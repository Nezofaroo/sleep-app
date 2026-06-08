import zipfile
import xml.etree.ElementTree as ET
import sys
import os

sys.stdout.reconfigure(encoding='utf-8')

# Note: The filename contains a combining Cyrillic 'и' and 'й' character (u\u0306), so let's list the downloads folder first to find the exact filename.
downloads_dir = r"C:\Users\admin\Favorites\Downloads"
found_file = None
for f in os.listdir(downloads_dir):
    if "өндірісті" in f.lower() and f.endswith(".docx"):
        found_file = os.path.join(downloads_dir, f)
        break

if not found_file:
    print("No file found in Downloads.")
    sys.exit(1)

print(f"Inspecting file: {found_file}")
try:
    with zipfile.ZipFile(found_file, 'r') as docx:
        xml_content = docx.read('word/document.xml')
        root = ET.fromstring(xml_content)
        ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
        paragraphs = root.findall('.//w:p', ns)
        print(f"Total paragraphs: {len(paragraphs)}")
        for idx in range(min(40, len(paragraphs))):
            p = paragraphs[idx]
            text_runs = p.findall('.//w:t', ns)
            text = "".join([run.text for run in text_runs if run.text])
            has_drawing = p.find('.//w:drawing', ns) is not None
            drawing_str = " [HAS_DRAWING]" if has_drawing else ""
            if text.strip() or has_drawing:
                print(f"P{idx}: {text}{drawing_str}")
except Exception as e:
    print(f"Error: {e}")
