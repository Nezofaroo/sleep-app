import zipfile
import xml.etree.ElementTree as ET
import os
import sys
import shutil
import copy

sys.stdout.reconfigure(encoding='utf-8')

# Paths
src_dir = r"C:\Users\admin\OneDrive\Рабочий стол\А.А.Дипломка\Диплом Абдыкадыр.А"
dest_dir = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка"

# Namespace
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

def strip_bold_italic_globally(root):
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
    return removed_count

# -------------------------------------------------------------
# Part 1: Мазмұны.docx
# -------------------------------------------------------------
def process_toc_page_1():
    template_path = os.path.join(src_dir, "Мазмұны.docx")
    dest_path = os.path.join(dest_dir, "Мазмұны.docx")
    
    print(f"\nProcessing {os.path.basename(template_path)}...")
    if not os.path.exists(template_path):
        print(f"Error: {template_path} not found!")
        return False
        
    shutil.copy2(template_path, dest_path)
    temp_backup = dest_path + ".tmp"
    shutil.copy2(dest_path, temp_backup)
    
    simple_rows_1 = {
        0: ("", "бет"),
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
        with zipfile.ZipFile(temp_backup, 'r') as docx_in:
            xml_content = docx_in.read('word/document.xml')
            root = ET.fromstring(xml_content)
            
            # Update heading P0
            paragraphs = root.findall('.//w:p', ns)
            format_para_in_cell(paragraphs[0], "МАЗМҰНЫ", align="center")
            
            # Locate table
            tables = root.findall('.//w:tbl', ns)
            table = tables[0]
            rows = table.findall('.//w:tr', ns)
            print(f"Table rows in template page 1: {len(rows)}")
            
            # 1. Update simple rows
            for idx, (h_text, p_text) in simple_rows_1.items():
                row = rows[idx]
                cells = row.findall('.//w:tc', ns)
                format_para_in_cell(cells[0].find('w:p', ns), h_text, align="left")
                format_para_in_cell(cells[1].find('w:p', ns), p_text, align="right")
                
            # 2. Update Row 22 (Section 3.2 multi-paragraph)
            row22 = rows[22]
            cells22 = row22.findall('.//w:tc', ns)
            
            # Cell 0
            cell0 = cells22[0]
            c0_ps = cell0.findall('.//w:p', ns)
            while len(c0_ps) < len(row22_headings):
                new_p = copy.deepcopy(c0_ps[0])
                cell0.append(new_p)
                c0_ps.append(new_p)
            while len(c0_ps) > len(row22_headings):
                cell0.remove(c0_ps[-1])
                c0_ps.pop()
            for i, text in enumerate(row22_headings):
                format_para_in_cell(c0_ps[i], text, align="left")
                
            # Cell 1
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
                
            # 3. Update Row 25 (Section 3.5)
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
            
            # Clear all bold/italic styling
            removed_count = strip_bold_italic_globally(root)
            print(f"Removed {removed_count} bold/italic tags from Page 1.")
            
            modified_xml = ET.tostring(root, encoding='utf-8')
            
            # Write back
            with zipfile.ZipFile(dest_path, 'w', zipfile.ZIP_DEFLATED) as docx_out:
                for item in docx_in.infolist():
                    if item.filename == 'word/document.xml':
                        docx_out.writestr(item, modified_xml)
                    else:
                        docx_out.writestr(item, docx_in.read(item.filename))
                        
        os.remove(temp_backup)
        print("Page 1 processed successfully.")
        return True
    except Exception as e:
        print(f"Error on Page 1: {e}")
        if os.path.exists(temp_backup):
            os.remove(temp_backup)
        return False

# -------------------------------------------------------------
# Part 2: Мазмұны 2.docx
# -------------------------------------------------------------
def process_toc_page_2():
    template_path = os.path.join(src_dir, "Мазмұны 2.docx")
    dest_path = os.path.join(dest_dir, "Мазмұны 2.docx")
    
    print(f"\nProcessing {os.path.basename(template_path)}...")
    if not os.path.exists(template_path):
        print(f"Error: {template_path} not found!")
        return False
        
    shutil.copy2(template_path, dest_path)
    temp_backup = dest_path + ".tmp"
    shutil.copy2(dest_path, temp_backup)
    
    simple_rows_2 = {
        0: ("4 ЭКОНОМИКАЛЫҚ БӨЛІМ", "39"),
        1: ("4.1 Экономикалық бөлімге кіріспе", "39"),
        2: ("4.2 Жұмыста пайдаланылатын еңбек ресурстары", "39"),
        3: ("4.3 Әзірлеу кезінде пайдаланылған техникалық жабдық", "40"),
        5: ("5 ЕҢБЕКТІ ҚОРҒАУ", "54"),
        6: ("5.1 Қазақстан Республикасының еңбекті қорғау саласындағы заңнамалық және нормативтік-құқықтық негіздері", "54"),
        7: ("5.2 Еңбек және демалыс режимдерін нормалау", "56"),
        8: ("5.3 Электр қауіпсіздігі және электр тогынан қорғану құралдары", "58"),
        10: ("ҚОРЫТЫНДЫ", "71"),
        11: ("ҚОСЫМША", "72"),
        12: ("ҚОСЫМША А – Жоба листингі", "73"),
        13: ("ҚОСЫМША Б – Кіріс деректері", "133"),
        15: ("ҚОЛДАНЫЛҒАН ӘДЕБИЕТТЕР ТІЗІМІ", "142"),
    }
    
    row4_headings = [
        "4.4 Әзірлеу бойынша жұмыс құнын есептеу",
        "4.5 Бағдарламалық өнімнің экономикалық тиімділігін есептеу",
        "4.6 Қорытынды"
    ]
    row4_pages = [
        "41", "49", "52"
    ]
    
    row9_headings = [
        "5.4 Қауіпті және зиянды өндірістік факторлардың мониторингі",
        "5.5 Ғимараттағы өрттің алдын алу және қорғаныс жүйелері",
        "5.6 Эвакуациялау процесін ұйымдастыру және авариялық жоспарлау",
        "5.7 Еңбекті қорғауды басқарудың ішкі жүйесі және бақылау",
        "5.9 Жұмыс орнындағы электр қауіпсіздігі",
        "5.10 Қоршаған ортаны қорғау",
        "5.11 Өнеркәсіптік жарықтандыру"
    ]
    row9_pages = [
        "60", "62", "64", "66", "68", "69", "70"
    ]
    
    row14_headings = [
        "ҚОСЫМША В – Шығыс деректері",
        "ҚОСЫМША Г – Бағдарламалық кешеннің жұмыс істеу сызбасы"
    ]
    row14_pages = [
        "136", "141"
    ]
    
    try:
        with zipfile.ZipFile(temp_backup, 'r') as docx_in:
            xml_content = docx_in.read('word/document.xml')
            root = ET.fromstring(xml_content)
            
            # Locate table
            tables = root.findall('.//w:tbl', ns)
            table = tables[0]
            rows = table.findall('.//w:tr', ns)
            print(f"Table rows in template page 2: {len(rows)}")
            
            # 1. Update simple rows
            for idx, (h_text, p_text) in simple_rows_2.items():
                row = rows[idx]
                cells = row.findall('.//w:tc', ns)
                format_para_in_cell(cells[0].find('w:p', ns), h_text, align="left")
                format_para_in_cell(cells[1].find('w:p', ns), p_text, align="right")
                
            # 2. Update Row 4 (multi-paragraph)
            row4 = rows[4]
            cells4 = row4.findall('.//w:tc', ns)
            
            # Cell 0
            cell0_4 = cells4[0]
            c0_4_ps = cell0_4.findall('.//w:p', ns)
            while len(c0_4_ps) < len(row4_headings):
                new_p = copy.deepcopy(c0_4_ps[0])
                cell0_4.append(new_p)
                c0_4_ps.append(new_p)
            while len(c0_4_ps) > len(row4_headings):
                cell0_4.remove(c0_4_ps[-1])
                c0_4_ps.pop()
            for i, text in enumerate(row4_headings):
                format_para_in_cell(c0_4_ps[i], text, align="left")
                
            # Cell 1
            cell1_4 = cells4[1]
            c1_4_ps = cell1_4.findall('.//w:p', ns)
            while len(c1_4_ps) < len(row4_pages):
                new_p = copy.deepcopy(c1_4_ps[0])
                cell1_4.append(new_p)
                c1_4_ps.append(new_p)
            while len(c1_4_ps) > len(row4_pages):
                cell1_4.remove(c1_4_ps[-1])
                c1_4_ps.pop()
            for i, text in enumerate(row4_pages):
                format_para_in_cell(c1_4_ps[i], text, align="right")
                
            # 3. Update Row 9 (multi-paragraph remaining headings of Section 5)
            row9 = rows[9]
            cells9 = row9.findall('.//w:tc', ns)
            
            # Cell 0
            cell0_9 = cells9[0]
            c0_9_ps = cell0_9.findall('.//w:p', ns)
            while len(c0_9_ps) < len(row9_headings):
                new_p = copy.deepcopy(c0_9_ps[0])
                cell0_9.append(new_p)
                c0_9_ps.append(new_p)
            while len(c0_9_ps) > len(row9_headings):
                cell0_9.remove(c0_9_ps[-1])
                c0_9_ps.pop()
            for i, text in enumerate(row9_headings):
                format_para_in_cell(c0_9_ps[i], text, align="left")
                
            # Cell 1
            cell1_9 = cells9[1]
            c1_9_ps = cell1_9.findall('.//w:p', ns)
            while len(c1_9_ps) < len(row9_pages):
                new_p = copy.deepcopy(c1_9_ps[0])
                cell1_9.append(new_p)
                c1_9_ps.append(new_p)
            while len(c1_9_ps) > len(row9_pages):
                cell1_9.remove(c1_9_ps[-1])
                c1_9_ps.pop()
            for i, text in enumerate(row9_pages):
                format_para_in_cell(c1_9_ps[i], text, align="right")
                
            # 4. Update Row 14 (multi-paragraph Appendices V & G)
            row14 = rows[14]
            cells14 = row14.findall('.//w:tc', ns)
            
            # Cell 0
            cell0_14 = cells14[0]
            c0_14_ps = cell0_14.findall('.//w:p', ns)
            while len(c0_14_ps) < len(row14_headings):
                new_p = copy.deepcopy(c0_14_ps[0])
                cell0_14.append(new_p)
                c0_14_ps.append(new_p)
            while len(c0_14_ps) > len(row14_headings):
                cell0_14.remove(c0_14_ps[-1])
                c0_14_ps.pop()
            for i, text in enumerate(row14_headings):
                format_para_in_cell(c0_14_ps[i], text, align="left")
                
            # Cell 1
            cell1_14 = cells14[1]
            c1_14_ps = cell1_14.findall('.//w:p', ns)
            while len(c1_14_ps) < len(row14_pages):
                new_p = copy.deepcopy(c1_14_ps[0])
                cell1_14.append(new_p)
                c1_14_ps.append(new_p)
            while len(c1_14_ps) > len(row14_pages):
                cell1_14.remove(c1_14_ps[-1])
                c1_14_ps.pop()
            for i, text in enumerate(row14_pages):
                format_para_in_cell(c1_14_ps[i], text, align="right")
                
            # Clear all bold/italic styling
            removed_count = strip_bold_italic_globally(root)
            print(f"Removed {removed_count} bold/italic tags from Page 2.")
            
            modified_xml = ET.tostring(root, encoding='utf-8')
            
            # Write back
            with zipfile.ZipFile(dest_path, 'w', zipfile.ZIP_DEFLATED) as docx_out:
                for item in docx_in.infolist():
                    if item.filename == 'word/document.xml':
                        docx_out.writestr(item, modified_xml)
                    else:
                        docx_out.writestr(item, docx_in.read(item.filename))
                        
        os.remove(temp_backup)
        print("Page 2 processed successfully.")
        return True
    except Exception as e:
        print(f"Error on Page 2: {e}")
        if os.path.exists(temp_backup):
            os.remove(temp_backup)
        return False

# Run both
p1_success = process_toc_page_1()
p2_success = process_toc_page_2()

if p1_success and p2_success:
    print("\nBOTH Table of Contents documents processed and saved successfully!")
    sys.exit(0)
else:
    print("\nFailed to process one or both of the Table of Contents files.")
    sys.exit(1)
