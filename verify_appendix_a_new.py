import zipfile
import xml.etree.ElementTree as ET
import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
dest_docx = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Қосымша А.docx"

def verify():
    print(f"Verifying {dest_docx}...")
    if not os.path.exists(dest_docx):
        print("Error: Target file does not exist!")
        sys.exit(1)
        
    errors = 0
    with zipfile.ZipFile(dest_docx, 'r') as docx:
        xml_content = docx.read('word/document.xml')
        root = ET.fromstring(xml_content)
        
        # 1. Check title
        paragraphs = root.findall('.//w:p', ns)
        print(f"Total paragraphs in generated file: {len(paragraphs)}")
        if len(paragraphs) != 18:
            print(f"FAILED: Found {len(paragraphs)} paragraphs, expected 18")
            errors += 1
            
        title_text = "".join([r.text for r in paragraphs[0].findall('.//w:t', ns) if r.text]).strip()
        if title_text == "Қосымша А":
            print("PASSED: Title is 'Қосымша А'")
        else:
            print(f"FAILED: Title is '{title_text}', expected 'Қосымша А'")
            errors += 1
            
        subtitle_text = "".join([r.text for r in paragraphs[3].findall('.//w:t', ns) if r.text]).strip()
        if subtitle_text == "Бағдарламалық кодтың листингтері":
            print("PASSED: Subtitle is 'Бағдарламалық кодтың листингтері'")
        else:
            print(f"FAILED: Subtitle is '{subtitle_text}', expected 'Бағдарламалық кодтың листингтері'")
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
                            
        # 4. Check that files are written
        full_text = ""
        for t in root.findall('.//w:t', ns):
            if t.text:
                full_text += t.text + " "
                
        expected_files = [
            "main.dart", "database_helper.dart", "sleep_record.dart", 
            "sound_event.dart", "background_service_init.dart", "sleep_audio_trigger_service.dart"
        ]
        for f in expected_files:
            if f in full_text:
                print(f"PASSED: Found code file '{f}' in document.")
            else:
                print(f"FAILED: Code file '{f}' NOT found in document!")
                errors += 1
                
        # 5. Check if there are no old Kotlin files
        kotlin_files = ["LoginActivity", "QuizFragment", "MatchPairsFragment", "MyTranslatorFragment", "ProfileFragment", "FirestoreManager", "FirebaseWord", "SharedPrefsManager"]
        for kf in kotlin_files:
            if kf in full_text:
                print(f"FAILED: Found Kotlin file '{kf}' in document!")
                errors += 1
            else:
                pass
        print("PASSED: Checked that no Kotlin files remain.")

    if errors == 0:
        print("ALL VERIFICATIONS PASSED SUCCESSFULLY!")
        sys.exit(0)
    else:
        print(f"VERIFICATION FAILED WITH {errors} ERRORS.")
        sys.exit(1)

if __name__ == "__main__":
    verify()
