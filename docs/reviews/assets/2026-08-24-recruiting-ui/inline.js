// Rebuilds the self-contained publishable copy: relative <img src> -> data: URIs.
// Run before publishing as an Artifact (external asset paths do not resolve there).
//   node inline.js <src.html> <out.html>
const fs=require('fs'), path=require('path');
const src=process.argv[2], out=process.argv[3]||src;
const base=path.dirname(path.resolve(src));
let h=fs.readFileSync(src,'utf8'), n=0;
h=h.replace(/src="(assets\/[^"]+\.png)"/g,(m,rel)=>{
  n++; return 'src="data:image/png;base64,'+fs.readFileSync(path.join(base,rel)).toString('base64')+'"';
});
fs.writeFileSync(out,h);
console.log('inlined',n,'images ->',out,(fs.statSync(out).size/1048576).toFixed(2),'MB');
