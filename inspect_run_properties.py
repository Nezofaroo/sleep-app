import zipfile
import xml.etree.ElementTree as ET
import sys

sys.stdout.reconfigure(encoding='utf-8')

docx_path = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Пікір Бако.docx"

try:
    with zipfile.ZipFile(docx_path, 'r') as docx:
        xml_content = docx.read('word/document.xml')
        root = ET.fromstring(xml_content)
        
        ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
        
        paragraphs = root.findall('.//w:p', ns)
        
        for idx, p in enumerate(paragraphs):
            runs = p.findall('.//w:r', ns)
            if not runs:
                continue
            print(f"\nP{idx}:")
            for r_idx, r in enumerate(runs):
                t_elements = r.findall('.//w:t', ns)
                text = "".join([t.text for t in t_elements if t.text])
                
                # Check properties
                rPr = r.find('w:rPr', ns)
                props = []
                if rPr is not None:
                    props = [child.tag.split('}')[-1] for child in rPr]
                print(f"  Run {r_idx} ({repr(text)}): props={props}")
except Exception as e:
    print(f"Error: {e}")
