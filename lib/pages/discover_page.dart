import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_colors.dart';
import 'article_reading_page.dart';

class DiscoverArticle {
  final String tag;
  final String title;
  final String subtitle;
  final String content;
  final IconData icon;
  final int minutes;
  const DiscoverArticle(this.tag, this.title, this.subtitle, this.content, this.icon, this.minutes);
}

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  late final AudioPlayer _audioPlayer;
  _Soundscape? _playingSoundscape;
  Timer? _countdownTimer;
  int? _timerDurationMinutes;
  int _remainingSeconds = 0;

  static const DiscoverArticle _featuredArticle = DiscoverArticle(
    'Optimize',
    'Полное руководство по оптимизации сна',
    'Научно обоснованный план достижения идеального ночного отдыха.',
    'Сон — это основа нашего здоровья, продуктивности и долголетия. Оптимизация сна состоит из трех базовых компонентов:\n\n**1. Темнота и Тишина**\nИспользуйте плотные шторы (блэкаут) и устраните любые источники мерцающего света (светодиоды приборов). При необходимости используйте беруши.\n\n**2. Постоянный график**\nЛожитесь и вставайте в одно и то же время каждый день, даже в выходные. Это тренирует циркадный ритм и облегчает засыпание.\n\n**3. Расслабление перед сном**\nПосвятите последние 60 минут дня бесэкранным активностям: чтению бумажных книг, теплой ванне, медитации или мягким растяжкам.\n\n**4. Температурный режим**\nПроветрите комнату перед сном. Оптимальная температура воздуха составляет 16-19°C. Именно прохлада помогает телу снизить внутреннюю температуру для глубоких фаз сна.',
    Icons.auto_awesome_rounded,
    10,
  );

  static final List<DiscoverArticle> _articles = [
    DiscoverArticle(
      'Science',
      'Почему быстрый сон — это дефрагментация мозга',
      'Как нейроны перезаписывают память во время фазы быстрого движения глаз.',
      'Фаза быстрого сна (REM-сон) — один из самых удивительных процессов, происходящих в нашем организме. В этот период мозг работает так же активно, как и во время бодрствования, но наше тело остается практически парализованным.\n\n**Зачем нужен REM-сон?**\nВо время этой фазы мозг сортирует накопленную за день информацию. Ненужные воспоминания стираются, а важные переносятся из кратковременной памяти в долговременную. Этот процесс очень похож на дефрагментацию жесткого диска компьютера.\n\n**Эмоциональная обработка**\nREM-сон также играет ключевую роль в снижении эмоциональной чувствительности. Мозг повторно переживает стрессовые события дня в безопасной химической среде (с пониженным уровнем норадреналина), что помогает нам проснуться с более «холодной головой» и снизить тревожность.',
      Icons.psychology_outlined,
      4,
    ),
    DiscoverArticle(
      'Optimize',
      'Прохладная комната и глубокий сон: температура тела',
      'Научные факты о пользе сна при 18°C и о том, почему это необходимо организму.',
      'Многие сталкивались с тем, что в душной комнате уснуть практически невозможно. Наука подтверждает: температура окружающей среды имеет решающее влияние на качество глубокого сна.\n\n**Идеальный температурный режим**\nБольшинство сомнологов сходятся во мнении, что оптимальная температура для сна составляет от 15°C до 19°C (60-67°F). Это может показаться прохладным, но именно в таких условиях организм быстрее погружается в глубокие фазы сна.\n\n**Терморегуляция и восстановление**\nПеред началом сна температура нашего тела естественным образом снижается. Прохладная комната помогает ускорить этот процесс. Слишком высокая температура воздуха заставляет организм тратить энергию на охлаждение, что приводит к частым пробуждениям и снижает общую эффективность ночного восстановления.',
      Icons.thermostat_outlined,
      3,
    ),
    DiscoverArticle(
      'Technique',
      'Дыхание 4-7-8: засыпайте за 60 секунд',
      'Техника дыхания «морских котиков» США, адаптированная для гражданского сна.',
      'Дыхательная гимнастика «4-7-8» — это простой и эффективный способ справиться со стрессом, тревожностью и быстро заснуть. Метод основан на древней индийской практике пранаямы и адаптирован для быстрого расслабления.\n\n**Как работает эта техника?**\n1. Сделайте спокойный выдох через рот со свистящим звуком.\n2. Закройте рот и сделайте тихий вдох через нос на 4 счета.\n3. Задержите дыхание на 7 счетов.\n4. Сделайте полный выдох через рот на 8 счетов.\n5. Повторите этот цикл 4 раза.\n\n**Физиологический эффект**\nПри задержке дыхания и медленном выдохе активируется парасимпатическая нервная система, замедляется пульс и снижается артериальное давление. Это дает сигнал вашему мозгу, что вы находитесь в безопасности и готовы ко сну.',
      Icons.air_outlined,
      2,
    ),
    DiscoverArticle(
      'Circadian',
      'Световые протоколы для регуляции биоритмов',
      'Перепрограммируйте циркадный ритм с помощью стратегического синего света.',
      'Свет является главным синхронизатором наших внутренних циркадных часов. Правильное управление освещением помогает настроить режим сна даже закоренелым «совам».\n\n**Утренний протокол**\nВ течение первых 30 минут после пробуждения постарайтесь получить как можно больше яркого света (лучше всего — солнечного). Это останавливает выработку мелатонина и запускает таймер бодрствования: через 14-16 часов организм снова захочет спать.\n\n**Вечерний протокол**\nЗа 2 часа до сна минимизируйте яркий верхний свет. Синий спектр от экранов телефонов и компьютеров подавляет синтез мелатонина, обманывая мозг. Используйте теплый приглушенный свет и ночной режим на устройствах.',
      Icons.light_mode_outlined,
      5,
    ),
    DiscoverArticle(
      'Nutrition',
      'Глицинат магния: важнейший нутриент для сна',
      'Добавки, которые реально меняют качество вашего восстановления.',
      'Магний участвует более чем в 300 биохимических реакциях организма, и его дефицит напрямую влияет на бессонницу и мышечное напряжение.\n\n**Почему именно глицинат?**\nСуществуют разные формы магния, но глицинат (соединение магния с аминокислотой глицином) считается золотым стандартом для сна. Он обладает высокой биодоступностью, не вызывает дискомфорта в желудке, а глицин сам по себе оказывает мягкое успокаивающее действие на нервную систему.\n\n**Влияние на ГАМК**\nМагний активирует рецепторы гамма-аминомасляной кислоты (ГАМК) — главного тормозного нейромедиатора мозга, помогая отключить навязчивые мысли перед сном.',
      Icons.science_outlined,
      6,
    ),
    DiscoverArticle(
      'Audio',
      'Бинауральные ритмы и дельта-волны',
      'Настройка мозга на частоту 0.5–4 Гц для глубокого восстановительного сна.',
      'Бинауральные ритмы — это слуховая иллюзия, возникающая, когда в левое и правое ухо подаются звуки близких, но разных частот. Разница между ними воспринимается мозгом как третий ритм.\n\n**Синхронизация волн мозга**\nДля глубокого сна мозг должен войти в режим дельта-колебаний (от 0.5 до 4 Гц). Если в левое ухо подать частоту 100 Гц, а в правое — 103 Гц, мозг начнет синхронизироваться с разницей в 3 Гц (дельта-диапазон).\n\n**Как слушать бинауральные ритмы?**\nИспользовать наушники обязательно, иначе бинауральный эффект не возникнет. Слушайте записи на комфортной, невысокой громкости в течение 15-30 минут перед сном, закрыв глаза.',
      Icons.headphones_outlined,
      3,
    ),
  ];

  static final List<_Soundscape> _soundscapes = [
    _Soundscape('Deep Space',  Icons.star_outline_rounded, 'audio/deep_space.m4a', isLocal: true),
    _Soundscape('Rain',        Icons.water_drop_outlined,  'audio/rain.m4a',       isLocal: true),
    _Soundscape('White Noise', Icons.graphic_eq_rounded,   'audio/white_noise.m4a',isLocal: true),
    _Soundscape('Delta Wave',  Icons.waves_outlined,       'audio/delta_wave.m4a', isLocal: true),
    _Soundscape('Forest',      Icons.forest_outlined,      'https://www.frostscience.org/wp-content/uploads/2019/06/01-bird-calls.mp3', isLocal: false),
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleSoundscape(_Soundscape s) async {
    if (_playingSoundscape == s) {
      await _audioPlayer.stop();
      setState(() {
        _playingSoundscape = null;
      });
      _cancelTimer();
    } else {
      await _audioPlayer.stop();
      try {
        setState(() {
          _playingSoundscape = s;
        });
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        final Source source = s.isLocal ? AssetSource(s.audioPath) : UrlSource(s.audioPath);
        await _audioPlayer.play(source);
      } catch (e) {
        debugPrint("Error playing soundscape: $e");
        setState(() {
          _playingSoundscape = null;
        });
      }
    }
  }

  void _startTimer(int minutes) {
    _cancelTimer();
    setState(() {
      _timerDurationMinutes = minutes;
      _remainingSeconds = minutes * 60;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        _stopSoundscapeOnTimer();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _cancelTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    setState(() {
      _timerDurationMinutes = null;
      _remainingSeconds = 0;
    });
  }

  void _stopSoundscapeOnTimer() async {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    await _audioPlayer.stop();
    setState(() {
      _playingSoundscape = null;
      _timerDurationMinutes = null;
      _remainingSeconds = 0;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$mStr:$sStr';
  }

  void _showSleepTimerBottomSheet() {
    final c = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _SleepTimerBottomSheet(
          initialMinutes: _timerDurationMinutes,
          onStart: (mins) {
            _startTimer(mins);
            Navigator.pop(context);
          },
          onCancel: () {
            _cancelTimer();
            Navigator.pop(context);
          },
          c: c,
        );
      },
    );
  }

  Widget _buildTimerButton(AppColors c) {
    final active = _remainingSeconds > 0;
    final text = active ? _formatTime(_remainingSeconds) : 'Таймер: Выкл';
    return GestureDetector(
      onTap: _showSleepTimerBottomSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: active
            ? BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: c.accentGradient),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: c.accent.withValues(alpha: 0.35),
                      blurRadius: 10, offset: const Offset(0, 4))
                ])
            : c.cardRaised(radius: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.timer_rounded : Icons.timer_outlined,
              size: 14,
              color: active ? c.white : c.accent,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: active ? c.white : c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(c)),
            SliverToBoxAdapter(child: _buildFeaturedCard(context, c)),
            SliverToBoxAdapter(child: _buildSoundscapes(c)),
            SliverToBoxAdapter(child: _sectionLabel('Articles', c)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _ArticleCard(article: _articles[i]),
                  childCount: _articles.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Discover',
            style: GoogleFonts.montserrat(
                fontSize: 26, fontWeight: FontWeight.w800, color: c.textPrimary)),
        const SizedBox(height: 4),
        Text('Science-backed sleep insights',
            style: GoogleFonts.montserrat(fontSize: 14, color: c.textSecondary)),
      ]),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ArticleReadingPage(article: _featuredArticle),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: c.accentGradient),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: c.accent.withValues(alpha: 0.35),
                  blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: c.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('FEATURED',
                        style: GoogleFonts.montserrat(
                            fontSize: 9, fontWeight: FontWeight.w700,
                            color: c.white, letterSpacing: 1.5)),
                  ),
                  const SizedBox(height: 12),
                  Text('The Sleep Optimization Guide',
                      style: GoogleFonts.montserrat(
                          fontSize: 18, fontWeight: FontWeight.w800,
                          color: c.white, height: 1.2)),
                  const SizedBox(height: 8),
                  Text('A complete science-based roadmap to perfect sleep.',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, color: c.white.withValues(alpha: 0.85))),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: c.white, borderRadius: BorderRadius.circular(30)),
                    child: Text('Read Now',
                        style: GoogleFonts.montserrat(
                            fontSize: 12, fontWeight: FontWeight.w700, color: c.accent)),
                  ),
                ]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.menu_book_rounded, size: 64,
                  color: c.white.withValues(alpha: 0.35)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundscapes(AppColors c) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Soundscapes',
                style: GoogleFonts.montserrat(
                    fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary)),
            _buildTimerButton(c),
          ],
        ),
      ),
      SizedBox(
        height: 110,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          scrollDirection: Axis.horizontal,
          itemCount: _soundscapes.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (_, i) {
            final s = _soundscapes[i];
            final playing = _playingSoundscape == s;
            return _SoundscapeTile(
              s: s,
              playing: playing,
              onTap: () => _toggleSoundscape(s),
            );
          },
        ),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _sectionLabel(String label, AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
      child: Text(label,
          style: GoogleFonts.montserrat(
              fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary)),
    );
  }
}

