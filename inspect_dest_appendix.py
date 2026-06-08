import zipfile
import xml.etree.ElementTree as ET
import sys
import os

sys.stdout.reconfigure(encoding='utf-8')

docx_path = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Қосымша.docx"

with zipfile.ZipFile(docx_path, 'r') as docx:
    xml_content = docx.read('word/document.xml')
    root = ET.fromstring(xml_content)
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    paragraphs = root.findall('.//w:p', ns)
    print(f"Total paragraphs: {len(paragraphs)}")
    for idx, p in enumerate(paragraphs):
        text_runs = p.findall('.//w:t', ns)
        text = "".join([run.text for run in text_runs if run.text]).strip()
        if text:
            print(f"P{idx}: {text[:120]}")
