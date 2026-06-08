import zipfile
import xml.etree.ElementTree as ET
import sys

sys.stdout.reconfigure(encoding='utf-8')

docx_path = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Мазмұны 2.docx"
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

with zipfile.ZipFile(docx_path, 'r') as docx:
    xml_content = docx.read('word/document.xml')
    root = ET.fromstring(xml_content)
    tables = root.findall('.//w:tbl', ns)
    table = tables[0]
    cells = table.findall('.//w:tc', ns)
    
    cell_texts = []
    for cell in cells:
        for p in cell.findall('.//w:p', ns):
            for r in p.findall('.//w:r', ns):
                t = r.find('w:t', ns)
                if t is not None and t.text:
                    cell_texts.append(t.text.strip())
                    
    full_text = " ".join(cell_texts).lower()
    print("full_text length:", len(full_text))
    print("full_text content:")
    print(repr(full_text))
