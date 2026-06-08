import zipfile
import xml.etree.ElementTree as ET
import os
import sys
import shutil

sys.stdout.reconfigure(encoding='utf-8')

template_path = r"C:\Users\admin\OneDrive\Рабочий стол\А.А.Дипломка\Диплом Абдыкадыр.А\Қосымша А.docx"
dest_dir = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка"
dest_path = os.path.join(dest_dir, "Қосымша А.docx")

if not os.path.exists(dest_dir):
    os.makedirs(dest_dir)

# 1. Copy template to destination
print(f"Copying template from {template_path} to {dest_path}...")
shutil.copy2(template_path, dest_path)

# List of source files
src_files = [
    {
        "name": "login_page.dart",
        "path": r"c:\Android\AndroidStudioProjects\sleep_tracker_app\lib\pages\login_page.dart"
    },
    {
        "name": "register_page.dart",
        "path": r"c:\Android\AndroidStudioProjects\sleep_tracker_app\lib\pages\register_page.dart"
    },
    {
        "name": "tracker_page.dart",
        "path": r"c:\Android\AndroidStudioProjects\sleep_tracker_app\lib\pages\tracker_page.dart"
    },
    {
        "name": "statistics_page.dart",
        "path": r"c:\Android\AndroidStudioProjects\sleep_tracker_app\lib\pages\statistics_page.dart"
    },
    {
        "name": "profile_page.dart",
        "path": r"c:\Android\AndroidStudioProjects\sleep_tracker_app\lib\pages\profile_page.dart"
    },
    {
        "name": "database_helper.dart",
        "path": r"c:\Android\AndroidStudioProjects\sleep_tracker_app\lib\database\database_helper.dart"
    },
    {
        "name": "sleep_record.dart",
        "path": r"c:\Android\AndroidStudioProjects\sleep_tracker_app\lib\models\sleep_record.dart"
    },
    {
        "name": "background_service_init.dart",
        "path": r"c:\Android\AndroidStudioProjects\sleep_tracker_app\lib\services\background_service_init.dart"
    }
]

# Namespaces
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
ET.register_namespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')

def format_code_paragraph(p, file_path, file_name):
    # Read file code lines
    print(f"Reading code from: {file_path}")
    if not os.path.exists(file_path):
        print(f"Warning: File {file_path} not found!")
        code_lines = [f"// File {file_name} not found"]
    else:
        with open(file_path, 'r', encoding='utf-8') as f:
            code_lines = [line.rstrip('\r\n') for line in f.readlines()]

    # Save pPr
    pPr = p.find('w:pPr', ns)
    p.clear()
    
    if pPr is not None:
        p.append(pPr)
    else:
        pPr = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}pPr')
        p.append(pPr)

    # Indentation and alignment for code
    ind = pPr.find('w:ind', ns)
    if ind is None:
        ind = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}ind')
        pPr.append(ind)
    ind.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}left', '284')
    ind.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}firstLine', '709')

    jc = pPr.find('w:jc', ns)
    if jc is None:
        jc = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}jc')
        pPr.append(jc)
    jc.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', 'both')

    # Create run
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

    # Add text and breaks
    first = True
    for line in code_lines:
        if not first:
            br = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}br')
            run.append(br)
        else:
            first = False
        
        t = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t')
        # Preserve whitespace in XML
        t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
        t.text = line
        run.append(t)
        
    p.append(run)

def format_title_paragraph(p, text, align="center"):
    # Save pPr
    pPr = p.find('w:pPr', ns)
    p.clear()
    
    if pPr is not None:
        p.append(pPr)
    else:
        pPr = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}pPr')
        p.append(pPr)

    ind = pPr.find('w:ind', ns)
    if ind is None:
        ind = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}ind')
        pPr.append(ind)
    ind.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}left', '284')
    ind.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}firstLine', '709')

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
    # We read from dest_path (copied template) to avoid read-write conflicts
    temp_backup = dest_path + ".tmp"
    shutil.copy2(dest_path, temp_backup)
    
    with zipfile.ZipFile(temp_backup, 'r') as docx_in:
        xml_content = docx_in.read('word/document.xml')
        root = ET.fromstring(xml_content)
        
        paragraphs = root.findall('.//w:p', ns)
        print(f"Total paragraphs in document: {len(paragraphs)}")
        
        # Replace Paragraph 0: Heading
        format_title_paragraph(paragraphs[0], "Қосымша А", align="center")
        
        # Replace Paragraph 3: Subheading
        format_title_paragraph(paragraphs[3], "Бағдарламалық кодтың листингтері", align="center")
        
        # Replace the 8 code files
        # File 1: LoginActivity -> login_page.dart (P6 name, P7 code)
        format_title_paragraph(paragraphs[6], "login_page.dart", align="center")
        format_code_paragraph(paragraphs[7], src_files[0]["path"], src_files[0]["name"])
        
        # File 2: QuizFragment -> register_page.dart (P8 name, P9 code)
        format_title_paragraph(paragraphs[8], "register_page.dart", align="center")
        format_code_paragraph(paragraphs[9], src_files[1]["path"], src_files[1]["name"])
        
        # File 3: MatchPairsFragment -> tracker_page.dart (P10 name, P11 code)
        format_title_paragraph(paragraphs[10], "tracker_page.dart", align="center")
        format_code_paragraph(paragraphs[11], src_files[2]["path"], src_files[2]["name"])
        
        # File 4: MyTranslatorFragment -> statistics_page.dart (P12 name, P13 code)
        format_title_paragraph(paragraphs[12], "statistics_page.dart", align="center")
        format_code_paragraph(paragraphs[13], src_files[3]["path"], src_files[3]["name"])
        
        # File 5: ProfileFragment -> profile_page.dart (P14 name, P15 code)
        format_title_paragraph(paragraphs[14], "profile_page.dart", align="center")
        format_code_paragraph(paragraphs[15], src_files[4]["path"], src_files[4]["name"])
        
        # File 6: FirestoreManager -> database_helper.dart (P16 name, P17 code)
        format_title_paragraph(paragraphs[16], "database_helper.dart", align="center")
        format_code_paragraph(paragraphs[17], src_files[5]["path"], src_files[5]["name"])
        
        # File 7: FirebaseWord -> sleep_record.dart (P18 name, P19 code)
        format_title_paragraph(paragraphs[18], "sleep_record.dart", align="center")
        format_code_paragraph(paragraphs[19], src_files[6]["path"], src_files[6]["name"])
        
        # File 8: SharedPrefsManager -> background_service_init.dart (P20 name, P21 code)
        format_title_paragraph(paragraphs[20], "background_service_init.dart", align="center")
        format_code_paragraph(paragraphs[21], src_files[7]["path"], src_files[7]["name"])

        # Global styling removal (completely strip bold/italic tags)
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
                    
    # Remove temp backup
    os.remove(temp_backup)
    print("Appendix A successfully created and styled!")
except Exception as e:
    print(f"Error: {e}")
    if os.path.exists(temp_backup):
        os.remove(temp_backup)
    sys.exit(1)
