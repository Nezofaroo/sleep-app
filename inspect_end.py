import zipfile
import xml.etree.ElementTree as ET
import sys

sys.stdout.reconfigure(encoding='utf-8')

docx_path = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Өндірісті ұйымдастыру.docx"

with zipfile.ZipFile(docx_path, 'r') as docx:
    xml_content = docx.read('word/document.xml')
    root = ET.fromstring(xml_content)
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    paragraphs = root.findall('.//w:p', ns)
    print(f"Total paragraphs: {len(paragraphs)}")
    for i in range(380, len(paragraphs)):
        p = paragraphs[i]
        text_runs = p.findall('.//w:t', ns)
        text = "".join([run.text for run in text_runs if run.text])
        has_drawing = p.find('.//w:drawing', ns) is not None
        drawing_str = " [HAS_DRAWING]" if has_drawing else ""
        print(f"P{i}: {text}{drawing_str}")
