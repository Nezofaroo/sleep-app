import zipfile
import xml.etree.ElementTree as ET
import sys

sys.stdout.reconfigure(encoding='utf-8')

docx_path = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Өндірісті ұйымдастыру.docx"

with zipfile.ZipFile(docx_path, 'r') as docx:
    xml_content = docx.read('word/document.xml')
    root = ET.fromstring(xml_content)
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    body = root.find('.//w:body', ns)
    
    for idx in range(0, 36):
        child = body[idx]
        tag = child.tag.split('}')[-1]
        text = ""
        if tag == "p":
            text_runs = child.findall('.//w:t', ns)
            text = "".join([run.text for run in text_runs if run.text])
            has_drawing = child.find('.//w:drawing', ns) is not None
            drawing_str = " [HAS_DRAWING]" if has_drawing else ""
            print(f"Child {idx}: <{tag}> {text[:80]}{drawing_str}")
        elif tag == "tbl":
            print(f"Child {idx}: <{tag}>")
        else:
            print(f"Child {idx}: <{tag}>")
