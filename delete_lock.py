import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

dest_dir = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка"

if not os.path.exists(dest_dir):
    print("Destination directory does not exist.")
    sys.exit(0)

deleted_count = 0
for f in os.listdir(dest_dir):
    if f.startswith("~$"):
        full_path = os.path.join(dest_dir, f)
        try:
            os.remove(full_path)
            print(f"Deleted lock file: {f}")
            deleted_count += 1
        except Exception as e:
            print(f"Failed to delete lock file {f}: {e}")

print(f"Done. Deleted {deleted_count} lock files.")
