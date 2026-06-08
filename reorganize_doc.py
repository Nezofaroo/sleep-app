import zipfile
import xml.etree.ElementTree as ET
import os
import sys
import shutil
import copy

sys.stdout.reconfigure(encoding='utf-8')

src_docx = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Өндірісті ұйымдастыру.docx"
backup_docx = r"C:\Users\admin\OneDrive\Рабочий стол\Н.Н. Дипломка\Өндірісті ұйымдастыру_backup.docx"

# 1. Back up original document if backup doesn't already exist or we want a fresh copy of the modified source
print("Creating backup of original document...")
shutil.copy2(src_docx, backup_docx)
print(f"Backup created at: {backup_docx}")

# Namespace and XML registry
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
ET.register_namespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')

def create_para(text, align="both"):
    p = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}p')
    pPr = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}pPr')
    
    ind = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}ind')
    ind.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}left', '284')
    ind.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}firstLine', '709')
    pPr.append(ind)
    
    jc = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}jc')
    jc.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', align)
    pPr.append(jc)
    
    rPr = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rPr')
    sz = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}sz')
    sz.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', '28')
    szCs = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}szCs')
    szCs.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', '28')
    lang = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}lang')
    lang.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', 'kk-KZ')
    rPr.append(sz)
    rPr.append(szCs)
    rPr.append(lang)
    pPr.append(rPr)
    p.append(pPr)
    
    run = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}r')
    run_rPr = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}rPr')
    run_sz = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}sz')
    run_sz.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', '28')
    run_szCs = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}szCs')
    run_szCs.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', '28')
    run_lang = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}lang')
    run_lang.set('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val', 'kk-KZ')
    run_rPr.append(run_sz)
    run_rPr.append(run_szCs)
    run_rPr.append(run_lang)
    run.append(run_rPr)
    
    t = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t')
    t.text = text
    run.append(t)
    p.append(run)
    return p

def create_empty_para():
    p = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}p')
    pPr = ET.Element('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}pPr')
    p.append(pPr)
    return p

# String Leaks Check dictionary (to clean up old terminology)
STRING_REPS = {
    "Linguaphile": "Sleep.ly",
    "Linguaphile-дің": "Sleep.ly-дің",
    "Linguaphile-де": "Sleep.ly-де",
    "Kotlin": "Dart",
    "Android SDK": "Flutter SDK",
    "SharedPreferences": "Hive",
    "Intent": "Navigator",
    "Firebase Firestore": "SQLite (Sqflite)",
    "Firebase Authentication": "Жергілікті сақтау",
    "LiveData": "Streams",
    "ViewModel": "Provider",
    "Repository": "DatabaseHelper",
    "Activity": "Widget",
    "Fragment": "Screen",
    "Room Database": "SQLite (Sqflite)"
}

