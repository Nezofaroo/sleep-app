import zipfile
import xml.etree.ElementTree as ET
import os
import sys
import shutil

sys.stdout.reconfigure(encoding='utf-8')

template_path = r"C:\Users\admin\OneDrive\Рабочий стол\А.А.Дипломка\Диплом Абдыкадыр.А\Қосымша.docx"
dest_dir = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка"
dest_path = os.path.join(dest_dir, "Қосымша.docx")

print(f"Restoring template from {template_path} to {dest_path}...")
shutil.copy2(template_path, dest_path)

ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
ET.register_namespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')

def format_paragraph(p, text, align="center"):
    # Save pPr
    pPr = p.find('w:pPr', ns)
    p.clear()
    
    if pPr is not None:
        p.append(pPr)
    else:
        pPr = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}pPr')
        p.append(pPr)

    jc = pPr.find('w:jc', ns)
    if jc is None:
        jc = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}jc')
        pPr.append(jc)
    jc.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', align)

    run = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}r')
    rPr = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rPr')
    
    sz = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}sz')
    sz.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', '28')
    szCs = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}szCs')
    szCs.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', '28')
    
    rFonts = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rFonts')
    rFonts.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}ascii', 'Times New Roman')
    rFonts.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}hAnsi', 'Times New Roman')
    rFonts.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}cs', 'Times New Roman')
    
    lang = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}lang')
    lang.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', 'kk-KZ')
    
    rPr.append(sz)
    rPr.append(szCs)
    rPr.append(rFonts)
    rPr.append(lang)
    run.append(rPr)

    t = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t')
    t.text = text
    run.append(t)
    p.append(run)

try:
    temp_backup = dest_path + ".tmp"
    shutil.copy2(dest_path, temp_backup)
    
    with zipfile.ZipFile(temp_backup, 'r') as docx_in:
        xml_content = docx_in.read('word/document.xml')
        root = ET.fromstring(xml_content)
        
        paragraphs = root.findall('.//w:p', ns)
        print(f"Total paragraphs in document: {len(paragraphs)}")
        
        # Format paragraph 11 (which contains the text "ҚОСЫМША")
        # In the original file it is "ҚОСЫМША", let's keep it centered, size 14, Times New Roman, regular.
        format_paragraph(paragraphs[11], "ҚОСЫМША", align="center")
        
        # Global Tree Sweep to completely remove ALL bold/italic formatting tags
        parent_map = {c: p for p in root.iter() for c in p}
        tags_to_remove = [
            '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}b',
            '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}bCs',
            '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}i',
            '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}iCs'
        ]
        removed_count = 0
        for elem in list(parent_map.keys()):
            if elem.tag in tags_to_remove:
                parent = parent_map[elem]
                if parent is not None:
                    try:
                        parent.remove(elem)
                        removed_count += 1
                    except ValueError:
                        pass
        print(f"Removed {removed_count} bold/italic tags globally.")

        modified_xml = ET.tostring(root, encoding='utf-8')
        
        # Write modified zip back
        print(f"Writing changes to {dest_path}...")
        with zipfile.ZipFile(dest_path, 'w', zipfile.ZIP_DEFLATED) as docx_out:
            for item in docx_in.infolist():
                if item.filename == 'word/document.xml':
                    docx_out.writestr(item, modified_xml)
                else:
                    docx_out.writestr(item, docx_in.read(item.filename))
                    
    os.remove(temp_backup)
    print("Appendix cover page successfully restored and styled!")
except Exception as e:
    print(f"Error: {e}")
    if os.path.exists(temp_backup):
        os.remove(temp_backup)
    sys.exit(1)
