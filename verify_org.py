import zipfile
import xml.etree.ElementTree as ET
import os
import sys

# Reconfigure stdout for Kazakh encoding
sys.stdout.reconfigure(encoding='utf-8')

dest_docx = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Өндірісті ұйымдастыру.docx"

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
            
        # Firebase should not be in table descriptions (e.g. Firebase Word, Firebase Vocabulary)
        # Wait, Firebase Auth is okay if it's auth/cloud sync, but let's check:
        # Since they wanted Hive and SQLite, let's verify if "Firebase Firestore" is gone.
        if "firebase firestore" in full_text.lower():
            print("FAILED: 'Firebase Firestore' is still found in the document text!")
            errors += 1
        else:
            print("PASSED: 'Firebase Firestore' is completely removed.")
            
        # Sleep.ly should be in text
        if "sleep.ly" in full_text.lower():
            print("PASSED: 'Sleep.ly' is found in the document text.")
        else:
            print("FAILED: 'Sleep.ly' is NOT found in the document text!")
            errors += 1
            
        # Flutter should be in text
        if "flutter" in full_text.lower():
            print("PASSED: 'Flutter' is found in the document text.")
        else:
            print("FAILED: 'Flutter' is NOT found in the document text!")
            errors += 1
            
        # Hive should be in text
        if "hive" in full_text.lower():
            print("PASSED: 'Hive' is found in the document text.")
        else:
            print("FAILED: 'Hive' is NOT found in the document text!")
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
            
        # 3. Check that drawings (images) are still present
        drawings = root.findall('.//w:drawing', ns)
        print(f"Total drawings found: {len(drawings)}")
        if len(drawings) > 0:
            print(f"PASSED: Drawings (images) are preserved (found {len(drawings)} drawings).")
        else:
            print("FAILED: Drawings (images) were NOT found or were removed!")
            errors += 1
            
    if errors == 0:
        print("ALL VERIFICATIONS PASSED SUCCESSFULLY!")
        sys.exit(0)
    else:
        print(f"VERIFICATION FAILED WITH {errors} ERRORS.")
        sys.exit(1)

if __name__ == "__main__":
    verify()
