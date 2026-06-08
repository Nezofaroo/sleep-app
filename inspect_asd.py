import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

asd_path = r"C:\Users\admin\AppData\Roaming\Microsoft\Word\Өндірісті%20ұйымдастыру312577731637896933\Өндірісті%20ұйымдастыру((Autosaved-312578273603524208)).asd"

if not os.path.exists(asd_path):
    # Try with unescaped space
    asd_path = asd_path.replace("%20", " ")

if not os.path.exists(asd_path):
    print(f"File not found: {asd_path}")
    sys.exit(1)

print(f"Reading first 100 bytes of {asd_path}:")
try:
    with open(asd_path, 'rb') as f:
        header = f.read(100)
        print("Hex representation:")
        print(header.hex(' ').upper())
        print("\nASCII representation:")
        print("".join([chr(b) if 32 <= b < 127 else '.' for b in header]))
except Exception as e:
    print(f"Error: {e}")