class _SoundscapeTile extends StatelessWidget {
  final _Soundscape s;
  final bool playing;
  final VoidCallback onTap;

  const _SoundscapeTile({
    required this.s,
    required this.playing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 110,
        padding: const EdgeInsets.all(16),
        decoration: playing
            ? BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: c.accentGradient),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: c.accent.withValues(alpha: 0.4),
                      blurRadius: 12, offset: const Offset(0, 6))
                ])
            : c.cardRaised(radius: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(s.icon, color: playing ? c.white : c.accent, size: 24),
            const SizedBox(height: 8),
            Text(s.name,
                style: GoogleFonts.montserrat(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: playing ? c.white : c.textPrimary)),
            Icon(playing ? Icons.pause_circle_rounded : Icons.play_circle_outline_rounded,
                color: playing ? c.white.withValues(alpha: 0.8) : c.textDisabled,
                size: 18),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final DiscoverArticle article;
  const _ArticleCard({required this.article});
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleReadingPage(article: article),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: c.cardRaised(radius: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: c.iconBadge(radius: 12),
              child: Icon(article.icon, color: c.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: c.tagDecoration(radius: 6),
                    child: Text(article.tag,
                        style: GoogleFonts.montserrat(
                            fontSize: 9, fontWeight: FontWeight.w700, color: c.tagText)),
                  ),
                  const SizedBox(width: 8),
                  Text('${article.minutes} мин',
                      style: GoogleFonts.montserrat(fontSize: 11, color: c.textDisabled)),
                ]),
                const SizedBox(height: 7),
                Text(article.title,
                    style: GoogleFonts.montserrat(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: c.textPrimary, height: 1.25)),
                const SizedBox(height: 4),
                Text(article.subtitle,
                    style: GoogleFonts.montserrat(
                        fontSize: 12, color: c.textSecondary, height: 1.35)),
              ]),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: const Color(0xFFBEBECB)),
          ],
        ),
      ),
    );
  }
}

