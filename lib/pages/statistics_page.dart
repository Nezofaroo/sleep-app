import 'dart:convert';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../database/database_helper.dart';
import '../models/sleep_record.dart';
import '../models/sound_event.dart';
import '../providers/sleep_audio_provider.dart';




class _C {
  static const bg         = Color(0xFF080E1D);
  static const surface    = Color(0xFF111827);
  static const surface2   = Color(0xFF1A2235);
  static const border     = Color(0xFF1E2D4A);
  static const accent     = Color(0xFF4B6BDB);
  static const orange     = Color(0xFFE8A33E);
  static const cream      = Color(0xFFEAEDF2);
  static const muted      = Color(0xFF7A84A8);
  static const mutedDim   = Color(0xFF2D3A52);
  static const phaseDeep  = Color(0xFF9B59B6);
  static const phaseLight = Color(0xFF4B8FE0);
  static const phaseRem   = Color(0xFFE8B840);
  static const phaseWake  = Color(0xFF3FC4C4);
  static const scoreGrad1 = Color(0xFF5B3FD5);
  static const scoreGrad2 = Color(0xFF3B6FDB);
}




const _kWeekRu = ['ВС', 'ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ'];

const _kMonthUpperRu = [
  'ЯНВ', 'ФЕВ', 'МАР', 'АПР', 'МАЯ', 'ИЮН',
  'ИЮЛ', 'АВГ', 'СЕН', 'ОКТ', 'НОЯ', 'ДЕК',
];

const _kMonthGenRu = [
  'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
  'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
];

const _kMonthNomRu = [
  'январь', 'февраль', 'март', 'апрель', 'май', 'июнь',
  'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь',
];







class _Phase {
  final double t;
  final int    p;
  const _Phase(this.t, this.p);
}

// Removed _AudioItem

class _PhaseInfo {
  final String label, percent, duration;
  final Color  color;
  final double fraction;
  const _PhaseInfo(this.label, this.percent, this.duration, this.color, this.fraction);
}





const _kPhases = [
  _Phase(0.00, 3), _Phase(0.30, 1), _Phase(0.80, 0), _Phase(1.30, 1),
  _Phase(1.70, 2), _Phase(2.20, 1), _Phase(2.70, 0), _Phase(3.20, 3),
  _Phase(3.30, 1), _Phase(3.70, 2), _Phase(4.20, 1), _Phase(4.70, 3),
  _Phase(4.90, 2), _Phase(5.40, 1), _Phase(5.90, 2), _Phase(6.40, 1),
  _Phase(6.90, 3), _Phase(7.10, 2), _Phase(7.60, 1), _Phase(8.10, 2),
  _Phase(8.60, 3), _Phase(8.80, 2), _Phase(9.30, 1), _Phase(9.80, 2),
  _Phase(10.50, 3),
];

const _kPhaseInfos = [
  _PhaseInfo('Глубокий',      '18%', '1 ч. 59 мин', _C.phaseDeep,  0.18),
  _PhaseInfo('Неглубокий сон','52%', '5 ч. 34 мин', _C.phaseLight, 0.52),
  _PhaseInfo('REM',           '16%', '1 ч. 45 мин', _C.phaseRem,   0.16),
  _PhaseInfo('Бодрствование', '14%', '1 ч. 28 мин', _C.phaseWake,  0.14),
];

// Removed mock audio data lists






int _dowIndex(DateTime d) => d.weekday % 7;


DateTime _weekSunday(DateTime d) =>
    DateUtils.dateOnly(d).subtract(Duration(days: _dowIndex(d)));

int _qualityScore(String? q) => switch (q) {
  'Poor'      => 30,
  'Fair'      => 55,
  'Good'      => 74,
  'Excellent' => 92,
  _           => 0,
};

Color _phaseColor(int p) => switch (p) {
  0 => _C.phaseDeep,
  1 => _C.phaseLight,
  2 => _C.phaseRem,
  _ => _C.phaseWake,
};

String _fmtDuration(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return h == 0 ? '$m мин' : '$h ч. $m мин';
}





