import zipfile
import xml.etree.ElementTree as ET
import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

def inspect_doc(path):
    print(f"\n--- Inspecting {os.path.basename(path)} ---")
    if not os.path.exists(path):
        print("Does not exist!")
        return
    with zipfile.ZipFile(path, 'r') as docx:
        root = ET.fromstring(docx.read('word/document.xml'))
        paragraphs = root.findall('.//w:p', ns)
        count = 0
        for idx, p in enumerate(paragraphs):
            text_runs = p.findall('.//w:t', ns)
            text = "".join([run.text for run in text_runs if run.text]).strip()
            if text and (text[0].isdigit() or text.isupper() or "қорытынды" in text.lower() or "бөлім" in text.lower() or "кіріспе" in text.lower()):
                if len(text) < 120:
                    print(f"P{idx}: {text}")
                    count += 1
        print(f"Total potential headings printed: {count}")

inspect_doc(r"C:\Users\admin\OneDrive\Рабочий стол\А.А.Дипломка\Диплом Абдыкадыр.А\Жалпы бөлім.docx")
inspect_doc(r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Жалпы болым.docx")
inspect_doc(r"C:\Users\admin\OneDrive\Рабочий стол\А.А.Дипломка\Диплом Абдыкадыр.А\Арнайы бөлім.docx")
inspect_doc(r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Н.Н. Арнайы болым.docx")
