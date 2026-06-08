import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

search_dirs = [
    os.path.expandvars(r"%APPDATA%\Microsoft\Word"),
    os.path.expandvars(r"%LOCALAPPDATA%\Temp"),
    os.path.expandvars(r"%LOCALAPPDATA%\Microsoft\Office\UnsavedFiles")
]

print("Searching for backup/autorecover files...")
for s_dir in search_dirs:
    if os.path.exists(s_dir):
        print(f"Searching in: {s_dir}")
        for root, dirs, files in os.walk(s_dir):
            for f in files:
                if "ұйымдастыру" in f.lower() or "өндірісті" in f.lower() or f.endswith(".asd") or (f.startswith("~w") and f.endswith(".tmp")):
                    path = os.path.join(root, f)
                    try:
                        size = os.path.getsize(path)
                        print(f"Match: {f}, Size: {size} bytes, Path: {path}")
                    except Exception as e:
                        pass
