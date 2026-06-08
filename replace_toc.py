import zipfile
import xml.etree.ElementTree as ET
import os
import sys
import shutil
import copy

sys.stdout.reconfigure(encoding='utf-8')

template_path = r"C:\Users\admin\OneDrive\Рабочий стол\А.А.Дипломка\Диплом Абдыкадыр.А\Мазмұны.docx"
dest_dir = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка"
dest_path = os.path.join(dest_dir, "Мазмұны.docx")

if not os.path.exists(dest_dir):
    os.makedirs(dest_dir)

# 1. Copy template to destination
print(f"Copying template from {template_path} to {dest_path}...")
shutil.copy2(template_path, dest_path)

# Namespaces
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
ET.register_namespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')

def format_para_in_cell(p, text, align="left"):
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

def copy_row_with_text(base_row, text0, text1):
    new_row = copy.deepcopy(base_row)
    cells = new_row.findall('.//w:tc', ns)
    
    # Format Cell 0
    cell0_ps = cells[0].findall('.//w:p', ns)
    for p in cell0_ps[1:]:
        cells[0].remove(p)
    format_para_in_cell(cell0_ps[0], text0, align="left")
    
    # Format Cell 1
    cell1_ps = cells[1].findall('.//w:p', ns)
    for p in cell1_ps[1:]:
        cells[1].remove(p)
    format_para_in_cell(cell1_ps[0], text1, align="right")
    
    return new_row

# Mappings of Row index to (Cell0_text, Cell1_text)
# For simple 1-paragraph rows
simple_rows = {
    1: ("Кіріспе", " 8"),
    2: ("1 ЖАЛПЫ БӨЛІМ", "10"),
    3: ("1.1 Жобаның өзектілігі", "10"),
    4: ("1.2 Деректерді сақтау және өңдеу технологиялары", "11"),
    5: ("1.3 Бағдарламалау құралдарының сипаттамасы", "12"),
    6: ("1.3.1 Dart бағдарламалау тілі және Flutter фреймворкі туралы жалпы мәлімет", "12"),
    7: ("1.3.2 Dart тілінің негізгі элементтері", "13"),
    8: ("1.3.3 Бағдарламаны құрылымдау тәсілдері", "14"),
    9: ("1.3.4 Деректерді сақтау және алмасу құралдары", "15"),
    10: ("1.3.5 Flutter фреймворкінің кіріктірілген компоненттері", "15"),
    11: ("2 АРНАЙЫ БӨЛІМ", "17"),
    12: ("2.1 Жобаның жалпы қойылымы", "17"),
    13: ("2.1.1 Кіріс және шығыс деректері", "18"),
    14: ("2.1.2 Кешеннің жұмыс схемасы", "20"),
    15: ("2.1.3 Бағдарламалық кешен сипаттамасы", "20"),
    16: ("2.1.4 Деректер қорының құрылымы", "21"),
    17: ("2.2 Проблемалық бағдарламаның сипаттамасы", "21"),
    18: ("2.2.1 Бағдарлама алгоритмінің блок-схемасы", "22"),
    19: ("2.2.2 Идентификаторлар кестесі", "24"),
    20: ("3 ӨНДІРІСТІ ҰЙЫМДАСТЫРУ", "25"),
    21: ("3.1 Жобаны орындау шарттары", "25"),
    23: ("3.3 Жүйелік және пайдаланушылық шектеулерді тестілеу", "36"),
    24: ("3.4 Кіріс және шығыс құжаттарының формалары", "37"),
}

# Row 22 multiline items
row22_headings = [
    "3.2 Пайдаланушы нұсқаулығы",
    "3.2.1 Авторизация және тіркелу терезелері",
    "3.2.2 Басты TrackerPage терезесімен жұмыс істеу",
    "3.2.3 Ұйқыға кету терезесі",
    "3.2.4 Дыбыс датчигі және жазбалар терезесі",
    "3.2.5 Ұйқыдан кейінгі күйді бағалау панелі",
    "3.2.6 Динамикалық ұйқы кеңестері",
    "3.2.7 Ұйқыны бақылау алгоритмі мен терезелері",
    "3.2.8 Пайдаланушы профилі",
    "3.2.9 Ұйқы статистикасы мен графиктер",
    "3.2.10 Пайдаланушы баптаулары мен тақырып таңдау"
]

