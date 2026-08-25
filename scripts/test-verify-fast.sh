#!/usr/bin/env bash

set -euo pipefail
cd "$(dirname "$0")/.."

test_root="$(mktemp -d "${TMPDIR:-/tmp}/pfc-verify-fast-test.XXXXXX")"
trap 'rm -rf -- "${test_root:?}"' EXIT

fake_bin="$test_root/bin"
fake_product="$test_root/product"
build_calls="$test_root/build-calls"
shard_calls="$test_root/shard-calls"
mkdir -p "$fake_bin" "$fake_product"

printf '%s\n' \
    '#!/usr/bin/env bash' \
    'set -euo pipefail' \
    'if [ "${1:-}" = "--version" ]; then printf "%s\n" "Swift test double"; exit 0; fi' \
    'if [[ " $* " == *" --show-bin-path "* ]]; then printf "%s\n" "$PFC_TEST_PRODUCT"; exit 0; fi' \
    'printf "%s\n" build >> "$PFC_TEST_BUILD_CALLS"' \
    > "$fake_bin/swift"

printf '%s\n' \
    '#!/usr/bin/env bash' \
    'exit 0' \
    > "$fake_bin/xcrun"

printf '%s\n' \
    '#!/usr/bin/env bash' \
    'set -euo pipefail' \
    'printf "%s\n" "$1" >> "$PFC_TEST_SHARD_CALLS"' \
    'attempts=0' \
    'while [ "$(wc -l < "$PFC_TEST_SHARD_CALLS")" -lt 2 ]; do' \
    '    attempts=$((attempts + 1))' \
    '    [ "$attempts" -lt 40 ] || exit 9' \
    '    sleep 0.05' \
    'done' \
    'if [ "$1" = "${PFC_TEST_FAIL_SELECTOR:-}" ]; then printf "%s\n" partial; exit 7; fi' \
    'printf "%s\n" "1 tests, 1 checks" "all passed"' \
    > "$fake_product/SimTests"

chmod +x "$fake_bin/swift" "$fake_bin/xcrun" "$fake_product/SimTests"

if ! output="$({
    PATH="$fake_bin:$PATH" \
    PFC_TEST_PRODUCT="$fake_product" \
    PFC_TEST_BUILD_CALLS="$build_calls" \
    PFC_TEST_SHARD_CALLS="$shard_calls" \
    PFC_VERIFY_FAST_SCRATCH="$test_root/scratch" \
        ./scripts/verify.sh --fast --jobs 2
} 2>&1)"; then
    printf '%s\n' "$output" >&2
    exit 1
fi

[ "$(wc -l < "$build_calls" | tr -d ' ')" = "1" ]
[ "$(wc -l < "$shard_calls" | tr -d ' ')" = "4" ]
diff -u \
    <(printf '%s\n' --core-contracts --engine --generation-only --screen-read-models) \
    <(sort "$shard_calls")
[[ "$output" == *"5 passed, 0 failed"* ]] || exit 1

failure_build_calls="$test_root/failure-build-calls"
failure_shard_calls="$test_root/failure-shard-calls"
set +e
failure_output="$({
    PATH="$fake_bin:$PATH" \
    PFC_TEST_PRODUCT="$fake_product" \
    PFC_TEST_BUILD_CALLS="$failure_build_calls" \
    PFC_TEST_SHARD_CALLS="$failure_shard_calls" \
    PFC_TEST_FAIL_SELECTOR=--engine \
    PFC_VERIFY_FAST_SCRATCH="$test_root/failure-scratch" \
        ./scripts/verify.sh --fast --jobs 2
} 2>&1)"
failure_status=$?
set -e
[ "$failure_status" -eq 1 ]
[ "$(wc -l < "$failure_shard_calls" | tr -d ' ')" = "4" ]
[[ "$failure_output" == *"FAIL  engine"* ]] || exit 1
[[ "$failure_output" == *"4 passed, 1 failed"* ]] || exit 1

broken_bin="$test_root/broken-bin"
mkdir -p "$broken_bin"
printf '%s\n' '#!/usr/bin/env bash' 'exit 125' > "$broken_bin/xargs"
chmod +x "$broken_bin/xargs"
set +e
worker_output="$({
    PATH="$broken_bin:$fake_bin:$PATH" \
    PFC_TEST_PRODUCT="$fake_product" \
    PFC_TEST_BUILD_CALLS="$test_root/worker-build-calls" \
    PFC_VERIFY_FAST_SCRATCH="$test_root/worker-scratch" \
        ./scripts/verify.sh --fast --jobs 2
} 2>&1)"
worker_status=$?
set -e
[ "$worker_status" -eq 1 ]
[[ "$worker_output" == *"1 passed, 4 failed"* ]] || exit 1

empty_bin="$test_root/empty-bin"
mkdir -p "$empty_bin"
printf '%s\n' \
    '#!/usr/bin/env bash' \
    'for label in core-contracts engine generation read-models; do' \
    '    : > "$PFC_FAST_STATUS_ROOT/$label"' \
    'done' \
    > "$empty_bin/xargs"
chmod +x "$empty_bin/xargs"
set +e
empty_output="$({
    PATH="$empty_bin:$fake_bin:$PATH" \
    PFC_TEST_PRODUCT="$fake_product" \
    PFC_TEST_BUILD_CALLS="$test_root/empty-build-calls" \
    PFC_VERIFY_FAST_SCRATCH="$test_root/empty-scratch" \
        ./scripts/verify.sh --fast --jobs 2
} 2>&1)"
empty_status=$?
set -e
[ "$empty_status" -eq 1 ]
[[ "$empty_output" == *"1 passed, 4 failed"* ]] || exit 1

set +e
invalid_output="$(./scripts/verify.sh --fast --jobs 0 2>&1)"
invalid_status=$?
set -e
[ "$invalid_status" -eq 2 ]
[[ "$invalid_output" == *"--jobs requires an integer from 1 to 8"* ]] || exit 1

set +e
ignored_output="$({
    PATH="$fake_bin:$PATH" \
    PFC_TEST_PRODUCT="$fake_product" \
    PFC_TEST_BUILD_CALLS="$build_calls" \
        ./scripts/verify.sh --jobs 2 --build
} 2>&1)"
ignored_status=$?
set -e
[ "$ignored_status" -eq 2 ]
[[ "$ignored_output" == *"--jobs requires --fast"* ]] || exit 1

help_output="$(./scripts/verify.sh --help)"
[[ "$help_output" == *"--fast --jobs 2"* ]] || exit 1
[[ "$help_output" != *"set -euo pipefail"* ]] || exit 1

printf '%s\n' "verify fast tests passed"
