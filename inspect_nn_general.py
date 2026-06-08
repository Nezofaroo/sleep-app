import zipfile
import xml.etree.ElementTree as ET
import sys
import os

sys.stdout.reconfigure(encoding='utf-8')

general_docx = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Жалпы болым.docx"

if not os.path.exists(general_docx):
    print("General section document not found!")
    sys.exit(1)

with zipfile.ZipFile(general_docx, 'r') as docx:
    xml_content = docx.read('word/document.xml')
    root = ET.fromstring(xml_content)
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    paragraphs = root.findall('.//w:p', ns)
    
    print("Headings in Жалпы бөлім.docx:")
    for idx, p in enumerate(paragraphs):
        text_runs = p.findall('.//w:t', ns)
        text = "".join([run.text for run in text_runs if run.text]).strip()
        # Look for headings starting with numbers
        if text.startswith("1") or text.startswith("Кіріспе") or text.startswith("Жалпы"):
            print(f"P{idx}: {text}")
