import zipfile
import xml.etree.ElementTree as ET
import sys

sys.stdout.reconfigure(encoding='utf-8', errors='backslashreplace')

docx_path = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Пікір Бако.docx"

try:
    with zipfile.ZipFile(docx_path, 'r') as docx:
        xml_content = docx.read('word/document.xml')
        root = ET.fromstring(xml_content)
        
        ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
        
        paragraphs = root.findall('.//w:p', ns)
        print(f"Total paragraphs: {len(paragraphs)}")
        
        for idx in range(len(paragraphs)):
            p = paragraphs[idx]
            text_runs = p.findall('.//w:t', ns)
            text = "".join([run.text for run in text_runs if run.text])
            print(f"P{idx}: {text}")
except Exception as e:
    print(f"Error: {e}")
