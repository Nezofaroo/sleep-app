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
    
    print(f"Total children of body: {len(body)}")
    for idx, child in enumerate(body):
        # We only want to show the tag name and text if it is a paragraph
        tag = child.tag.split('}')[-1]
        text = ""
        if tag == "p":
            text_runs = child.findall('.//w:t', ns)
            text = "".join([run.text for run in text_runs if run.text])
            has_drawing = child.find('.//w:drawing', ns) is not None
            drawing_str = " [HAS_DRAWING]" if has_drawing else ""
            print(f"Child {idx}: <{tag}> {text[:80]}{drawing_str}")
        elif tag == "tbl":
            # Let's see the first row cell text of the table to identify it
            cell_texts = []
            for cell in child.findall('.//w:tc', ns)[:3]:
                truns = cell.findall('.//w:t', ns)
                cell_texts.append("".join([r.text for r in truns if r.text]))
            print(f"Child {idx}: <{tag}> Cells: {cell_texts}")
        else:
            print(f"Child {idx}: <{tag}>")
