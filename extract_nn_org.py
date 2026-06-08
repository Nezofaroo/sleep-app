import zipfile
import xml.etree.ElementTree as ET
import sys
import os

# Reconfigure stdout for Kazakh encoding
sys.stdout.reconfigure(encoding='utf-8')

docx_path = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Өндірісті ұйымдастыру.docx"
output_path = r"c:\Android\AndroidStudioProjects\sleep_tracker_app\nn_org_text.txt"

if not os.path.exists(docx_path):
    print(f"Error: {docx_path} does not exist!")
    sys.exit(1)

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
                # Let's also check if there is a drawing inside
                has_drawing = p.find('.//w:drawing', ns) is not None
                drawing_str = " [HAS_DRAWING]" if has_drawing else ""
                if text.strip() or has_drawing:
                    f.write(f"P{idx}: {text}{drawing_str}\n")
        print(f"Successfully extracted {len(paragraphs)} paragraphs to {output_path}")
except Exception as e:
    print(f"Error: {e}")
