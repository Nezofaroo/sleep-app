import zipfile
import xml.etree.ElementTree as ET
import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

def verify_file(path, expected_headings, expected_title=None):
    print(f"\nVerifying {os.path.basename(path)}...")
    if not os.path.exists(path):
        print(f"Error: {path} does not exist!")
        return False
        
    errors = 0
    with zipfile.ZipFile(path, 'r') as docx:
        xml_content = docx.read('word/document.xml')
        root = ET.fromstring(xml_content)
        
        # 1. Check title if specified
        if expected_title:
            paragraphs = root.findall('.//w:p', ns)
            title_p = paragraphs[0]
            title_text = "".join([r.text for r in title_p.findall('.//w:t', ns) if r.text]).strip()
            if title_text == expected_title:
                print(f"PASSED: Title is '{title_text}'")
            else:
                print(f"FAILED: Title is '{title_text}', expected '{expected_title}'")
                errors += 1
                
        # 2. Check for bold/italic tags
        bold_tags = (root.findall('.//w:pPr/w:b', ns) + 
                     root.findall('.//w:pPr/w:bCs', ns) + 
                     root.findall('.//w:rPr/w:b', ns) + 
                     root.findall('.//w:rPr/w:bCs', ns))
        italic_tags = (root.findall('.//w:pPr/w:i', ns) + 
                       root.findall('.//w:pPr/w:iCs', ns) + 
                       root.findall('.//w:rPr/w:i', ns) + 
                       root.findall('.//w:rPr/w:iCs', ns))
                       
        if len(bold_tags) > 0:
            print(f"FAILED: Found {len(bold_tags)} bold tags in XML!")
            errors += 1
        else:
            print("PASSED: No bold tags found.")
            
        if len(italic_tags) > 0:
            print(f"FAILED: Found {len(italic_tags)} italic tags in XML!")
            errors += 1
        else:
            print("PASSED: No italic tags found.")
            
        # 3. Check table contents and fonts
        tables = root.findall('.//w:tbl', ns)
        if len(tables) == 0:
            print("FAILED: No tables found in document!")
            errors += 1
            return False
            
        table = tables[0]
        cells = table.findall('.//w:tc', ns)
        
        # Collect all text in cells
        cell_texts = []
        for cell in cells:
            for p in cell.findall('.//w:p', ns):
                # Check run font and size
                for r in p.findall('.//w:r', ns):
                    rPr = r.find('w:rPr', ns)
                    if rPr is not None:
                        sz = rPr.find('w:sz', ns)
                        szCs = rPr.find('w:szCs', ns)
                        rFonts = rPr.find('w:rFonts', ns)
                        
                        # Verify size
                        if sz is not None and sz.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val') != '28':
                            print(f"FAILED: Found non-14pt size in run: {sz.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val')}")
                            errors += 1
                            
                        # Verify font
                        if rFonts is not None:
                            ascii_font = rFonts.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}ascii')
                            if ascii_font != 'Times New Roman':
                                print(f"FAILED: Found non-Times New Roman font: {ascii_font}")
                                errors += 1
                                
                    t = r.find('w:t', ns)
                    if t is not None and t.text:
                        cell_texts.append(t.text.strip())
                        
        # Check expected headings
        full_text = " ".join(cell_texts).lower()
        for heading in expected_headings:
            if heading.lower() in full_text:
                print(f"PASSED: Found heading '{heading}'")
            else:
                print(f"FAILED: Heading '{heading}' NOT found in table cells!")
                errors += 1
                
    if errors == 0:
        print(f"SUCCESS: {os.path.basename(path)} is valid!")
        return True
    else:
        print(f"FAILURE: {os.path.basename(path)} has {errors} errors.")
        return False

# Headings to verify in page 1
headings_1 = [
    "1 ЖАЛПЫ БӨЛІМ",
    "1.2 Деректерді сақтау және өңдеу технологиялары",
    "1.3.1 Dart бағдарламалау тілі және Flutter фреймворкі туралы жалпы мәлімет",
    "2 АРНАЙЫ БӨЛІМ",
    "2.1.1 Кіріс және шығыс деректері",
    "3 ӨНДІРІСТІ ҰЙЫМДАСТЫРУ",
    "3.2 Пайдаланушы нұсқаулығы",
    "3.2.1 Авторизация және тіркелу терезелері",
    "3.2.10 Пайдаланушы баптаулары мен тақырып таңдау",
    "3.5 Деректер қоры кестелерінің құрылымы"
]

# Headings to verify in page 2
headings_2 = [
    "4 ЭКОНОМИКАЛЫҚ БӨЛІМ",
    "4.1 Экономикалық бөлімге кіріспе",
    "5 ЕҢБЕКТІ ҚОРҒАУ",
    "5.1 Қазақстан Республикасының еңбекті қорғау саласындағы заңнамалық және нормативтік-құқықтық негіздері",
    "5.2 Еңбек және демалыс режимдерін нормалау",
    "5.11 Өнеркәсіптік жарықтандыру",
    "ҚОРЫТЫНДЫ",
    "ҚОСЫМША А – Жоба листингі",
    "ҚОЛДАНЫЛҒАН ӘДЕБИЕТТЕР ТІЗІМІ"
]

dest_dir = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка"
v1 = verify_file(os.path.join(dest_dir, "Мазмұны.docx"), headings_1, "МАЗМҰНЫ")
v2 = verify_file(os.path.join(dest_dir, "Мазмұны 2.docx"), headings_2)

if v1 and v2:
    print("\nALL VERIFICATIONS PASSED SUCCESSFULLY!")
    sys.exit(0)
else:
    print("\nVERIFICATION FAILED FOR ONE OR BOTH FILES.")
    sys.exit(1)
