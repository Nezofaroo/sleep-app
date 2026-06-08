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
    rows = table.findall('.//w:tr', ns)
    
    # Check Row 0 Cell 0
    p = rows[0].findall('.//w:tc', ns)[0].find('w:p', ns)
    text = "".join([r.text for r in p.findall('.//w:t', ns) if r.text]).strip()
    
    expected = "4 ЭКОНОМИКАЛЫҚ БӨЛІМ"
    print(f"Extracted: {repr(text)}")
    print(f"Expected:  {repr(expected)}")
    print(f"Match?     {text.lower() == expected.lower()}")
    
    # Check Row 1 Cell 0
    p1 = rows[1].findall('.//w:tc', ns)[0].find('w:p', ns)
    text1 = "".join([r.text for r in p1.findall('.//w:t', ns) if r.text]).strip()
    
    expected1 = "4.1 Экономикалық бөлімге кіріспе"
    print(f"Extracted1: {repr(text1)}")
    print(f"Expected1:  {repr(expected1)}")
    print(f"Match1?     {text1.lower() == expected1.lower()}")
