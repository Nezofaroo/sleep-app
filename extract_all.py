import zipfile
import xml.etree.ElementTree as ET
import sys

# Reconfigure stdout for Kazakh encoding
sys.stdout.reconfigure(encoding='utf-8')

docx_path = r"C:\Users\admin\OneDrive\Рабочий стол\А.А.Дипломка\Диплом Абдыкадыр.А\Жалпы бөлім.docx"
output_path = r"c:\Android\AndroidStudioProjects\sleep_tracker_app\general_section_text.txt"

try:
    with zipfile.ZipFile(docx_path, 'r') as docx:
        xml_content = docx.read('word/document.xml')
        root = ET.fromstring(xml_content)
        
        # Namespaces
        ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
        
        paragraphs = root.findall('.//w:p', ns)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(f"Total paragraphs: {len(paragraphs)}\n\n")
            for idx, p in enumerate(paragraphs):
                text_runs = p.findall('.//w:t', ns)
                text = "".join([run.text for run in text_runs if run.text])
                f.write(f"P{idx}: {text}\n")
        print(f"Successfully extracted to {output_path}")
except Exception as e:
    print(f"Error: {e}")
