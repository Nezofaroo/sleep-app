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
    
    print(f"Mapping figures from document:")
    
    # Let's search for "Сурет 3.X" or "Cурет 3.X" (note the Cyrillic/Latin C)
    def get_text(p):
        text_runs = p.findall('.//w:t', ns)
        return "".join([run.text for run in text_runs if run.text]).strip()

    figures = {}
    for idx, p in enumerate(paragraphs):
        text = get_text(p)
        # Check if text starts with "Сурет 3." or "Cурет 3."
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
                # Find preceding drawing paragraph
                preceding_drawing = None
                for search_idx in range(idx - 1, -1, -1):
                    # Check if search_idx has drawing
                    search_p = paragraphs[search_idx]
                    if search_p.find('.//w:drawing', ns) is not None:
                        preceding_drawing = (search_idx, search_p)
                        break
                    # If we find another caption or heading, stop
                    search_text = get_text(search_p)
                    if search_text.startswith("Сурет 3.") or search_text.startswith("Cурет 3."):
                        break
                
                figures[num] = {
                    'caption_idx': idx,
                    'caption_text': text,
                    'drawing_idx': preceding_drawing[0] if preceding_drawing else None,
                    'has_drawing_elem': preceding_drawing[1].find('.//w:drawing', ns) is not None if preceding_drawing else False
                }
            except Exception as e:
                print(f"Error parsing {text}: {e}")
                
    for num in sorted(figures.keys()):
        fig = figures[num]
        print(f"Figure {num}:")
        print(f"  Caption: {fig['caption_text']} (P{fig['caption_idx']})")
        print(f"  Drawing P-Index: P{fig['drawing_idx']} (Has drawing element: {fig['has_drawing_elem']})")
