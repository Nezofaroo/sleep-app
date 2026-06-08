import zipfile
import sys

sys.stdout.reconfigure(encoding='utf-8')

docx_path = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Пікір Бако.docx"

try:
    with zipfile.ZipFile(docx_path, 'r') as z:
        print(f"Total files in zip: {len(z.namelist())}")
        for name in sorted(z.namelist()):
            print(f"  {name}")
except Exception as e:
    print(f"Error: {e}")
