import zipfile
import xml.etree.ElementTree as ET
import sys

sys.stdout.reconfigure(encoding='utf-8')

docx_path = r"C:\Users\admin\OneDrive\Рабочий стол\А.А.Дипломка\Диплом Абдыкадыр.А\Мазмұны.docx"

with zipfile.ZipFile(docx_path, 'r') as docx:
    xml_content = docx.read('word/document.xml')
    root = ET.fromstring(xml_content)
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    
    tables = root.findall('.//w:tbl', ns)
    print(f"Total tables: {len(tables)}")
    for t_idx, table in enumerate(tables):
        rows = table.findall('.//w:tr', ns)
        print(f"Table {t_idx} has {len(rows)} rows:")
        for r_idx, row in enumerate(rows):
            cells = row.findall('.//w:tc', ns)
            print(f"  Row {r_idx} has {len(cells)} cells:")
            for c_idx, cell in enumerate(cells):
                paragraphs = cell.findall('.//w:p', ns)
                cell_text = []
                for p in paragraphs:
                    truns = p.findall('.//w:t', ns)
                    text = "".join([r.text for r in truns if r.text])
                    cell_text.append(text)
                print(f"    Cell {c_idx}: {cell_text[:5]} (has {len(paragraphs)} paragraphs)")
