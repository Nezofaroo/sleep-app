import zipfile
import xml.etree.ElementTree as ET
import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

def inspect_doc(path):
    print(f"\n--- Inspecting {path} ---")
    if not os.path.exists(path):
        print("File does not exist!")
        return
    try:
        with zipfile.ZipFile(path, 'r') as docx:
            xml_content = docx.read('word/document.xml')
            root = ET.fromstring(xml_content)
            paragraphs = root.findall('.//w:p', ns)
            print(f"Total paragraphs: {len(paragraphs)}")
            for idx in range(min(30, len(paragraphs))):
                p = paragraphs[idx]
                text_runs = p.findall('.//w:t', ns)
                text = "".join([run.text for run in text_runs if run.text])
                has_drawing = p.find('.//w:drawing', ns) is not None
                drawing_str = " [HAS_DRAWING]" if has_drawing else ""
                if text.strip() or has_drawing:
                    print(f"P{idx}: {text[:100]}{drawing_str}")
            # print the last few paragraphs
            if len(paragraphs) > 30:
                print("...")
                for idx in range(max(30, len(paragraphs) - 5), len(paragraphs)):
                    p = paragraphs[idx]
                    text_runs = p.findall('.//w:t', ns)
                    text = "".join([run.text for run in text_runs if run.text])
                    has_drawing = p.find('.//w:drawing', ns) is not None
                    drawing_str = " [HAS_DRAWING]" if has_drawing else ""
                    if text.strip() or has_drawing:
                        print(f"P{idx}: {text[:100]}{drawing_str}")
    except Exception as e:
        print(f"Error: {e}")

inspect_doc(r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Қосымша.docx")
inspect_doc(r"C:\Users\admin\OneDrive\Рабочий стол\А.А.Дипломка\Диплом Абдыкадыр.А\Қосымша.docx")
inspect_doc(r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Қосымша А.docx")
