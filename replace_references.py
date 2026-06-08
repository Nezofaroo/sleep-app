import zipfile
import xml.etree.ElementTree as ET
import os
import sys
import shutil
import copy

sys.stdout.reconfigure(encoding='utf-8')

template_path = r"C:\Users\admin\OneDrive\Рабочий стол\А.А.Дипломка\Диплом Абдыкадыр.А\Қолданылған әдебиеттер тізімі.docx"
dest_dir = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка"
dest_path = os.path.join(dest_dir, "Қолданылған әдебиеттер тізімі.docx")

if not os.path.exists(dest_dir):
    os.makedirs(dest_dir)

print(f"Copying template from {template_path} to {dest_path}...")
shutil.copy2(template_path, dest_path)

ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
ET.register_namespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')

def format_paragraph(p, text, align="left"):
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

new_references = [
    "1.Қазақстан Республикасының «Білім туралы» Заңы. – Астана, 2025.",
    "2.Қазақстан Республикасының «Ақпараттандыру туралы» Заңы. – Астана, 2025.",
    "3.Назарбаев Н.Ә. Қазақстанның цифрлық даму стратегиясы. – Астана, 2024.",
    "4.Flutter фреймворкі бойынша әзірлеушілерге арналған ресми құжаттама – https://docs.flutter.dev",
    "5.Dart бағдарламалау тілінің ресми нұсқаулығы мен құжаттамасы – https://dart.dev",
    "6.Hive мобильдік дерекқорының ресми құжаттамасы мен нұсқаулары – https://pub.dev/packages/hive",
    "7.SQLite (Sqflite) деректер қорын қосу және баптау бойынша ресми құжаттама – https://pub.dev/packages/sqflite",
    "8.Flutter-де фондық жұмыс сервистерін (Background Service) ұйымдастыру – https://pub.dev/packages/flutter_background_service",
    "9.Material Design 3 интерфейсін жобалау мен дизайнын әзірлеу бойынша нұсқаулық – https://m3.material.io",
    "10.Flutter-де қосымша күйін басқару (Provider) кітапханасының ресми құжаттамасы – https://pub.dev/packages/provider",
    "11.Копеев А. Мобильді қосымшаларды әзірлеу негіздері: оқу құралы. – Алматы: 2023.",
    "12.Адилов Б. Flutter және Dart көмегімен кроссплатформалық қолданбалар жасау. – Астана: 2024.",
    "13.Швец А. Погружение в паттерны проектирования. – 2021.",
    "14.Android Studio және VS Code әзірлеу орталарының ресми нұсқаулықтары – https://developer.android.com/studio",
    "15.Audioplayers аудио файлдармен жұмыс істеу пакетінің ресми құжаттамасы – https://pub.dev/packages/audioplayers"
]

try:
    temp_backup = dest_path + ".tmp"
    shutil.copy2(dest_path, temp_backup)
    
    with zipfile.ZipFile(temp_backup, 'r') as docx_in:
        xml_content = docx_in.read('word/document.xml')
        root = ET.fromstring(xml_content)
        
        paragraphs = root.findall('.//w:p', ns)
        
        # Format Heading P2
        format_paragraph(paragraphs[2], "ҚОЛДАНЫЛҒАН ӘДЕБИЕТТЕР ТІЗІМІ", align="center")
        
        # Format and write new references (P5 to P19)
        ref_idx = 0
        for p_idx in range(5, 20):
            if p_idx < len(paragraphs):
                format_paragraph(paragraphs[p_idx], new_references[ref_idx], align="left")
                ref_idx += 1
                
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
    print("Bibliography successfully created and styled!")
except Exception as e:
    print(f"Error: {e}")
    if os.path.exists(temp_backup):
        os.remove(temp_backup)
    sys.exit(1)
