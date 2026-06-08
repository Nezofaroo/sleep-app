import zipfile
import xml.etree.ElementTree as ET
import sys
import os

sys.stdout.reconfigure(encoding='utf-8')

special_docx = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Н.Н. Арнайы болым.docx"

if not os.path.exists(special_docx):
    print("Special section document not found!")
    sys.exit(1)

with zipfile.ZipFile(special_docx, 'r') as docx:
    xml_content = docx.read('word/document.xml')
    root = ET.fromstring(xml_content)
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    paragraphs = root.findall('.//w:p', ns)
    
    print("Headings in Н.Н. Арнайы болым.docx:")
    for idx, p in enumerate(paragraphs):
        text_runs = p.findall('.//w:t', ns)
        text = "".join([run.text for run in text_runs if run.text]).strip()
        # Look for headings starting with numbers or containing "БӨЛІМ"
        if text.startswith("2") or text.startswith("Арнайы"):
            print(f"P{idx}: {text}")
