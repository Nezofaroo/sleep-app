import zipfile
import xml.etree.ElementTree as ET
import sys

sys.stdout.reconfigure(encoding='utf-8')

dest_docx = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Өндірісті ұйымдастыру.docx"
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

with zipfile.ZipFile(dest_docx, 'r') as docx:
    xml_content = docx.read('word/document.xml')
    root = ET.fromstring(xml_content)
    
    # Let's search for w:b elements
    bolds = root.findall('.//w:b', ns)
    print(f"Total w:b elements: {len(bolds)}")
    for idx, b in enumerate(bolds):
        # Find parent run or paragraph properties or style
        parent = root.find(f".//*[w:b][{idx+1}]", ns) # Or we can find path
        print(f"B{idx}: Tag={b.tag}, Parent={parent.tag if parent is not None else 'None'}")
        if parent is not None:
            # Let's find grandparent
            grandparent = root.find(f".//*[{parent.tag}]", ns) # rough
            # Let's just print parent XML
            print("Parent XML:", ET.tostring(parent, encoding='utf-8').decode('utf-8')[:300])