class StatisticsPage extends StatefulWidget {
  final SleepAudioProvider audioProvider;
  const StatisticsPage({super.key, required this.audioProvider});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {

  int      _topTab        = 0;
  DateTime _selectedDate  = DateUtils.dateOnly(DateTime.now());
  bool     _showCalendar  = false;
  late DateTime _weekStart;


  int      _periodTab     = 0;
  late DateTime _statWeek;
  late DateTime _statMonth;
  int      _bedtimeTab    = 0;


  SoundEventType? _selectedCategoryFilter;
  final Set<SoundEventType> _expandedCategories = {
    SoundEventType.snore,
    SoundEventType.talk
  };


  final _db = DatabaseHelper();
  List<SleepRecord> _records = [];
  bool _loading = true;


  @override
  void initState() {
    super.initState();
    _weekStart = _weekSunday(_selectedDate);
    _statWeek  = _weekStart;
    _statMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final recs = await _db.getAllRecords();
    if (mounted) {
      setState(() {
        _records = recs;
        _loading = false;
      });
    }
  }


  SleepRecord? _recordForDate(DateTime d) {
    final day = DateUtils.dateOnly(d);
    try {
      return _records.lastWhere(
        (r) => DateUtils.dateOnly(r.startTime) == day,
      );
    } catch (_) { return null; }
  }

  List<SleepRecord> _weekRecords(DateTime sun) {
    final end = sun.add(const Duration(days: 7));
    return _records.where((r) =>
        !r.startTime.isBefore(sun) && r.startTime.isBefore(end)).toList();
  }

  List<SleepRecord> _monthRecords(DateTime month) => _records
      .where((r) =>
          r.startTime.year == month.year &&
          r.startTime.month == month.month)
      .toList();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: _C.accent),
                ),
              )
            else
              Expanded(
                child: _topTab == 0 ? _buildJournal() : _buildStatistics(),
              ),
          ],
        ),
      ),
    );
  }




  Widget _buildTopBar() {
    return Container(
      color: _C.bg,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Row(children: [
        _topTab_(label: 'Журнал',     index: 0),
        const SizedBox(width: 24),
        _topTab_(label: 'Статистика', index: 1),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _showCalendar = !_showCalendar),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _C.border),
            ),
            child: Icon(
              _showCalendar
                  ? Icons.calendar_month_rounded
                  : Icons.calendar_today_rounded,
              color: _showCalendar ? _C.orange : _C.muted,
              size: 18,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _topTab_({required String label, required int index}) {
    final active = _topTab == index;
    return GestureDetector(
      onTap: () => setState(() {
        _topTab = index;
        _showCalendar = false;
      }),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: GoogleFonts.montserrat(
                fontSize: 17,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? _C.cream : _C.muted)),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 2,
          width: active ? 30 : 0,
          decoration: BoxDecoration(
            color: _C.orange,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ]),
    );
  }




  Widget _buildJournal() {
    final rec = _recordForDate(_selectedDate);

    final allEvents = widget.audioProvider.allRecords;
    final dayEvents = allEvents.where((e) {
      if (rec != null) {
        final start = rec.startTime;
        final end = rec.endTime ?? start.add(const Duration(hours: 12));
        return !e.startTime.isBefore(start) && !e.startTime.isAfter(end);
      } else {
        return DateUtils.dateOnly(e.startTime) == _selectedDate;
      }
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildWeekStrip()),
        if (_showCalendar) SliverToBoxAdapter(child: _buildFullCalendar()),
        SliverToBoxAdapter(child: _buildTimeRangeBadge(rec)),
        SliverToBoxAdapter(child: _buildScoreCard(rec)),
        SliverToBoxAdapter(child: _buildStageSectionHeader()),
        SliverToBoxAdapter(child: _buildStageGraph()),
        SliverToBoxAdapter(child: _buildPhaseGrid()),
        SliverToBoxAdapter(child: _buildSummaryTiles(rec, dayEvents)),
        SliverToBoxAdapter(child: _buildNotesSection(rec)),
        SliverToBoxAdapter(child: _buildFragmentSection(dayEvents)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }


  Widget _buildNotesSection(SleepRecord? rec) {
    if (rec == null) return const SizedBox.shrink();

    List<String> factors = [];
    String? mood;
    if (rec.notes != null && rec.notes!.isNotEmpty) {
      try {
        final Map<String, dynamic> notesMap = jsonDecode(rec.notes!);
        if (notesMap['factors'] != null) {
          factors = List<String>.from(notesMap['factors']);
        }
        mood = notesMap['mood'] as String?;
      } catch (_) {}
    }

    String moodLabel = 'Нейтрально';
    if (mood != null) {
      moodLabel = switch (mood) {
        '😴' => 'Очень плохо',
        '😕' => 'Плохо',
        '😐' => 'Нейтрально',
        '🙂' => 'Хорошо',
        '😄' => 'Отлично',
        _    => 'Нейтрально',
      };
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Заметки',
              style: GoogleFonts.montserrat(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _C.cream)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _C.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Заметки о сне',
                        style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _C.muted)),
                    GestureDetector(
                      onTap: () => _editRecordFactors(rec, factors),
                      child: const Icon(Icons.edit_outlined, size: 16, color: _C.accent),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (factors.isEmpty)
                  Text('Нет заметок о факторах сна',
                      style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: _C.muted.withValues(alpha: 0.7)))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: factors.map((f) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _C.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _C.accent.withValues(alpha: 0.5)),
                      ),
                      child: Text(f,
                          style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _C.accent)),
                    )).toList(),
                  ),
                const Divider(color: _C.border, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Настроение во время просыпания',
                        style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _C.muted)),
                    GestureDetector(
                      onTap: () => _editRecordMood(rec, mood),
                      child: const Icon(Icons.edit_outlined, size: 16, color: _C.accent),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (mood == null)
                  Text('Не указано',
                      style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: _C.muted.withValues(alpha: 0.7)))
                else
                  Row(
                    children: [
                      Text(moodLabel,
                          style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _C.cream)),
                      const SizedBox(width: 6),
                      Text(mood, style: const TextStyle(fontSize: 18)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editRecordFactors(SleepRecord rec, List<String> currentFactors) {
    final settings = Hive.box('settings');
    final List<String> allFactors = List<String>.from(
      settings.get('sleepFactorsList', defaultValue: [
        'Боль',
        'Легкий сон',
        'Медитация',
        'Болезнь',
        'Плотный прием пищи',
        'Теплая ванна',
        'Таблетка снотворного',
        'Алкоголь',
        'Тренировка',
        'Растяжка',
        'Поздний прием пищи',
        'Состояние стресса',
        'Кофе'
      ])
    );

    List<String> selected = List<String>.from(currentFactors);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            return AlertDialog(
              backgroundColor: _C.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: _C.border)),
              title: Text('Факторы сна',
                  style: GoogleFonts.montserrat(
                      color: _C.cream, fontWeight: FontWeight.w700, fontSize: 16)),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allFactors.map((factor) {
                      final isSel = selected.contains(factor);
                      return GestureDetector(
                        onTap: () {
                          setS(() {
                            if (isSel) {
                              selected.remove(factor);
                            } else {
                              selected.add(factor);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? _C.accent.withValues(alpha: 0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSel ? _C.accent : _C.border,
                            ),
                          ),
                          child: Text(
                            factor,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                              color: isSel ? _C.accent : _C.muted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Отмена', style: GoogleFonts.montserrat(color: _C.muted)),
                ),
                TextButton(
                  onPressed: () async {
                    Map<String, dynamic> notesMap = {};
                    if (rec.notes != null && rec.notes!.isNotEmpty) {
                      try {
                        notesMap = Map<String, dynamic>.from(jsonDecode(rec.notes!));
                      } catch (_) {}
                    }
                    notesMap['factors'] = selected;

                    await DatabaseHelper().updateSleepRecord(
                      rec.copyWith(notes: jsonEncode(notesMap))
                    );
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                  child: Text('Сохранить', style: GoogleFonts.montserrat(color: _C.accent)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editRecordMood(SleepRecord rec, String? currentMood) {
    String? selected = currentMood;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            return AlertDialog(
              backgroundColor: _C.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: _C.border)),
              title: Text('Настроение при пробуждении',
                  style: GoogleFonts.montserrat(
                      color: _C.cream, fontWeight: FontWeight.w700, fontSize: 16)),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['😴', '😕', '😐', '🙂', '😄'].map((e) =>
                  GestureDetector(
                    onTap: () => setS(() => selected = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected == e ? _C.accent.withValues(alpha: 0.15) : Colors.transparent,
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 32)),
                    ),
                  )).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Отмена', style: GoogleFonts.montserrat(color: _C.muted)),
                ),
                TextButton(
                  onPressed: () async {
                    Map<String, dynamic> notesMap = {};
                    if (rec.notes != null && rec.notes!.isNotEmpty) {
                      try {
                        notesMap = Map<String, dynamic>.from(jsonDecode(rec.notes!));
                      } catch (_) {}
                    }
                    if (selected != null) {
                      notesMap['mood'] = selected;
                    } else {
                      notesMap.remove('mood');
                    }

                    await DatabaseHelper().updateSleepRecord(
                      rec.copyWith(notes: notesMap.isNotEmpty ? jsonEncode(notesMap) : null)
                    );
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                  child: Text('Сохранить', style: GoogleFonts.montserrat(color: _C.accent)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWeekStrip() {
    return Container(
      color: _C.bg,
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      child: Row(
        children: List.generate(7, (i) {
          final day = _weekStart.add(Duration(days: i));
          final sel = DateUtils.dateOnly(day) == _selectedDate;
          return Expanded(
            child: _WeekDayCell(
              day: day,
              isSelected: sel,
              onTap: () => setState(() {
                _selectedDate = DateUtils.dateOnly(day);
                _weekStart    = _weekSunday(day);
              }),
            ),
          );
        }),
      ),
    );
  }


  Widget _buildFullCalendar() {
    return Container(
      color: _C.bg,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: _FullCalendarWidget(
        displayedMonth: DateTime(_selectedDate.year, _selectedDate.month),
        selectedDate: _selectedDate,
        onDateSelected: (d) => setState(() {
          _selectedDate = d;
          _weekStart    = _weekSunday(d);
        }),
      ),
    );
  }


  Widget _buildTimeRangeBadge(SleepRecord? rec) {
    final fmt = DateFormat('hh:mm a');
    final text = (rec?.endTime != null)
        ? '${fmt.format(rec!.startTime)}-${fmt.format(rec.endTime!)}'
        : 'Нет данных';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _C.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.bed_rounded, size: 16, color: _C.muted),
          const SizedBox(width: 8),
          Text(text,
              style: GoogleFonts.montserrat(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _C.cream)),
        ]),
      ),
    );
  }


  Widget _buildScoreCard(SleepRecord? rec) {
    final score = rec != null ? _qualityScore(rec.quality) : 74;
    final label = switch (score) {
      >= 90 => 'Отлично',
      >= 75 => 'Хорошо',
      >= 60 => 'Посредственный',
      >= 40 => 'Плохо',
      _     => 'Нет данных',
    };
    final labelColor = switch (score) {
      >= 90 => const Color(0xFF66BB6A),
      >= 75 => const Color(0xFF8FDB6B),
      >= 60 => _C.orange,
      _     => const Color(0xFFDB5F6F),
    };
    final desc = rec != null
        ? 'Ваш сон был нормальным — но недостаточным\nдля полного восстановления.'
        : 'Начните трекинг, чтобы увидеть данные.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_C.scoreGrad1, _C.scoreGrad2],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: _C.scoreGrad1.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$score',
                  style: GoogleFonts.montserrat(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0)),
              const SizedBox(height: 2),
              Row(children: [
                Text(label,
                    style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: labelColor)),
                const SizedBox(width: 6),
                _InfoButton(onTap: _showScoreInfoDialog),
              ]),
            ]),
            const Spacer(),

            _NeutralFace(score: score),
          ]),
          const SizedBox(height: 14),

          _QualityBar(score: score),
          const SizedBox(height: 12),
          Text(desc,
              style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.5)),
        ]),
      ),
    );
  }

  void _showScoreInfoDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _C.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('О баллах сна',
            style: GoogleFonts.montserrat(
                color: _C.cream, fontWeight: FontWeight.w700)),
        content: Text(
          'Балл качества сна рассчитывается на основе '
          'продолжительности сна, его структуры (фазы), '
          'количества пробуждений и других факторов.\n\n'
          'Шкала: 0–40 Плохо · 40–60 Посредственно · '
          '60–80 Хорошо · 80–100 Отлично.',
          style: GoogleFonts.montserrat(
              color: _C.muted, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Понятно',
                style: GoogleFonts.montserrat(color: _C.accent)),
          ),
        ],
      ),
    );
  }


  Widget _buildStageSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(children: [
        Text('Фазы сна',
            style: GoogleFonts.montserrat(
                fontSize: 16, fontWeight: FontWeight.w700, color: _C.cream)),
        const SizedBox(width: 6),
        _InfoButton(onTap: () {}),
      ]),
    );
  }


  Widget _buildStageGraph() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border),
        ),
        child: Column(children: [

          SizedBox(
            height: 170,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 10, 10, 0),
              child: Row(children: [

                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _phaseYLabel('Бодрст-\nвование', _C.phaseWake),
                      _phaseYLabel('REM',       _C.phaseRem),
                      _phaseYLabel('Неглу-\nбокий',    _C.phaseLight),
                      _phaseYLabel('Глуб-\nокий',      _C.phaseDeep),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                Expanded(
                  child: CustomPaint(
                    painter: _SleepStagePainter(phases: _kPhases),
                  ),
                ),
              ]),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 10, 10),
            child: Row(children: [
              Text('Время',
                  style: GoogleFonts.montserrat(fontSize: 8, color: _C.muted)),
              const SizedBox(width: 2),
              ...List.generate(11, (i) {
                final label = (i + 2).toString();
                final subLabel = i == 0
                    ? 'AM'
                    : i == 10
                        ? 'PM'
                        : '';
                return Expanded(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(label,
                        style: GoogleFonts.montserrat(
                            fontSize: 9, color: _C.muted),
                        textAlign: TextAlign.center),
                    if (subLabel.isNotEmpty)
                      Text(subLabel,
                          style: GoogleFonts.montserrat(
                              fontSize: 7, color: _C.muted),
                          textAlign: TextAlign.center),
                  ]),
                );
              }),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _phaseYLabel(String text, Color color) {
    return SizedBox(
      width: 44,
      child: Text(text,
          style: GoogleFonts.montserrat(fontSize: 8, color: color, height: 1.2),
          textAlign: TextAlign.right),
    );
  }


  Widget _buildPhaseGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border),
        ),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.4,
          padding: const EdgeInsets.all(14),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          children: _kPhaseInfos.map((p) => _PhaseDonutTile(info: p)).toList(),
        ),
      ),
    );
  }


  Widget _buildSummaryTiles(SleepRecord? rec, List<SoundEvent> dayEvents) {
    final inBedStr   = rec?.endTime != null
        ? _fmtDuration(rec!.endTime!.difference(rec.startTime).inMinutes)
        : '—';
    final sleepStr   = rec?.durationMinutes != null
        ? _fmtDuration(rec!.durationMinutes!)
        : '—';
    final asleepStr  = rec != null
        ? DateFormat('hh:mm a').format(rec.startTime)
        : '—';
    final noiseCount = dayEvents.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(children: [
        Row(children: [
          Expanded(child: _SummaryTile(
            icon: Icons.nightlight_round,
            iconColor: _C.accent,
            title: 'В кровати',
            value: inBedStr,
            chevron: true,
          )),
          const SizedBox(width: 12),
          Expanded(child: _SummaryTile(
            icon: Icons.bedtime_rounded,
            iconColor: _C.orange,
            title: 'Время сна',
            value: sleepStr,
            chevron: true,
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _SummaryTile(
            icon: Icons.alarm_rounded,
            iconColor: const Color(0xFF66BB6A),
            title: 'Засыпание',
            value: asleepStr,
          )),
          const SizedBox(width: 12),
          Expanded(child: _SummaryTile(
            icon: Icons.graphic_eq_rounded,
            iconColor: _C.phaseDeep,
            title: 'Шум',
            value: '$noiseCount эпизодов',
          )),
        ]),
        const SizedBox(height: 12),
        _SleepDebtTile(),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.graphic_eq_rounded, size: 36, color: _C.muted.withValues(alpha: 0.4)),
            const SizedBox(height: 8),
            Text(
              'Нет фрагментов за этот день',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _C.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _generateDeterministicWaveform(String id) {
    final seed = id.hashCode;
    final r = math.Random(seed);
    return List.generate(40, (_) => 0.15 + r.nextDouble() * 0.85);
  }

  Widget _buildFragmentSection(List<SoundEvent> dayEvents) {
    return ListenableBuilder(
      listenable: widget.audioProvider,
      builder: (context, _) {
        final Map<SoundEventType, List<SoundEvent>> grouped = {};
        for (final e in dayEvents) {
          grouped.putIfAbsent(e.type, () => []).add(e);
        }

        for (final key in grouped.keys) {
          grouped[key]!.sort((a, b) => a.startTime.compareTo(b.startTime));
        }

        final totalEvents = dayEvents.length;
        final categories = SoundEventType.values;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Фрагменты',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _C.cream,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _C.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _C.accent.withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '$totalEvents',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _C.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((type) {
                    final active = _selectedCategoryFilter == type;
                    final count = grouped[type]?.length ?? 0;
                    final label = count > 0 ? '${type.label} ($count)' : type.label;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryFilter = active ? null : type;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                            color: active ? _C.accent : _C.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: active ? _C.accent : _C.border,
                            ),
                          ),
                          child: Text(
                            label,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: active ? Colors.white : _C.muted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              if (totalEvents == 0)
                _buildEmptyState()
              else
                ...categories.map((type) {
                  if (_selectedCategoryFilter != null && _selectedCategoryFilter != type) {
                    return const SizedBox.shrink();
                  }

                  final events = grouped[type] ?? [];
                  if (_selectedCategoryFilter == null && events.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final count = events.length;
                  final isExpanded = _expandedCategories.contains(type);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _C.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _C.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedCategories.remove(type);
                                } else {
                                  _expandedCategories.add(type);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Text(
                                    '${type.emoji} ${type.label}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _C.cream,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (count > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _C.muted.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$count',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: _C.muted,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: _C.muted,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded) ...[
                            const Divider(color: _C.border, height: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: events.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: Text(
                                          'Нет фрагментов этого типа',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            color: _C.muted,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: events.map((e) => _buildFragmentTile(e)).toList(),
                                    ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFragmentTile(SoundEvent event) {
    final isPlaying = widget.audioProvider.isPlaying(event.id);
    final isActive = widget.audioProvider.currentlyPlayingId == event.id;
    final progress = isActive ? (widget.audioProvider.playProgress ?? 0.0) : 0.0;
    final typeColor = _C.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => widget.audioProvider.playEvent(event),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: _C.cream,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              DateFormat('HH:mm').format(event.startTime),
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _C.cream,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 24,
                child: CustomPaint(
                  painter: _WaveformPainter(
                    values: _generateDeterministicWaveform(event.id),
                    color: typeColor,
                    progress: progress,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showFragmentMenu(event),
              child: const Icon(
                Icons.more_vert_rounded,
                color: _C.muted,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFragmentMenu(SoundEvent event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: _C.mutedDim,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          _sheetItem(Icons.delete_outline_rounded, 'Удалить',
              const Color(0xFFDB5F6F), () async {
            Navigator.pop(context);
            _confirmDeleteFragment(event);
          }),
          _sheetItem(Icons.share_rounded, 'Поделиться', _C.cream,
              () => Navigator.pop(context)),
          _sheetItem(Icons.note_add_outlined, 'Добавить заметку', _C.cream,
              () => Navigator.pop(context)),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _confirmDeleteFragment(SoundEvent event) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: _C.bg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: _C.border)),
          title: Text(
            'Удалить фрагмент?',
            style: GoogleFonts.montserrat(
                color: _C.cream, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          content: Text(
            'Вы уверены, что хотите удалить эту запись?',
            style: GoogleFonts.montserrat(color: _C.muted, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Отмена', style: GoogleFonts.montserrat(color: _C.muted)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await widget.audioProvider.deleteEvent(event);
                setState(() {});
              },
              child: Text('Удалить', style: GoogleFonts.montserrat(color: const Color(0xFFDB5F6F))),
            ),
          ],
        );
      },
    );
  }

  Widget _sheetItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label,
          style: GoogleFonts.montserrat(color: color, fontSize: 14)),
      onTap: onTap,
    );
  }




  Widget _buildStatistics() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildPeriodToggle()),
        SliverToBoxAdapter(child: _buildDateRangeNav()),
        SliverToBoxAdapter(child: _buildSleepQualitySection()),
        SliverToBoxAdapter(child: _buildBedtimeSection()),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }


  Widget _buildPeriodToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.border),
        ),
        child: Row(
          children: [
            _periodBtn('Неделя', 0),
            _periodBtn('Месяц',  1),
          ],
        ),
      ),
    );
  }

  Widget _periodBtn(String label, int index) {
    final active = _periodTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _periodTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: active ? _C.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label,
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : _C.muted)),
          ),
        ),
      ),
    );
  }


  Widget _buildDateRangeNav() {
    String rangeText;
    int year;
    if (_periodTab == 0) {
      final end = _statWeek.add(const Duration(days: 6));
      final sm  = _kMonthUpperRu[_statWeek.month - 1];
      final em  = _kMonthUpperRu[end.month - 1];
      rangeText = '$sm ${_statWeek.day}–$em ${end.day}';
      year      = _statWeek.year;
    } else {
      rangeText = _kMonthGenRu[_statMonth.month - 1];
      year      = _statMonth.year;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(
            onTap: () => setState(() {
              if (_periodTab == 0) {
                _statWeek = _statWeek.subtract(const Duration(days: 7));
              } else {
                _statMonth = DateTime(_statMonth.year, _statMonth.month - 1);
              }
            }),
            child: const Icon(Icons.chevron_left_rounded,
                color: _C.muted, size: 26),
          ),
          const SizedBox(width: 16),
          Text(rangeText,
              style: GoogleFonts.montserrat(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _C.cream)),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => setState(() {
              if (_periodTab == 0) {
                _statWeek = _statWeek.add(const Duration(days: 7));
              } else {
                _statMonth = DateTime(_statMonth.year, _statMonth.month + 1);
              }
            }),
            child: const Icon(Icons.chevron_right_rounded,
                color: _C.muted, size: 26),
          ),
        ]),
        Text('$year',
            style: GoogleFonts.montserrat(fontSize: 11, color: _C.muted)),
      ]),
    );
  }


  Widget _buildSleepQualitySection() {
    final recs   = _periodTab == 0
        ? _weekRecords(_statWeek)
        : _monthRecords(_statMonth);
    final scores = recs.map((r) => _qualityScore(r.quality).toDouble()).toList();
    final maxVal = scores.isEmpty ? 74.0 : scores.reduce(math.max);
    final minVal = scores.isEmpty ? 74.0 : scores.reduce(math.min);
    final avgVal = scores.isEmpty
        ? 74.0
        : scores.fold(0.0, (a, b) => a + b) / scores.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Качество сна',
              style: GoogleFonts.montserrat(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _C.cream)),
          const SizedBox(width: 6),
          _InfoButton(onTap: () {}),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.border),
          ),
          child: Column(children: [

            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _legendDot('Макс.', maxVal.round(), _C.orange),
                const SizedBox(height: 4),
                _legendDot('Мин.',  minVal.round(), _C.accent),
              ]),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('Ср.',
                    style: GoogleFonts.montserrat(fontSize: 11, color: _C.muted)),
                Text('${avgVal.round()}',
                    style: GoogleFonts.montserrat(
                        fontSize: 30, fontWeight: FontWeight.w900, color: _C.cream)),
              ]),
            ]),
            const SizedBox(height: 16),

            SizedBox(height: 160, child: _buildBarChart(recs)),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _C.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.border),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.show_chart_rounded, color: _C.orange, size: 18),
                  const SizedBox(width: 8),
                  Text('Общий анализ',
                      style: GoogleFonts.montserrat(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: _C.cream)),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _legendDot(String label, int value, Color color) {
    return Row(children: [
      Container(width: 8, height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 6),
      Text(label,
          style: GoogleFonts.montserrat(fontSize: 12, color: _C.muted)),
      const SizedBox(width: 4),
      Text('$value',
          style: GoogleFonts.montserrat(
              fontSize: 13, fontWeight: FontWeight.w700, color: _C.cream)),
    ]);
  }

  Widget _buildBarChart(List<SleepRecord> recs) {
    List<double> values;
    List<String> labels;
    double barWidth;

    if (_periodTab == 0) {

      values = List.filled(7, 0.0);
      for (final r in recs) {
        values[_dowIndex(r.startTime)] = _qualityScore(r.quality).toDouble();
      }

      if (values.every((v) => v == 0) && _records.isEmpty) {
        values[5] = 74.0;
      }
      labels   = _kWeekRu.toList();
      barWidth = 22;
    } else {

      final days = DateUtils.getDaysInMonth(_statMonth.year, _statMonth.month);
      values = List.filled(days, 0.0);
      for (final r in recs) {
        final d = r.startTime.day - 1;
        if (d < days) values[d] = _qualityScore(r.quality).toDouble();
      }
      if (values.every((v) => v == 0) && _records.isEmpty) {
        final today = DateTime.now();
        if (today.year == _statMonth.year && today.month == _statMonth.month) {
          values[today.day - 1] = 74.0;
        }
      }
      labels   = List.generate(days, (i) => '${i + 1}');
      barWidth = 6;
    }

    final barGroups = <BarChartGroupData>[
      for (int i = 0; i < values.length; i++)
        BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY: values[i],
            color: _C.accent,
            width: barWidth,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true, toY: 100, color: _C.surface2),
          ),
        ]),
    ];

    return BarChart(BarChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 25,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: _C.border, strokeWidth: 1, dashArray: [4, 4]),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 25,
          getTitlesWidget: (v, _) => Text('${v.round()}',
              style: GoogleFonts.montserrat(fontSize: 9, color: _C.muted)),
        )),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            final i = v.round();
            if (i < 0 || i >= labels.length) return const SizedBox();
            if (_periodTab == 1 && i % 5 != 0) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(labels[i],
                  style: GoogleFonts.montserrat(
                      fontSize: _periodTab == 0 ? 10 : 8, color: _C.muted),
                  textAlign: TextAlign.center),
            );
          },
        )),
      ),
      barGroups: barGroups,
      maxY: 100,
    ));
  }


  Widget _buildBedtimeSection() {

    final recs   = _periodTab == 0
        ? _weekRecords(_statWeek)
        : _monthRecords(_statMonth);
    final fmt    = DateFormat('hh:mm a');

    String earliest = '—', latest = '—', avg = '—';
    if (recs.isNotEmpty) {
      final sorted = recs
          .map((r) => _bedtimeTab == 0 ? r.startTime : r.startTime)
          .toList()
        ..sort((a, b) => a.hour != b.hour ? a.hour - b.hour : a.minute - b.minute);
      earliest = fmt.format(sorted.first);
      latest   = fmt.format(sorted.last);
      final totalMin = sorted
          .map((t) => t.hour * 60 + t.minute)
          .fold(0, (a, b) => a + b);
      final avgMin   = totalMin ~/ sorted.length;
      final h        = avgMin ~/ 60;
      final m        = avgMin % 60;
      avg = DateFormat('hh:mm a')
          .format(DateTime(2000, 1, 1, h, m));
    } else {
      earliest = '01:04 AM';
      latest   = '01:04 AM';
      avg      = '01:04 AM';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Flexible(
            child: Text('Время отхода ко сну / пробуждения',
                style: GoogleFonts.montserrat(
                    fontSize: 14, fontWeight: FontWeight.w700, color: _C.cream)),
          ),
          const SizedBox(width: 6),
          _InfoButton(onTap: () {}),
        ]),
        const SizedBox(height: 12),

        Row(children: [
          _bedtimeTabBtn('Укладывание в кровать', 0),
          const SizedBox(width: 8),
          _bedtimeTabBtn('Засыпание', 1),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.border),
          ),
          child: Column(children: [
            _bedtimeRow('Самые\nранние',  _C.orange, earliest, 'Ср. $avg'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: _C.border, height: 1),
            ),
            _bedtimeRow('Самые\nпоздние', _C.accent, latest, null),
          ]),
        ),
      ]),
    );
  }

  Widget _bedtimeTabBtn(String label, int index) {
    final active = _bedtimeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _bedtimeTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? _C.accent : _C.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: active ? _C.accent : _C.border),
        ),
        child: Text(label,
            style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : _C.muted)),
      ),
    );
  }

  Widget _bedtimeRow(String label, Color dotColor, String value, String? avgLabel) {
    return Row(children: [
      Container(
          width: 8, height: 8,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: dotColor)),
      const SizedBox(width: 8),
      SizedBox(
        width: 72,
        child: Text(label,
            style: GoogleFonts.montserrat(
                fontSize: 11, color: _C.muted, height: 1.3)),
      ),
      Text(value,
          style: GoogleFonts.montserrat(
              fontSize: 16, fontWeight: FontWeight.w700, color: _C.cream)),
      const Spacer(),
      if (avgLabel != null)
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('Ср.',
              style: GoogleFonts.montserrat(fontSize: 10, color: _C.muted)),
          Text(avgLabel,
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w700, color: _C.cream)),
        ]),
    ]);
  }
}