try:
    with zipfile.ZipFile(backup_docx, 'r') as docx_in:
        xml_content = docx_in.read('word/document.xml')
        root = ET.fromstring(xml_content)
        body = root.find('.//w:body', ns)
        
        # 2. Programmatically map the 14 drawings in the body
        def get_text(elem):
            if elem.tag.endswith('p'):
                text_runs = elem.findall('.//w:t', ns)
                return "".join([run.text for run in text_runs if run.text]).strip()
            return ""

        figures = {}
        for idx, child in enumerate(body):
            text = get_text(child)
            if (text.startswith("Сурет 3.") or text.startswith("Cурет 3.")) and len(text) > 8:
                try:
                    num_str = ""
                    for char in text[8:]:
                        if char.isdigit():
                            num_str += char
                        else:
                            break
                    num = int(num_str)
                    
                    # Search backwards for drawing paragraph
                    drawing_idx = None
                    for s_idx in range(idx - 1, -1, -1):
                        s_child = body[s_idx]
                        if s_child.tag.endswith('p') and s_child.find('.//w:drawing', ns) is not None:
                            drawing_idx = s_idx
                            break
                        s_text = get_text(s_child)
                        if s_text.startswith("Сурет 3.") or s_text.startswith("Cурет 3."):
                            break
                    
                    if drawing_idx is not None:
                        figures[num] = copy.deepcopy(body[drawing_idx])
                except Exception as e:
                    print(f"Error parsing figure index {text}: {e}")

        print(f"Mapped {len(figures)} figures successfully.")
        if len(figures) < 14:
            print("Error: Could not locate all 14 figures! Reorganize aborted.")
            sys.exit(1)

        # Keep parts of original body children
        first_part = [copy.deepcopy(child) for child in body[:31]]
        # Last part is Section 3.3, 3.4, 3.5 and tables (indices 134 to 179)
        last_part = [copy.deepcopy(child) for child in body[134:180]]
        # The section properties properties element (always last child of body)
        sectPr = copy.deepcopy(body[-1])

        # 3. Build new User Guide (middle_part)
        middle_part = []
        
        # Heading 3.2
        middle_part.append(create_para("3.2 Пайдаланушы нұсқаулығы", align="center"))
        middle_part.append(create_empty_para())
        
        # User guide opening
        middle_part.append(create_para(
            "Қосымшамен жұмыс істеуді бастау үшін пайдаланушы мобильді құрылғыдан бағдарламаны іске қосады. "
            "Іске қосылғаннан кейін жүйе басты бақылау экранын (TrackerPage) немесе егер пайдаланушы жүйеге кірмеген "
            "болса, авторизация бетін ашады. Мұнда пайдаланушы ұйқыны тіркеуді бастай алады, дыбыс оқиғаларын тексере "
            "алады немесе статистика мен баптауларға өте алады. Тіркелу және авторизация функциялары пайдаланушы "
            "деректерін қорғау және бұлттық үндестіруді іске қосу үшін қолданылады."
        ))
        middle_part.append(create_empty_para())

        # 3.2.1
        middle_part.append(create_para("3.2.1 Авторизация және тіркелу терезелері", align="center"))
        middle_part.append(create_empty_para())
        middle_part.append(create_para(
            "Қосымшаның қауіпсіздігін және бұлттық үндестіруін қамтамасыз ету мақсатында авторизация және "
            "тіркелу терезелері әзірленді. Пайдаланушы қолданбаны алғаш рет іске қосқан кезде жүйеге кіру немесе "
            "тіркелу қажет болады. Егер пайдаланушы бұрын тіркелген болса, ол өзінің электрондық пошта мекенжайын "
            "және құпиясөзін енгізу арқылы жүйеге кіре алады. Авторизация сәтті аяқталғаннан кейін жүйе автоматты "
            "түрде басты TrackerPage бетіне бағыттайды және келесі кіру кезінде авто-кіру функциясы арқылы "
            "пайдаланушының жүйеге жылдам өтуін қамтамасыз етеді."
        ))
        middle_part.append(create_para("Сурет 3.1-де пайдаланушының авторизация терезесі көрсетілген:"))
        middle_part.append(figures[1])
        middle_part.append(create_para("Сурет 3.1 – Пайдаланушының авторизация терезесі", align="center"))
        middle_part.append(create_empty_para())

        middle_part.append(create_para(
            "Жаңа пайдаланушылар үшін қосымшада тіркелу мүмкіндігі қарастырылған. Тіркелу терезесінде "
            "пайдаланушы аты, электрондық пошта мекенжайы және құпиясөзді растау өрістері ұсынылады. Енгізілген "
            "мәліметтер валидациядан өтіп, жергілікті және бұлттық деректер қорына сәтті сақталған соң пайдаланушы "
            "үшін жаңа есептік жазба құрылады. Бұл пайдаланушыға өзінің ұйқы сессияларының деректерін сақтауға "
            "және кез келген уақытта қалпына келтіруге мүмкіндік береді."
        ))
        middle_part.append(create_para("Сурет 3.2-де пайдаланушының тіркелу терезесі көрсетілген:"))
        middle_part.append(figures[2])
        middle_part.append(create_para("Сурет 3.2 – Пайдаланушының тіркелу терезесі", align="center"))
        middle_part.append(create_empty_para())

        # 3.2.2
        middle_part.append(create_para("3.2.2 Басты TrackerPage терезесімен жұмыс істеу", align="center"))
        middle_part.append(create_empty_para())
        middle_part.append(create_para(
            "Қосымшаның негізгі беті – басты TrackerPage терезесі болып табылады. Бұл терезеде пайдаланушының "
            "ағымдағы күйі, оятқыштың орнатылған уақыты және ұйқыны бақылауды бастау батырмасы орналасқан. "
            "Пайдаланушы бұл терезе арқылы ұйқы процесін тікелей басқара алады. Интерфейс заманауи қараңғы "
            "дизайнда жасалған, бұл түнде қолданбаны пайдалану кезінде көздің шаршауын азайтуға мүмкіндік береді."
        ))
        middle_part.append(create_para("Сурет 3.3-те басты TrackerPage терезесі көрсетілген:"))
        middle_part.append(figures[3])
        middle_part.append(create_para("Сурет 3.3 – Басты TrackerPage терезесі", align="center"))
        middle_part.append(create_empty_para())

        # 3.2.3
        middle_part.append(create_para("3.2.3 Ұйқыға кету терезесі", align="center"))
        middle_part.append(create_empty_para())
        middle_part.append(create_para(
            "Пайдаланушы ұйқы режимін бастау алдында оның дайындығын тексеру және тыныштандыратын орта қалыптастыру "
            "үшін ұйқыға кету терезесі әзірленді. Бұл терезеде пайдаланушыға ұйықтар алдында демалуға көмектесетін "
            "тыныш музыка немесе табиғат дыбыстарын қосу мүмкіндігі беріледі. Сондай-ақ пайдаланушы осы терезе "
            "арқылы түндегі ұйқысын бақылау режимін жылдам іске қоса алады."
        ))
        middle_part.append(create_para("Сурет 3.4-те пайдаланушы ұйқыға кету терезесі көрсетілген:"))
        middle_part.append(figures[4])
        middle_part.append(create_para("Сурет 3.4 – Пайдаланушы ұйқыға кету терезесі", align="center"))
        middle_part.append(create_empty_para())

        # 3.2.4
        middle_part.append(create_para("3.2.4 Дыбыс датчигі және жазбалар терезесі", align="center"))
        middle_part.append(create_empty_para())
        middle_part.append(create_para(
            "Ұйқы барысында пайдаланушының түндегі дыбыстық белсенділігін (қорылдау, сөйлеу немесе сыртқы "
            "шулар) тіркеу үшін дыбыс датчигі модулі жұмыс істейді. Егер қоршаған орта дыбысы пайдаланушы баптауларда "
            "орнатқан шектік мәннен (sound threshold) асатын болса, қосымша дыбысты автоматты түрде жазып алады. "
            "Жазылған файлдар дыбыс датчигі және жазбалар терезесінде уақыты мен децибел деңгейі көрсетіліп "
            "сақталады. Пайдаланушы бұл жазбаларды кез келген уақытта қайта тыңдай алады."
        ))
        middle_part.append(create_para("Сурет 3.5-те дыбыс датчигі және жазбалар терезесі көрсетілген:"))
        middle_part.append(figures[5])
        middle_part.append(create_para("Сурет 3.5 – Дыбыс датчигі және жазбалар терезесі", align="center"))
        middle_part.append(create_empty_para())

        # 3.2.5
        middle_part.append(create_para("3.2.5 Ұйқыдан кейінгі күйді бағалау панелі", align="center"))
        middle_part.append(create_empty_para())
        middle_part.append(create_para(
            "Ояну сәтінен кейін пайдаланушының субъективті сезімін анықтау және ұйқы сапасының оның көңіл-күйіне "
            "әсерін талдау мақсатында көңіл-күй сұрау панелі қолданылады. Қосымша пайдаланушы оянған бойда "
            "одан ағымдағы көңіл-күйін (мысалы, сергек, шаршаған, орташа) сұрайды. Бұл деректер статистика "
            "модулінде жинақталып, болашақта ұйқы сапасын жақсарту бойынша кеңестер беру үшін пайдаланылады."
        ))
        middle_part.append(create_para("Сурет 3.6-да ұйқыдан кейін көңіл күй сұрау панелі көрсетілген:"))
        middle_part.append(figures[6])
        middle_part.append(create_para("Сурет 3.6 – Ұйқыдан кейін көңіл күй сұрау панелі", align="center"))
        middle_part.append(create_empty_para())

        # 3.2.6
        middle_part.append(create_para("3.2.6 Динамикалық ұйқы кеңестері", align="center"))
        middle_part.append(create_empty_para())
        middle_part.append(create_para(
            "Пайдаланушылардың ұйқы гигиенасын жақсарту және оларға сау ұйқы әдеттерін үйрету үшін "
            "Discover (Кеңестер) бөлімі әзірленген. Мұнда ұйқы сапасын арттыруға бағытталған ғылыми негізделген "
            "мақалалар мен ұсыныстар жарияланады. Ұсыныстар пайдаланушының ұйқы статистикасы мен оның түнде "
            "тіркелген дыбыстық оқиғаларына байланысты динамикалық түрде өзгеріп отырады."
        ))
        middle_part.append(create_para("Сурет 3.7-де ұйқы кеңестері мен Discover бөлімі көрсетілген:"))
        middle_part.append(figures[7])
        middle_part.append(create_para("Сурет 3.7 – Ұйқы кеңестері мен Discover бөлімі", align="center"))
        middle_part.append(create_empty_para())

        # 3.2.7
        middle_part.append(create_para("3.2.7 Ұйқыны бақылау алгоритмі мен терезелері", align="center"))
        middle_part.append(create_empty_para())
        middle_part.append(create_para(
            "Ұйқыны тіркеу және бақылау режимі іске қосылған кезде арнайы бақылау терезесі ашылады. "
            "Бұл терезеде ұйқының басталғанынан бергі жалпы ұзақтығын есептейтін таймер және микрофон датчигінен "
            "келетін дыбыс деңгейін нақты уақытта бейнелейтін анимациялық толқын көрсетіледі. Фондық режим қызметі "
            "(Background Service) қолданба жабық тұрса да, бақылау процесінің үзілмеуін қамтамасыз етеді."
        ))
        middle_part.append(create_para("Сурет 3.8-де ұйқыны бақылау және тіркеу терезесі көрсетілген:"))
        middle_part.append(figures[8])
        middle_part.append(create_para("Сурет 3.8 – Ұйқыны бақылау және тіркеу терезесі", align="center"))
        middle_part.append(create_empty_para())

        # 3.2.8
        middle_part.append(create_para("3.2.8 Пайдаланушы профилі", align="center"))
        middle_part.append(create_empty_para())
        middle_part.append(create_para(
            "Пайдаланушы профилі оның жеке деректерін, тіркелген күнін, мақсатты ұйқы ұзақтығын (күнделікті "
            "қажетті сағаттар санын) және жүйелік параметрлерін қамтиды. Бұл терезеде пайдаланушы өз деректерін "
            "басқара алады, электрондық пошта мекенжайын тексере алады және қажет болған жағдайда жүйеден шығу "
            "батырмасын басып, сессияны аяқтай алады."
        ))
        middle_part.append(create_para("Сурет 3.9-да пайдаланушы профилі терезесі көрсетілген:"))
        middle_part.append(figures[9])
        middle_part.append(create_para("Сурет 3.9 – Пайдаланушы профилі терезесі", align="center"))
        middle_part.append(create_empty_para())

        # 3.2.9
        middle_part.append(create_para("3.2.9 Ұйқы статистикасы мен графиктер", align="center"))
        middle_part.append(create_empty_para())
        middle_part.append(create_para(
            "Пайдаланушының ұйқы тарихын талдау және оның прогресін көрсету үшін толық аналитикалық статистика "
            "бөлімі құрылды. Мұнда бірнеше функционалдық терезелер бар. Бірінші кезекте пайдаланушы өткен күндердің "
            "ұйқы нәтижелерін күнтізбелік интерфейс арқылы таңдап көре алады. Күнтізбе әр күннің ұйқы сапасы ұпайын "
            "жылдам шолуға мүмкіндік береді."
        ))
        middle_part.append(create_para("Сурет 3.10-да статистика ішіндегі күнтізбе көрсетілген:"))
        middle_part.append(figures[10])
        middle_part.append(create_para("Сурет 3.10 – Статистика ішіндегі күнтізбе", align="center"))
        middle_part.append(create_empty_para())

        middle_part.append(create_para(
            "Екінші маңызды терезе – аналитикалық ақпараттармен аудио жазбалар тізімі. Мұнда пайдаланушының "
            "ұйқы кезеңдерінің ұзақтығы (терең ұйқы, жеңіл ұйқы, REM фазасы) пайыздық және сағаттық қатынаста "
            "көрсетіледі. Сонымен қатар түнде жазылған барлық аудио файлдардың тізімі мен олардың уақыт аралығы "
            "осы терезеде жинақталған."
        ))
        middle_part.append(create_para("Сурет 3.11-де аналитикалық ақпараттармен аудио жазбалар терезесі көрсетілген:"))
        middle_part.append(figures[11])
        middle_part.append(create_para("Сурет 3.11 – Аналитикалық ақпараттармен аудио жазбалар", align="center"))
        middle_part.append(create_empty_para())

        middle_part.append(create_para(
            "Ұзақ мерзімді үрдістерді бақылау үшін апталық статистика терезесі әзірленді. Мұнда аптаның "
            "әр күніне арналған ұйқы сапасы мен оның ұзақтығы fl_chart кітапханасы арқылы динамикалық бағандық "
            "диаграммалар түрінде бейнеленеді. Бұл пайдаланушыға апта ішіндегі ұйқы режимінің тұрақтылығын "
            "талдауға көмектеседі."
        ))
        middle_part.append(create_para("Сурет 3.12-де нақтырақ апта бойынша статистика бөлімі көрсетілген:"))
        middle_part.append(figures[12])
        middle_part.append(create_para("Сурет 3.12 – Нақтырақ апта бойынша статистика бөлімі", align="center"))
        middle_part.append(create_empty_para())

        middle_part.append(create_para(
            "Сондай-ақ айлық статистика терезесі пайдаланушының бір ай бойындағы ұйқы динамикасын сызықтық "
            "график түрінде көрсетеді. Бұл график ұйқы сапасының айлық өзгеруін, орташа ұзақтықты және мақсатты "
            "көрсеткішке жету пайызын визуализациялайды."
        ))
        middle_part.append(create_para("Сурет 3.13-те нақтырақ айлық бойынша статистика бөлімі көрсетілген:"))
        middle_part.append(figures[13])
        middle_part.append(create_para("Сурет 3.13 – Нақтырақ айлық бойынша статистика бөлімі", align="center"))
        middle_part.append(create_empty_para())

        # 3.2.10
        middle_part.append(create_para("3.2.10 Пайдаланушы баптаулары мен тақырып таңдау", align="center"))
        middle_part.append(create_empty_para())
        middle_part.append(create_para(
            "Қосымшаның соңғы бөлімі – параметрлерді реттеу беті. Мұнда пайдаланушы дыбыс датчигінің "
            "сезімталдық шегін (sound threshold), ақылды оятқыштың ояту терезесін және хабарландыруларды баптай алады. "
            "Сонымен қатар пайдаланушы интерфейстің қараңғы (Dark Theme) немесе жарық (Light Theme) тақырыптарын "
            "өзінің таңдауына қарай ауыстыра алады. Барлық өзгертілген параметрлер жергілікті Hive жәшігінде сақталып, "
            "қосымша қайта қосылған кезде автоматты түрде қолданылады."
        ))
        middle_part.append(create_para("Сурет 3.14-те параметрлер ішіндегі тема ауыстыру терезесі көрсетілген:"))
        middle_part.append(figures[14])
        middle_part.append(create_para("Сурет 3.14 – Параметрлер ішіндегі тема ауыстыру", align="center"))
        middle_part.append(create_empty_para())

        # Clear existing children from body
        body.clear()

        # Reconstruct body children list
        new_children = first_part + middle_part + last_part + [sectPr]
        for child in new_children:
            body.append(child)

        # 4. Perform String Leaks Check globally
        for t in root.findall('.//w:t', ns):
            if t.text:
                orig_text = t.text
                new_text = orig_text
                for old_val, new_val in STRING_REPS.items():
                    new_text = new_text.replace(old_val, new_val)
                if new_text != orig_text:
                    t.text = new_text

        # 5. Styling removal
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
        
        # 6. Re-zip the modified document.xml with other docx assets
        print(f"Writing changes to {src_docx}...")
        with zipfile.ZipFile(src_docx, 'w', zipfile.ZIP_DEFLATED) as docx_out:
            for item in docx_in.infolist():
                if item.filename == 'word/document.xml':
                    docx_out.writestr(item, modified_xml)
                else:
                    docx_out.writestr(item, docx_in.read(item.filename))
                    
    print("Reorganization and text correction completed successfully!")
except Exception as e:
    print(f"Error during reorganization: {e}")
    sys.exit(1)
