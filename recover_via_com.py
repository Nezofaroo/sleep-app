import subprocess
import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

asd_path = r"C:\Users\admin\AppData\Roaming\Microsoft\Word\Өндірісті%20ұйымдастыру312577731637896933\Өндірісті%20ұйымдастыру((Autosaved-312578273603524208)).asd"
dest_docx = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Өндірісті ұйымдастыру.docx"

if not os.path.exists(asd_path):
    asd_path = asd_path.replace("%20", " ")

if not os.path.exists(asd_path):
    print("ASD file not found!")
    sys.exit(1)

# PowerShell script to run
ps_script = f"""
try {{
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $doc = $word.Documents.Open("{asd_path}")
    $doc.SaveAs([ref]"{dest_docx}", [ref]12)
    $doc.Close()
    $word.Quit()
    Write-Output "Successfully recovered via Word COM!"
}} catch {{
    Write-Error $_.Exception.Message
    if ($word) {{ $word.Quit() }}
}}
"""

print("Running Word COM recovery via PowerShell...")
process = subprocess.run(["powershell", "-Command", ps_script], capture_output=True, text=True)

print("Stdout:")
print(process.stdout)
print("Stderr:")
print(process.stderr)

if process.returncode == 0 and "Successfully" in process.stdout:
    print("Recovery completed successfully!")
else:
    print("Recovery failed.")
    sys.exit(1)
