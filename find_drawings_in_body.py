import zipfile
import xml.etree.ElementTree as ET
import sys

sys.stdout.reconfigure(encoding='utf-8')

docx_path = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Өндірісті ұйымдастыру.docx"

with zipfile.ZipFile(docx_path, 'r') as docx:
    xml_content = docx.read('word/document.xml')
    root = ET.fromstring(xml_content)
    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    body = root.find('.//w:body', ns)
    
    def get_text(elem):
        if elem.tag.endswith('p'):
            text_runs = elem.findall('.//w:t', ns)
            return "".join([run.text for run in text_runs if run.text]).strip()
        return ""

    figures = {}
    for idx, child in enumerate(body):
        text = get_text(child)
        if (text.startswith("Сурет 3.") or text.startswith("Cурет 3.")) and len(text) > 8:
            # Extract number
            try:
                num_str = ""
                for char in text[8:]:
                    if char.isdigit():
                        num_str += char
                    else:
                        break
                num = int(num_str)
                
                # Search backwards for drawing paragraph
                drawing_idx = None
                for s_idx in range(idx - 1, -1, -1):
                    s_child = body[s_idx]
                    if s_child.tag.endswith('p') and s_child.find('.//w:drawing', ns) is not None:
                        drawing_idx = s_idx
                        break
                    # Stop if we hit another figure caption or a heading
                    s_text = get_text(s_child)
                    if s_text.startswith("Сурет 3.") or s_text.startswith("Cурет 3."):
                        break
                
                figures[num] = {
                    'caption_idx': idx,
                    'caption_text': text,
                    'drawing_idx': drawing_idx
                }
            except Exception as e:
                print(f"Error parsing {text}: {e}")

    for num in sorted(figures.keys()):
        fig = figures[num]
        print(f"Figure {num}:")
        print(f"  Caption: '{fig['caption_text']}' (Child {fig['caption_idx']})")
        if fig['drawing_idx'] is not None:
            drawing_p = body[fig['drawing_idx']]
            has_drawing = drawing_p.find('.//w:drawing', ns) is not None
            print(f"  Drawing: Child {fig['drawing_idx']} (Has drawing: {has_drawing})")
        else:
            print(f"  Drawing: None found!")