row22_pages = [
    "26", "26", "28", "28", "29", "30", "31", "32", "33", "34", "35"
]

try:
    temp_backup = dest_path + ".tmp"
    shutil.copy2(dest_path, temp_backup)
    
    with zipfile.ZipFile(temp_backup, 'r') as docx_in:
        xml_content = docx_in.read('word/document.xml')
        root = ET.fromstring(xml_content)
        
        # Heading paragraph (not inside table)
        paragraphs = root.findall('.//w:p', ns)
        # Verify page heading P0
        format_para_in_cell(paragraphs[0], "МАЗМҰНЫ", align="center")
        
        # Locate table
        tables = root.findall('.//w:tbl', ns)
        table = tables[0]
        rows = table.findall('.//w:tr', ns)
        
        # Update simple rows
        for idx, (h_text, p_text) in simple_rows.items():
            row = rows[idx]
            cells = row.findall('.//w:tc', ns)
            format_para_in_cell(cells[0].find('w:p', ns), h_text, align="left")
            format_para_in_cell(cells[1].find('w:p', ns), p_text, align="right")
            
        # Update Row 22 (Section 3.2)
        row22 = rows[22]
        cells22 = row22.findall('.//w:tc', ns)
        
        # Setup paragraphs for Cell 0
        cell0 = cells22[0]
        c0_ps = cell0.findall('.//w:p', ns)
        while len(c0_ps) < len(row22_headings):
            # Create a new empty paragraph copying properties from first
            new_p = copy.deepcopy(c0_ps[0])
            cell0.append(new_p)
            c0_ps.append(new_p)
        while len(c0_ps) > len(row22_headings):
            cell0.remove(c0_ps[-1])
            c0_ps.pop()
        for i, text in enumerate(row22_headings):
            format_para_in_cell(c0_ps[i], text, align="left")
            
        # Setup paragraphs for Cell 1
        cell1 = cells22[1]
        c1_ps = cell1.findall('.//w:p', ns)
        while len(c1_ps) < len(row22_pages):
            new_p = copy.deepcopy(c1_ps[0])
            cell1.append(new_p)
            c1_ps.append(new_p)
        while len(c1_ps) > len(row22_pages):
            cell1.remove(c1_ps[-1])
            c1_ps.pop()
        for i, text in enumerate(row22_pages):
            format_para_in_cell(c1_ps[i], text, align="right")

        # Update Row 25 (Section 3.5)
        row25 = rows[25]
        cells25 = row25.findall('.//w:tc', ns)
        # Clear extra paragraphs in Cell 0
        c25_0_ps = cells25[0].findall('.//w:p', ns)
        for p in c25_0_ps[1:]:
            cells25[0].remove(p)
        format_para_in_cell(c25_0_ps[0], "3.5 Деректер қоры кестелерінің құрылымы", align="left")
        
        # Clear extra paragraphs in Cell 1
        c25_1_ps = cells25[1].findall('.//w:p', ns)
        for p in c25_1_ps[1:]:
            cells25[1].remove(p)
        format_para_in_cell(c25_1_ps[0], "38", align="right")

        # Add the concluding rows (Conclusion, References, Appendix A) by duplicating Row 23
        base_row = rows[23]
        
        row_conclusion = copy_row_with_text(base_row, "Қорытынды", "39")
        row_references = copy_row_with_text(base_row, "Пайдаланылған әдебиеттер тізімі", "40")
        row_appendix = copy_row_with_text(base_row, "Қосымша А", "41")
        
        table.append(row_conclusion)
        table.append(row_references)
        table.append(row_appendix)
        
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
    print("Table of Contents successfully created and styled!")
except Exception as e:
    print(f"Error: {e}")
    if os.path.exists(temp_backup):
        os.remove(temp_backup)
    sys.exit(1)
