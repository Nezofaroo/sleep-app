import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

lib_dir = r"c:\Android\AndroidStudioProjects\sleep_tracker_app\lib"

if not os.path.exists(lib_dir):
    print("lib directory not found!")
    sys.exit(1)

for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            full_path = os.path.join(root, f)
            with open(full_path, 'r', encoding='utf-8') as file:
                lines = len(file.readlines())
            size = os.path.getsize(full_path)
            print(f"File: {f}, Lines: {lines}, Size: {size} bytes, Path: {full_path}")
