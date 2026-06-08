import zipfile
import xml.etree.ElementTree as ET
import os
import sys
import shutil

sys.stdout.reconfigure(encoding='utf-8')

template_path = r"C:\Users\admin\OneDrive\Рабочий стол\А.А.Дипломка\Диплом Абдыкадыр.А\Қорытынды.docx"
dest_dir = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка"
dest_path = os.path.join(dest_dir, "Қорытынды.docx")

if not os.path.exists(dest_dir):
    os.makedirs(dest_dir)

# 1. Copy template to destination
print(f"Copying template from {template_path} to {dest_path}...")
shutil.copy2(template_path, dest_path)

# Namespaces
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
ET.register_namespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')

def format_para(p, text, align="both"):
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

def format_list_para(p, items):
    # Save pPr
    pPr = p.find('w:pPr', ns)
    p.clear()
    
    if pPr is not None:
        p.append(pPr)
    else:
        pPr = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}pPr')
        p.append(pPr)

    # Indentation and alignment
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

    # Build runs for each item
    for idx, item in enumerate(items):
        # 1. Run for spaces
        r_spaces = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}r')
        rPr_spaces = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rPr')
        rFonts = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rFonts')
        rFonts.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}ascii', 'Times New Roman')
        rFonts.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}hAnsi', 'Times New Roman')
        rPr_spaces.append(rFonts)
        sz = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}sz')
        sz.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', '28')
        rPr_spaces.append(sz)
        r_spaces.append(rPr_spaces)
        t_spaces = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t')
        t_spaces.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
        t_spaces.text = '          '
        r_spaces.append(t_spaces)
        p.append(r_spaces)

        # 2. Run for dash
        r_dash = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}r')
        rPr_dash = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rPr')
        rPr_dash.append(copy_rfonts())
        rPr_dash.append(copy_sz())
        r_dash.append(rPr_dash)
        t_dash = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t')
        t_dash.text = '- '
        r_dash.append(t_dash)
        p.append(r_dash)

        # 3. Run for text
        r_text = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}r')
        rPr_text = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rPr')
        rPr_text.append(copy_rfonts())
        rPr_text.append(copy_sz())
        lang = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}lang')
        lang.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', 'kk-KZ')
        rPr_text.append(lang)
        r_text.append(rPr_text)
        t_text = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t')
        t_text.text = item
        r_text.append(t_text)
        p.append(r_text)

        # 4. Run for break (if not last)
        if idx < len(items) - 1:
            r_br = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}r')
            rPr_br = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rPr')
            r_br.append(rPr_br)
            br = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}br')
            r_br.append(br)
            p.append(r_br)

def copy_rfonts():
    rFonts = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rFonts')
    rFonts.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}ascii', 'Times New Roman')
    rFonts.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}hAnsi', 'Times New Roman')
    rFonts.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}cs', 'Times New Roman')
    return rFonts

def copy_sz():
    sz = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}sz')
    sz.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', '28')
    return sz

# Content blocks
intro_text = (
    "Дипломдық жобаны орындау барысында ұйқы циклін бақылауға және дыбыстық оқиғаларды тіркеуге арналған "
    "Sleep.ly мобильді қосымшасы әзірленді. Жобаның негізгі мақсаты пайдаланушылардың ұйқы сапасын жақсартуға "
    "және түндегі дыбыстық белсенділігін талдауға мүмкіндік беретін заманауи мобильді көмекші жүйені құру болды."
)

research_text = (
    "Жобаны әзірлеу барысында пәндік аймаққа талдау жүргізіліп, ұйқыны бақылауға және дыбыстарды тіркеуге арналған "
    "қолданыстағы мобильді қосымшалардың мүмкіндіктері зерттелді. Зерттеу нәтижесінде пайдаланушылардың қажеттіліктері "
    "анықталып, қосымшаға қойылатын функционалдық талаптар қалыптастырылды."
)

tech_stack_text = (
    "Қосымшаны әзірлеу үшін Dart бағдарламалау тілі, Flutter SDK фреймворкі және Android Studio бағдарламалау ортасы "
    "пайдаланылды. Пайдаланушылардың параметрлері мен оятқыш уақыттарын жергілікті деңгейде жылдам өңдеу үшін оффлайн Hive "
    "дерекқоры, ал ұйқы сессияларының статистикасын сақтау үшін SQLite (Sqflite) деректер қоры қолданылды. Авторизация "
    "және бұлттық үндестіру Firebase технологиялары арқылы жүзеге асырылды."
)

