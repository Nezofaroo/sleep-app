import zipfile
import xml.etree.ElementTree as ET
import sys

sys.stdout.reconfigure(encoding='utf-8')

docx_path = r"C:\Users\admin\OneDrive\Рабочий стол\А.А.Дипломка\Диплом Абдыкадыр.А\Қорытынды.docx"

with zipfile.ZipFile(docx_path, 'r') as docx:
    xml_content = docx.read('word/document.xml')
    root = ET.fromstring(xml_content)
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    paragraphs = root.findall('.//w:p', ns)
    
    p7 = paragraphs[7]
    print("Runs and elements in P7:")
    for child in p7:
        tag = child.tag.split('}')[-1]
        print(f"  <{tag}>")
        if tag == "r":
            for r_child in child:
                rtag = r_child.tag.split('}')[-1]
                print(f"    <{rtag}>")
                if rtag == "t":
                    print(f"      Text: {repr(r_child.text)}")
