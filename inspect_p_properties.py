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
    
    # Let's inspect P34, which is a normal text paragraph in Section 3.2
    p34 = paragraphs[34]
    p_xml = ET.tostring(p34, encoding='utf-8').decode('utf-8')
    print("XML structure of P34:")
    print(p_xml[:1500]) # Print first 1500 chars