features_intro = "Әзірленген қосымша келесі негізгі функцияларды қамтиды:"

features_list = [
    "пайдаланушыларды тіркеу және авторизациялау;",
    "түнде дыбыс датчигінің көмегімен қорыл мен сөйлеуді тіркеу;",
    "аудио файлдарды жергілікті жадыда сақтау және тыңдау;",
    "ақылды оятқыш жүйесін және ояту терезелерін баптау;",
    "ұйқы циклінің сапасын бағалайтын ұпайды есептеу;",
    "апталық және айлық графиктерді Visualizer (fl_chart) арқылы көрсету;",
    "қараңғы және жарық интерфейс тақырыптарын ауыстыру;",
    "динамикалық ұйқы кеңестері мен Discover бөлімін пайдалану."
]

testing_text = (
    "Жобаны орындау барысында қосымшаның барлық негізгі модульдері әзірленіп, тестілеуден өткізілді. "
    "Тестілеу нәтижесінде жүйенің фондық режимде де тұрақты жұмыс істейтіні, микрофон датчигінің дыбыстарды "
    "дұрыс тіркейтіні, пайдаланушы интерфейсінің қолайлы екені және деректердің Hive пен SQLite дерекқорларында "
    "дұрыс сақталатыны анықталды. Қосымшада анықталған қателер түзетіліп, бағдарламаның соңғы нұсқасы "
    "пайдалануға дайын күйге келтірілді."
)

economy_text = (
    "Дипломдық жобаның экономикалық бөлімінде бағдарламалық өнімді әзірлеуге жұмсалатын шығындар есептеліп, "
    "жобаның экономикалық тиімділігі анықталды. Есептеу нәтижелері әзірленген бағдарламалық өнімді енгізудің "
    "тиімді екенін көрсетті."
)

safety_text = (
    "Еңбекті қорғау бөлімінде бағдарламашылардың еңбек жағдайлары қарастырылып, жұмыс орнындағы электр "
    "қауіпсіздігі, артық жұмыс уақытын ұйымдастыру, шу мен дірілден қорғау, сондай-ақ қауіпсіз жұмыс ортасын "
    "қалыптастыру мәселелері талданды."
)

concluding_text = (
    "Осылайша дипломдық жобаның барлық мақсаттары мен міндеттері толық орындалды. Sleep.ly мобильді қосымшасы "
    "ұйқы циклін бақылау және талдау процесін жеңілдетуге, пайдаланушылардың ұйқы сапасы мен гигиенасын арттыруға "
    "және түндегі дыбыстық белсенділігін бақылауға мүмкіндік береді. Жоба барысында алынған теориялық білімдер "
    "тәжірибеде қолданылып, мобильді қосымшаларды әзірлеу саласында маңызды тәжірибе жинақталды."
)

try:
    temp_backup = dest_path + ".tmp"
    shutil.copy2(dest_path, temp_backup)
    
    with zipfile.ZipFile(temp_backup, 'r') as docx_in:
        xml_content = docx_in.read('word/document.xml')
        root = ET.fromstring(xml_content)
        
        paragraphs = root.findall('.//w:p', ns)
        print(f"Total paragraphs in template: {len(paragraphs)}")
        
        # Replace contents
        format_para(paragraphs[0], "ҚОРЫТЫНДЫ", align="center")
        format_para(paragraphs[3], intro_text)
        format_para(paragraphs[4], research_text)
        format_para(paragraphs[5], tech_stack_text)
        format_para(paragraphs[6], features_intro)
        format_list_para(paragraphs[7], features_list)
        format_para(paragraphs[8], testing_text)
        format_para(paragraphs[9], economy_text)
        format_para(paragraphs[10], safety_text)
        format_para(paragraphs[11], concluding_text)

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
    print("Conclusion successfully created and styled!")
except Exception as e:
    print(f"Error: {e}")
    if os.path.exists(temp_backup):
        os.remove(temp_backup)
    sys.exit(1)
