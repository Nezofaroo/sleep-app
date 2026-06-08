import sys
sys.stdout.reconfigure(encoding='utf-8')

with open(r"c:\Android\AndroidStudioProjects\sleep_tracker_app\old_script_unescaped.py", "r", encoding="utf-8") as f:
    content = f.read()

print("File ends with:")
print(content[-3000:])
