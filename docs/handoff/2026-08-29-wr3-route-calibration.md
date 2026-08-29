# WR3 route fix — structural change done, calibration open

**State:** uncommitted on `main` (clean and pushed at `79209b4`). The structural fix is complete and
its own suites are green; it takes the pro engine out of five calibration bands and that is not yet
solved.

## What the defect was

`Assignment` sent four players into a pass pattern -- `prefix(2)` wide receivers, one tight end, one
back, capped at `MatchupRules.receiversInRoute` -- while `DepthChart`'s formation put **three**
receivers on the field (11 personnel, `02` §11.2.1). The third receiver stood in the pattern's place
on every snap of every game and could never be thrown to: no reception, no receiving yard, no
receiving touchdown, for an entire career. Development, awards, statistics leaders, draft and
recruiting evaluation all read that hole as fact about the player.

`CompetitionRules.wr3PlusTargetShare` was `0.0` for exactly as long, which was correct *agreement*
with the detailed engine rather than a second defect -- raising it alone failed the two-tier gate on
both tiers, which is how the coupling was found.

## What is done

- `03` §1.1a records the rule: a pass sends every eligible receiver in the formation into the pattern.
- `MatchupRules.receiversInRoute` 4 -> 5; `Assignment` takes three receivers.
- `CompetitionRules` target shares set from what the fixed detailed engine actually produces, not
  fitted: WR1 0.2983, WR2 0.2364, WR3+ 0.1901, TE 0.1572, RB 0.1181. College and pro agree to
  within 0.0005 and the five sum to 1.0000.
- Both play-by-play fingerprints re-pinned, measured in three release processes and in debug.
- `--engine` 70 tests / 31,903 checks green, including a new test that every receiver on the field
  is in the route.

## What is not done

`--calibration-gate` passes on `79209b4` (confirmed twice, independently) and fails with this change:
4 of 24 pro checks on the tuning ladder, 5 on the holdout. Both ladders agree on the two `[Q]`
research-backed misses, so this is a real distributional shift, not seed noise.

### Mechanism

The chosen target is the **maximum** openness over the routed receivers -- `SnapResolver` step 4, and
the comment there still says "the most open of four". The expected maximum of *n* candidates scales
about n/(n+1): 0.800 at four, 0.833 at five. That inflated `opennessThrowHelp` on every throw.

### What one principled refit bought

`opennessThrowHelp` 0.30 -> 0.288, scaled by the inverse of that ratio to hold the expected help
invariant to progression size. Measured on the tuning ladder, reproduced byte-identically in two
independent processes:

| metric (seeds A) | before refit | after refit | band | state |
|---|---|---|---|---|
| points per drive | 1.9713 | 1.9499 | <= 1.9500 | theta inside, CI upper 1.9688 out |
| explosive pass rate | 0.1530 | 0.1517 | <= 0.1500 | out |
| touchdowns of 40+ yards | 0.2080 | 0.2057 | >= 0.2000 | out, and moved *away* |
| tie rate | 0.0003 | 0.0003 | CI >= 0 | unmoved |

### Why one constant cannot finish it

The levers oppose each other. A -4% coefficient cut bought -1.1% on points per drive and -0.85% on
explosive pass rate; closing the remaining explosive-pass gap needs roughly another -9%, which drags
40+ yard touchdowns from 0.2057 toward 0.187 -- further under a floor it already misses. Tie rate
does not respond to this lever at all: it was ~3 ties per 3,000 games at baseline and is ~1 now, a
low-count statistic whose CI straddles zero.

### What the data says the model needs

The third receiver shifted the **depth mix** shallow: more intermediate completions, fewer deep
attempts, hence explosive passes up while long touchdowns fell. That is a target-selection question
-- how `SnapResolver.weightedTarget` trades openness against depth as the progression grows -- not a
coefficient question. Fitting several constants at once against seeds A would overfit the tuning
ladder, and `CalibrationHarness` states the rule at its declaration site: "If A and B disagree, the
model is overfitted and the answer is a better model, never a wider band."

## Note on the verification lane

`runCalibrationGateTests` is reachable only from `--calibration-gate` and `--calibration-tuning`. The
default `SimTests` run does not call it, so `./scripts/verify.sh` -- the `05` G2 gate -- does **not**
cover calibration. "verify.sh passes" and "the engine is calibrated" are separate claims.
