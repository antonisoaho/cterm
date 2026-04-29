import json, sys, os, tempfile

d = json.load(sys.stdin)
tool = d.get('tool_name', '')
filepath = d.get('tool_input', {}).get('file_path', '')

if tool in ('Write', 'Edit') and filepath:
    print(filepath)
elif tool == 'EnterPlanMode':
    resp = d.get('tool_response', {})
    content = resp if isinstance(resp, str) else json.dumps(resp, indent=2)
    planfile = os.path.join(tempfile.gettempdir(), 'claude-plan.md')
    open(planfile, 'w').write(content)
    planfile = planfile.replace('\\', '/').replace('C:', '/c').replace('c:', '/c')
    print(planfile)