class _SleepTimerBottomSheet extends StatefulWidget {
  final int? initialMinutes;
  final ValueChanged<int> onStart;
  final VoidCallback onCancel;
  final AppColors c;

  const _SleepTimerBottomSheet({
    required this.initialMinutes,
    required this.onStart,
    required this.onCancel,
    required this.c,
  });

  @override
  State<_SleepTimerBottomSheet> createState() => _SleepTimerBottomSheetState();
}

class _SleepTimerBottomSheetState extends State<_SleepTimerBottomSheet> {
  late int _selectedMinutes;
  final List<int> _presets = [5, 15, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.initialMinutes ?? 15;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: c.shadowDark.withValues(alpha: 0.8),
            offset: const Offset(0, -6),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.textDisabled.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Таймер сна',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Выберите время или установите своё:',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _presets.map((min) {
              final active = _selectedMinutes == min;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMinutes = min;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: active
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: c.accentGradient,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: c.accent.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          )
                        : c.cardRaised(radius: 12),
                    child: Center(
                      child: Text(
                        '$min м',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active ? c.white : c.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Своё время:',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: c.textSecondary,
                ),
              ),
              Text(
                '$_selectedMinutes мин',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: c.accent,
              inactiveTrackColor: c.progressBg,
              thumbColor: c.accent,
              overlayColor: c.accent.withValues(alpha: 0.2),
              valueIndicatorColor: c.accent,
              valueIndicatorTextStyle: GoogleFonts.montserrat(color: c.white),
            ),
            child: Slider(
              min: 1,
              max: 120,
              divisions: 120,
              value: _selectedMinutes.toDouble(),
              onChanged: (val) {
                setState(() {
                  _selectedMinutes = val.toInt();
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (widget.initialMinutes != null) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onCancel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: c.cardRaised(radius: 24),
                      child: Center(
                        child: Text(
                          'Сбросить',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: c.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onStart(_selectedMinutes),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: c.accentButton(radius: 24),
                    child: Center(
                      child: Text(
                        'Запустить',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: c.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Soundscape {
  final String name;
  final IconData icon;
  final String audioPath;
  final bool isLocal;
  const _Soundscape(this.name, this.icon, this.audioPath, {required this.isLocal});
}
