import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

search_paths = [
    r"C:\Users\admin\OneDrive\Рабочий стол",
    r"C:\Users\admin\Favorites\Downloads"
]

print("Searching for other copies of the document...")
for path in search_paths:
    if os.path.exists(path):
        for root, dirs, files in os.walk(path):
            for f in files:
                if "өндірісті" in f.lower() and f.endswith(".docx"):
                    full_path = os.path.join(root, f)
                    size = os.path.getsize(full_path)
                    print(f"Found: {f}, Size: {size} bytes, Path: {full_path}")
