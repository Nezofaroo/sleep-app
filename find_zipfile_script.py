import os
import sys
import json

log_dir = r"C:\Users\admin\.gemini\antigravity\brain\8214fc3e-ecce-4eac-b9b3-58371355eea2\.system_generated\logs"
transcript_path = os.path.join(log_dir, "transcript.jsonl")

if not os.path.exists(transcript_path):
    print("Transcript not found.")
    sys.exit(1)

try:
    with open(transcript_path, 'r', encoding='utf-8') as f:
        for line_num, line in enumerate(f):
            if "import zipfile" in line and "replace_text" in line:
                try:
                    obj = json.loads(line)
                    if "tool_calls" in obj:
                        for tc in obj["tool_calls"]:
                            if tc.get("name") == "write_to_file":
                                args = tc.get("args", {})
                                code = args.get("CodeContent")
                                if code and "zipfile" in code:
                                    print(f"Found code inside write_to_file call at line {line_num}!")
                                    out_path = r"c:\Android\AndroidStudioProjects\sleep_tracker_app\old_script_extracted.py"
                                    with open(out_path, "w", encoding="utf-8") as out:
                                        out.write(code)
                                    print(f"Extracted code written to {out_path}")
                                    sys.exit(0)
                except Exception as ex:
                    print(f"Failed to parse JSON on line {line_num}: {ex}")
except Exception as e:
    print(f"Error: {e}")
