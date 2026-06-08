import zipfile
import xml.etree.ElementTree as ET
import sys
import os

sys.stdout.reconfigure(encoding='utf-8')

docx_path = r"C:\Users\admin\OneDrive\Рабочий стол\А.А.Дипломка\Диплом Абдыкадыр.А\Мазмұны.docx"

if not os.path.exists(docx_path):
    print(f"Error: {docx_path} does not exist!")
    sys.exit(1)

try:
    with zipfile.ZipFile(docx_path, 'r') as docx:
        xml_content = docx.read('word/document.xml')
        root = ET.fromstring(xml_content)
        ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
        paragraphs = root.findall('.//w:p', ns)
        print(f"Total paragraphs in example: {len(paragraphs)}")
        for idx, p in enumerate(paragraphs):
            text_runs = p.findall('.//w:t', ns)
            text = "".join([run.text for run in text_runs if run.text])
            has_drawing = p.find('.//w:drawing', ns) is not None
            drawing_str = " [HAS_DRAWING]" if has_drawing else ""
            if text.strip() or has_drawing:
                print(f"P{idx}: {text}{drawing_str}")
except Exception as e:
    print(f"Error: {e}")