class _InfoButton extends StatelessWidget {
  final VoidCallback onTap;
  const _InfoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 18, height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _C.muted.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: Text('i',
              style: GoogleFonts.montserrat(
                  fontSize: 10, color: _C.muted,
                  fontStyle: FontStyle.italic)),
        ),
      ),
    );
  }
}


class _NeutralFace extends StatelessWidget {
  final int score;
  const _NeutralFace({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68, height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(44, 44),
          painter: _FacePainter(score: score),
        ),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  final int score;
  const _FacePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;


    canvas.drawCircle(
        Offset(cx, cy), r,
        Paint()..color = const Color(0xFFF5F5F5));


    final eyeP = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(Offset(cx - 8, cy - 5), 3, eyeP);
    canvas.drawCircle(Offset(cx + 8, cy - 5), 3, eyeP);


    final mouthP = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (score >= 80) {

      path.moveTo(cx - 10, cy + 4);
      path.quadraticBezierTo(cx, cy + 14, cx + 10, cy + 4);
    } else if (score >= 60) {

      path.moveTo(cx - 9, cy + 9);
      path.lineTo(cx + 9, cy + 9);
    } else {

      path.moveTo(cx - 10, cy + 12);
      path.quadraticBezierTo(cx, cy + 4, cx + 10, cy + 12);
    }
    canvas.drawPath(path, mouthP);
  }

