import zipfile
import xml.etree.ElementTree as ET
import sys
import os

sys.stdout.reconfigure(encoding='utf-8')

docx_path = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Мазмұны 2.docx"
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

with zipfile.ZipFile(docx_path, 'r') as docx:
    xml_content = docx.read('word/document.xml')
    root = ET.fromstring(xml_content)
    tables = root.findall('.//w:tbl', ns)
    table = tables[0]
    rows = table.findall('.//w:tr', ns)
    for r_idx, row in enumerate(rows):
        cells = row.findall('.//w:tc', ns)
        row_text = []
        for c_idx, cell in enumerate(cells):
            cell_p_text = []
            for p in cell.findall('.//w:p', ns):
                text = "".join([r.text for r in p.findall('.//w:t', ns) if r.text])
                cell_p_text.append(text)
            row_text.append(f"Cell {c_idx}: {cell_p_text}")
        print(f"Row {r_idx}: {row_text}")
