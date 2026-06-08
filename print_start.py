import sys
sys.stdout.reconfigure(encoding='utf-8')

with open(r"c:\Android\AndroidStudioProjects\sleep_tracker_app\old_script_extracted.py", "r", encoding="utf-8") as f:
    content = f.read()

print("File starts with:")
print(content[:2000])