  @override
  bool shouldRepaint(covariant _FacePainter old) => old.score != score;
}


class _QualityBar extends StatelessWidget {
  final int score;
  const _QualityBar({required this.score});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final trackW = constraints.maxWidth;
      final thumbX = (score / 100.0 * trackW).clamp(8.0, trackW - 8.0);
      return SizedBox(
        height: 18,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            top: 5, left: 0, right: 0,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(colors: [
                  Color(0xFFDB3F3F),
                  Color(0xFFDB803F),
                  Color(0xFF8888AA),
                  Color(0xFF3F6FDB),
                ]),
              ),
            ),
          ),
          Positioned(
            top: 0, left: thumbX - 9,
            child: Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.orange,
                boxShadow: [
                  BoxShadow(
                      color: _C.orange.withValues(alpha: 0.5),
                      blurRadius: 8),
                ],
              ),
            ),
          ),
        ]),
      );
    });
  }
}


class _WeekDayCell extends StatelessWidget {
  final DateTime day;
  final bool isSelected;
  final VoidCallback onTap;
  const _WeekDayCell({required this.day, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dow = day.weekday % 7;
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 38, height: 38,
          decoration: isSelected
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _C.orange, width: 2.5),
                )
              : null,
          child: Center(
            child: Text('${day.day}',
                style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? _C.orange : _C.cream)),
          ),
        ),
        const SizedBox(height: 3),
        Text(_kWeekRu[dow],
            style: GoogleFonts.montserrat(fontSize: 10, color: _C.muted)),
      ]),
    );
  }
}


