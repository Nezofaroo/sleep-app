import zipfile
import xml.etree.ElementTree as ET
import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
docx_path = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Қолданылған әдебиеттер тізімі.docx"

def verify():
    print(f"Verifying {os.path.basename(docx_path)}...")
    if not os.path.exists(docx_path):
        print("Error: Target file does not exist!")
        sys.exit(1)
        
    errors = 0
    with zipfile.ZipFile(docx_path, 'r') as docx:
        xml_content = docx.read('word/document.xml')
        root = ET.fromstring(xml_content)
        
        # 1. Check title
        paragraphs = root.findall('.//w:p', ns)
        title_text = "".join([r.text for r in paragraphs[2].findall('.//w:t', ns) if r.text]).strip()
        if title_text == "ҚОЛДАНЫЛҒАН ӘДЕБИЕТТЕР ТІЗІМІ":
            print("PASSED: Heading is correct.")
        else:
            print(f"FAILED: Heading is '{title_text}', expected 'ҚОЛДАНЫЛҒАН ӘДЕБИЕТТЕР ТІЗІМІ'")
            errors += 1
            
        # 2. Check for Bold/Italic formatting tags
        bold_tags = (root.findall('.//w:pPr/w:b', ns) + 
                     root.findall('.//w:pPr/w:bCs', ns) + 
                     root.findall('.//w:rPr/w:b', ns) + 
                     root.findall('.//w:rPr/w:bCs', ns))
        italic_tags = (root.findall('.//w:pPr/w:i', ns) + 
                       root.findall('.//w:pPr/w:iCs', ns) + 
                       root.findall('.//w:rPr/w:i', ns) + 
                       root.findall('.//w:rPr/w:iCs', ns))
        
        if len(bold_tags) > 0:
            print(f"FAILED: Found {len(bold_tags)} bold formatting tags in document XML!")
            errors += 1
        else:
            print("PASSED: No bold tags found in the document.")
            
        if len(italic_tags) > 0:
            print(f"FAILED: Found {len(italic_tags)} italic formatting tags in document XML!")
            errors += 1
        else:
            print("PASSED: No italic tags found in the document.")
            
        # 3. Check font and size of runs
        for idx, p in enumerate(paragraphs):
            runs = p.findall('.//w:r', ns)
            for r in runs:
                rPr = r.find('w:rPr', ns)
                if rPr is not None:
                    sz = rPr.find('w:sz', ns)
                    szCs = rPr.find('w:szCs', ns)
                    rFonts = rPr.find('w:rFonts', ns)
                    
                    if sz is not None and sz.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val') != '28':
                        print(f"FAILED: P{idx} run size is {sz.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val')}, expected 28")
                        errors += 1
                    if rFonts is not None:
                        ascii_font = rFonts.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}ascii')
                        if ascii_font != 'Times New Roman':
                            print(f"FAILED: P{idx} run font is '{ascii_font}', expected 'Times New Roman'")
                            errors += 1
                            
        # 4. Check for leaks/old references
        full_text = ""
        for t in root.findall('.//w:t', ns):
            if t.text:
                full_text += t.text + " "
                
        if "kotlin" in full_text.lower():
            print("FAILED: 'Kotlin' is still found in bibliography!")
            errors += 1
        else:
            print("PASSED: 'Kotlin' references are gone.")
            
        if "firebase" in full_text.lower() and "authentication" in full_text.lower():
            # Wait, our new references don't have Firebase Authentication, let's verify
            print("FAILED: Firebase Authentication is still found in bibliography!")
            errors += 1
        else:
            print("PASSED: Firebase Authentication is gone.")
            
        if "flutter" in full_text.lower():
            print("PASSED: 'Flutter' is found in bibliography.")
        else:
            print("FAILED: 'Flutter' is NOT found in bibliography!")
            errors += 1
            
        if "hive" in full_text.lower():
            print("PASSED: 'Hive' is found in bibliography.")
        else:
            print("FAILED: 'Hive' is NOT found in bibliography!")
            errors += 1

    if errors == 0:
        print("ALL VERIFICATIONS PASSED SUCCESSFULLY!")
        sys.exit(0)
    else:
        print(f"VERIFICATION FAILED WITH {errors} ERRORS.")
        sys.exit(1)

if __name__ == "__main__":
    verify()
