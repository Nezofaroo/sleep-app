import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

word_dir = r"C:\Users\admin\AppData\Roaming\Microsoft\Word\Өндірісті%20ұйымдастыру312577731637896933"
if os.path.exists(word_dir):
    print(f"Contents of {word_dir}:")
    for f in os.listdir(word_dir):
        path = os.path.join(word_dir, f)
        size = os.path.getsize(path)
        print(f"  File: {f}, Size: {size} bytes")
else:
    # Try unescaped
    word_dir = word_dir.replace("%20", " ")
    if os.path.exists(word_dir):
        print(f"Contents of {word_dir}:")
        for f in os.listdir(word_dir):
            path = os.path.join(word_dir, f)
            size = os.path.getsize(path)
            print(f"  File: {f}, Size: {size} bytes")
    else:
        print("Directory does not exist.")
