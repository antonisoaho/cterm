#!/usr/bin/env bash
node -e '
var chunks=[];
process.stdin.on("data",function(c){chunks.push(c);});
process.stdin.on("end",function(){
  var d;try{d=JSON.parse(Buffer.concat(chunks).toString());}catch(e){process.exit(0);}
  var model=(d.model&&d.model.display_name)||"?";
  var cwd=(d.workspace&&d.workspace.current_dir)||process.cwd();
  cwd=cwd.replace(/[\/\\]+$/,"").split(/[\/\\]/).pop();
  process.stdout.write("\x1b[36m"+model+"\x1b[0m \x1b[2m|\x1b[0m "+cwd);
});
'
