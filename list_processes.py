import subprocess
import sys

sys.stdout.reconfigure(encoding='utf-8')

try:
    output = subprocess.check_output('tasklist', shell=True).decode('cp1251')
    print("Listing all processes containing 'word' or 'office' or 'excel' or 'powerp':")
    found = False
    for line in output.splitlines():
        if any(w in line.lower() for w in ['winword', 'word', 'office', 'excel', 'powerp']):
            print(line)
            found = True
    if not found:
        print("No locking processes found in tasklist.")
except Exception as e:
    print(f"Error running tasklist: {e}")