class _FullCalendarWidget extends StatefulWidget {
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  const _FullCalendarWidget({
    required this.displayedMonth,
    required this.selectedDate,
    required this.onDateSelected,
  });
  @override
  State<_FullCalendarWidget> createState() => _FullCalendarWidgetState();
}

class _FullCalendarWidgetState extends State<_FullCalendarWidget> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = widget.displayedMonth;
  }

  @override
  Widget build(BuildContext context) {
    final firstDay     = DateTime(_month.year, _month.month, 1);
    final firstDow     = firstDay.weekday % 7;
    final daysInMonth  = DateUtils.getDaysInMonth(_month.year, _month.month);
    final totalCells   = firstDow + daysInMonth;
    final rows         = (totalCells / 7).ceil();

    return Column(children: [

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(
          onTap: () => setState(
              () => _month = DateTime(_month.year, _month.month - 1)),
          child: const Icon(Icons.chevron_left_rounded, color: _C.muted),
        ),
        Column(children: [
          Text(_kMonthNomRu[_month.month - 1],
              style: GoogleFonts.montserrat(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _C.cream)),
          Text('${_month.year}',
              style: GoogleFonts.montserrat(fontSize: 12, color: _C.muted)),
        ]),
        GestureDetector(
          onTap: () => setState(
              () => _month = DateTime(_month.year, _month.month + 1)),
          child: const Icon(Icons.chevron_right_rounded, color: _C.muted),
        ),
      ]),
      const SizedBox(height: 14),


      Row(children: _kWeekRu.map((d) => Expanded(
        child: Center(
          child: Text(d,
              style: GoogleFonts.montserrat(
                  fontSize: 11, color: _C.muted, fontWeight: FontWeight.w600)),
        ),
      )).toList()),
      const SizedBox(height: 6),


      for (int r = 0; r < rows; r++)
        Row(children: List.generate(7, (c) {
          final dayNum = r * 7 + c - firstDow + 1;
          if (dayNum < 1 || dayNum > daysInMonth) {
            return const Expanded(child: SizedBox(height: 44));
          }
          final date = DateTime(_month.year, _month.month, dayNum);
          final sel  = DateUtils.dateOnly(date) ==
              DateUtils.dateOnly(widget.selectedDate);
          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onDateSelected(date),
              child: SizedBox(
                height: 46,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 36, height: 36,
                    decoration: sel
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: _C.orange, width: 2.5),
                          )
                        : null,
                    child: Center(
                      child: Text('$dayNum',
                          style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: sel
                                  ? FontWeight.w800
                                  : FontWeight.w400,
                              color: sel ? _C.orange : _C.cream)),
                    ),
                  ),
                ),
              ),
            ),
          );
        })),
    ]);
  }
}


