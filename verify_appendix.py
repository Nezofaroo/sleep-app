import zipfile
import xml.etree.ElementTree as ET
import sys
import os

sys.stdout.reconfigure(encoding='utf-8')

dest_docx = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Қосымша А.docx"

ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}

def verify():
    print(f"Verifying {dest_docx}...")
    if not os.path.exists(dest_docx):
        print("Error: Target file does not exist!")
        sys.exit(1)
        
    errors = 0
    with zipfile.ZipFile(dest_docx, 'r') as docx:
        xml_content = docx.read('word/document.xml')
        root = ET.fromstring(xml_content)
        
        # 1. Check text content
        full_text = ""
        for t in root.findall('.//w:t', ns):
            if t.text:
                full_text += t.text + " "
                
        # Linguaphile should not be in text
        if "linguaphile" in full_text.lower():
            print("FAILED: 'Linguaphile' is still found in the document text!")
            errors += 1
        else:
            print("PASSED: 'Linguaphile' is completely removed.")
            
        # Kotlin should not be in text
        if "kotlin" in full_text.lower():
            print("FAILED: 'Kotlin' is still found in the document text!")
            errors += 1
        else:
            print("PASSED: 'Kotlin' is completely removed.")
            
        # Sleep.ly should be in text (e.g. from comments or imports if any, but wait, let's check:
        # if our files have 'sleep_tracker_app', that's fine.
            
        # Check files
        expected_files = [
            "login_page.dart", "register_page.dart", "tracker_page.dart", 
            "statistics_page.dart", "profile_page.dart", "database_helper.dart", 
            "sleep_record.dart", "background_service_init.dart"
        ]
        for f_name in expected_files:
            if f_name in full_text:
                print(f"PASSED: '{f_name}' heading found in document.")
            else:
                print(f"FAILED: '{f_name}' heading NOT found in document!")
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
        
        if bold_tags:
            print(f"FAILED: Found {len(bold_tags)} bold formatting tags in document XML!")
            errors += 1
        else:
            print("PASSED: No bold tags found in the document.")
            
        if italic_tags:
            print(f"FAILED: Found {len(italic_tags)} italic formatting tags in document XML!")
            errors += 1
        else:
            print("PASSED: No italic tags found in the document.")
            
    if errors == 0:
        print("ALL VERIFICATIONS PASSED SUCCESSFULLY!")
        sys.exit(0)
    else:
        print(f"VERIFICATION FAILED WITH {errors} ERRORS.")
        sys.exit(1)

if __name__ == "__main__":
    verify()
