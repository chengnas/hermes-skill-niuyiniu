"""扭一扭 hook — 拦截 /扭一扭，直接跑脚本不走 AI"""
import subprocess
import os


async def handle(event_type: str, context: dict):
    script = os.path.expanduser("~/.hermes/scripts/niuyiniu.sh")
    try:
        result = subprocess.run(
            ["bash", script],
            capture_output=True, text=True, timeout=60,
        )
        output = result.stdout.strip()
        if output and "MEDIA:" in output:
            return {"decision": "handled", "message": output}
        return {"decision": "handled", "message": "扭一扭失败，待会儿再试~"}
    except Exception as e:
        return {"decision": "handled", "message": f"扭一扭出错: {e}"}
