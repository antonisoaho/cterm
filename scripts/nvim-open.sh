#!/usr/bin/env bash
filepath=$(node -e '
var chunks=[];
process.stdin.on("data",function(c){chunks.push(c);});
process.stdin.on("end",function(){
  var d;try{d=JSON.parse(Buffer.concat(chunks).toString());}catch(e){process.exit(0);}
  var tool=d.tool_name||"";
  var fp=(d.tool_input&&d.tool_input.file_path)||"";
  if((tool==="Write"||tool==="Edit")&&fp){process.stdout.write(fp);}
  else if(tool==="EnterPlanMode"){
    var resp=d.tool_response;
    var content=typeof resp==="string"?resp:JSON.stringify(resp,null,2);
    var planfile=require("path").join(require("os").tmpdir(),"claude-plan.md");
    require("fs").writeFileSync(planfile,content);
    var posix=planfile.replace(/\\/g,"/").replace(/^([A-Za-z]):/,function(_,l){return"/"+l.toLowerCase();});
    process.stdout.write(posix);
  }
});
')
[ -z "$filepath" ] && exit 0
nvim --server "${CTERM_NVIM_ADDR:-127.0.0.1:6666}" --remote "$filepath" 2>/dev/null || true
