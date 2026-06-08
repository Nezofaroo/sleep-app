import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

directory = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка"
for root, dirs, files in os.walk(directory):
    for f in files:
        path = os.path.join(root, f)
        try:
            size = os.path.getsize(path)
            print(f"File: {f}, Size: {size} bytes, Path: {path}")
        except Exception as e:
            print(f"Error reading {f}: {e}")
