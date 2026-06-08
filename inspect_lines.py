import os
import sys
import json

log_dir = r"C:\Users\admin\.gemini\antigravity\brain\8214fc3e-ecce-4eac-b9b3-58371355eea2\.system_generated\logs"
transcript_path = os.path.join(log_dir, "transcript.jsonl")

try:
    with open(transcript_path, 'r', encoding='utf-8') as f:
        for line_num, line in enumerate(f):
            if line_num in [359, 367, 409, 437]:
                print(f"--- Line {line_num} ---")
                obj = json.loads(line)
                print(f"Keys: {list(obj.keys())}")
                if "type" in obj:
                    print(f"Type: {obj['type']}")
                if "tool_calls" in obj:
                    print(f"Tool calls type: {type(obj['tool_calls'])}")
                    for tc in obj["tool_calls"]:
                        print(f"  Tool call type: {tc.get('type') or tc.get('name')}")
                        print(f"  Keys in tool call: {list(tc.keys())}")
                        if "function" in tc:
                            print(f"    Function keys: {list(tc['function'].keys())}")
                            print(f"    Function name: {tc['function'].get('name')}")
                # Print a small snippet of content or arguments
                content = obj.get("content", "")
                if content:
                    print(f"  Content length: {len(content)}")
                    print(f"  Content snippet: {content[:300]}")
except Exception as e:
    print(f"Error: {e}")
