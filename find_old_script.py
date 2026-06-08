import os
import sys

# Reconfigure stdout for Kazakh encoding
sys.stdout.reconfigure(encoding='utf-8')

log_dir = r"C:\Users\admin\antigravity\brain\8214fc3e-ecce-4eac-b9b3-58371355eea2\.system_generated\logs"
# Wait, let's look at the correct path from metadata: C:\Users\admin\.gemini\antigravity
log_dir = r"C:\Users\admin\.gemini\antigravity\brain\8214fc3e-ecce-4eac-b9b3-58371355eea2\.system_generated\logs"
transcript_path = os.path.join(log_dir, "transcript.jsonl")

print(f"Checking transcript at: {transcript_path}")

if not os.path.exists(transcript_path):
    print("Transcript not found.")
    sys.exit(1)

try:
    with open(transcript_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        print(f"Total lines in transcript: {len(lines)}")
        
        # Search for lines containing replace_text_5.py or zipfile replacement logic
        found = []
        for idx, line in enumerate(lines):
            if "replace_text_5.py" in line or "w:rPr" in line:
                found.append(idx)
        
        print(f"Found {len(found)} matches.")
        # Print the last match details (context around it)
        if found:
            last_idx = found[-1]
            print(f"Last match at line {last_idx}:")
            # Print a snippet of that line
            snippet = lines[last_idx][:1000]
            print(snippet)
            
            # Let's write the whole line or parts of it containing python code to a file to inspect
            with open(r"c:\Android\AndroidStudioProjects\sleep_tracker_app\extracted_match.json", "w", encoding="utf-8") as out:
                out.write(lines[last_idx])
            print("Wrote last matching line to extracted_match.json")
except Exception as e:
    print(f"Error: {e}")