class _PhaseDonutTile extends StatelessWidget {
  final _PhaseInfo info;
  const _PhaseDonutTile({required this.info});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 46, height: 46,
        child: PieChart(PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 14,
          sections: [
            PieChartSectionData(
              value: info.fraction * 100,
              color: info.color,
              radius: 9,
              showTitle: false,
            ),
            PieChartSectionData(
              value: (1 - info.fraction) * 100,
              color: _C.mutedDim,
              radius: 9,
              showTitle: false,
            ),
          ],
        )),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(info.label,
                style: GoogleFonts.montserrat(
                    fontSize: 10, color: _C.muted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(info.percent,
                style: GoogleFonts.montserrat(
                    fontSize: 17, fontWeight: FontWeight.w800, color: _C.cream)),
            Text(info.duration,
                style: GoogleFonts.montserrat(
                    fontSize: 9, color: _C.muted)),
          ],
        ),
      ),
    ]);
  }
}


class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   title, value;
  final bool     chevron;
  const _SummaryTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.chevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: iconColor, size: 18),
          const Spacer(),
          if (chevron)
            const Icon(Icons.chevron_right_rounded, color: _C.muted, size: 16),
        ]),
        const SizedBox(height: 10),
        Text(title,
            style: GoogleFonts.montserrat(fontSize: 11, color: _C.muted)),
        const SizedBox(height: 3),
        Text(value,
            style: GoogleFonts.montserrat(
                fontSize: 15, fontWeight: FontWeight.w800, color: _C.cream)),
      ]),
    );
  }
}


