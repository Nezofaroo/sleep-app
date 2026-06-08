import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

lib_dir = r"c:\Android\AndroidStudioProjects\sleep_tracker_app\lib"
print("Dart files in lib directory:")
for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if f.endswith(".dart"):
            path = os.path.join(root, f)
            rel_path = os.path.relpath(path, lib_dir)
            try:
                with open(path, 'r', encoding='utf-8') as file:
                    lines = file.readlines()
                print(f"File: {rel_path}, Lines: {len(lines)}")
            except Exception as e:
                print(f"Error reading {rel_path}: {e}")