class _SleepDebtTile extends StatelessWidget {
  const _SleepDebtTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1832),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A3256)),
      ),
      child: Row(children: [
        const Icon(Icons.arrow_downward_rounded, color: _C.accent, size: 20),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Нехватка сна',
              style: GoogleFonts.montserrat(fontSize: 11, color: _C.muted)),
          Text('—',
              style: GoogleFonts.montserrat(
                  fontSize: 18, fontWeight: FontWeight.w800, color: _C.cream)),
        ]),
      ]),
    );
  }
}






class _SleepStagePainter extends CustomPainter {
  final List<_Phase> phases;
  const _SleepStagePainter({required this.phases});


  static double _phaseY(int p) => switch (p) {
    3 => 0.05,
    2 => 0.35,
    1 => 0.65,
    _ => 0.92,
  };

  static const _kGraphDuration = 10.5;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;


    final gridP = Paint()
      ..color = const Color(0xFF1E2D4A)
      ..strokeWidth = 0.8;
    for (final frac in [0.05, 0.35, 0.65, 0.92]) {
      canvas.drawLine(Offset(0, frac * h), Offset(w, frac * h), gridP);
    }


    for (int i = 0; i <= 10; i++) {
      final x = (i / _kGraphDuration) * w;
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridP);
    }

    if (phases.length < 2) return;


    for (int i = 0; i < phases.length - 1; i++) {
      final p0 = phases[i];
      final p1 = phases[i + 1];
      final x0 = (p0.t / _kGraphDuration).clamp(0.0, 1.0) * w;
      final x1 = (p1.t / _kGraphDuration).clamp(0.0, 1.0) * w;
      final y0 = _phaseY(p0.p) * h;
      final y1 = _phaseY(p1.p) * h;

      final segPaint = Paint()
        ..color = _phaseColor(p0.p)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path()..moveTo(x0, y0);
      final mx = (x0 + x1) / 2;
      path.cubicTo(mx, y0, mx, y1, x1, y1);
      canvas.drawPath(path, segPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SleepStagePainter old) =>
      old.phases != phases;
}


class _WaveformPainter extends CustomPainter {
  final List<double> values;
  final Color        color;
  final double       progress;

  const _WaveformPainter({
    required this.values,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final barW      = size.width / values.length;
    final progressX = size.width * progress;

    for (int i = 0; i < values.length; i++) {
      final x   = i * barW + barW / 2;
      final h   = values[i] * size.height;
      final top = (size.height - h) / 2;
      final c   = x <= progressX
          ? color
          : color.withValues(alpha: 0.22);
      canvas.drawLine(
          Offset(x, top),
          Offset(x, top + h),
          Paint()
            ..color = c
            ..strokeWidth = (barW * 0.55).clamp(1.5, 4.0)
            ..strokeCap = StrokeCap.round);
    }


    if (progress > 0) {
      canvas.drawCircle(
          Offset(progressX, size.height / 2),
          5,
          Paint()..color = _C.accent);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) =>
      old.progress != progress || old.color != color;
}
