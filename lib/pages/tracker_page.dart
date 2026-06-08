import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/sleep_record.dart';
import '../models/alarm_settings.dart';
import '../models/sound_event.dart';
import '../providers/alarm_settings_provider.dart';
import '../providers/sleep_audio_provider.dart';
import '../widgets/pulse_indicator.dart';
import 'alarm_settings_page.dart';
import 'snore_detection_page.dart';


class _C {
  static const bg      = Color(0xFF080C14);
  static const surface = Color(0xFF111827);
  static const accent  = Color(0xFF4F6EF7);
  static const cream   = Color(0xFFEEF0F8);
  static const muted   = Color(0xFF7A84A8);
  static const danger  = Color(0xFFE05C6A);
  static const success = Color(0xFF4CAF7D);
  static const divider = Color(0xFF1E2D50);
  static const glass   = Color(0xFF1A2540);
}











class TrackerPage extends StatefulWidget {
  final AlarmSettingsProvider alarmProvider;
  final SleepAudioProvider    audioProvider;

  const TrackerPage({
    super.key,
    required this.alarmProvider,
    required this.audioProvider,
  });

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage>
    with TickerProviderStateMixin {
  final DatabaseHelper _db = DatabaseHelper();


  bool         _isSleeping   = false;
  SleepRecord? _activeSession;
  Duration     _elapsed      = Duration.zero;
  Timer?       _timer;


  late final AnimationController _btnCtrl;
  late final Animation<double>   _btnScale;

  AlarmSettings  get _alarm => widget.alarmProvider.settings;
  SleepAudioProvider get _audio => widget.audioProvider;

  @override
  void initState() {
    super.initState();
    _btnCtrl  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _btnScale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));
    _loadActiveSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _btnCtrl.dispose();
    super.dispose();
  }


  Future<void> _loadActiveSession() async {
    final s = await _db.getActiveSession();
    if (s != null && mounted) {
      setState(() {
        _activeSession = s;
        _isSleeping    = true;
        _elapsed       = DateTime.now().difference(s.startTime);
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _activeSession != null) {
        setState(() =>
            _elapsed = DateTime.now().difference(_activeSession!.startTime));
      }
    });
  }


  Future<void> _toggleSleep() async {
    await _btnCtrl.forward();
    await _btnCtrl.reverse();

    if (_isSleeping) {
      _timer?.cancel();


      await _audio.stopMonitoring();

      final end  = DateTime.now();
      final mins = end.difference(_activeSession!.startTime).inMinutes;
      final updated = _activeSession!.copyWith(endTime: end, durationMinutes: mins);
      await _db.updateSleepRecord(updated);

      if (mounted) _showQualityDialog(updated);
    } else {
      final now    = DateTime.now();
      final record = SleepRecord(
        startTime: now,
        alarmTime: _alarm.alarmEnabled
            ? _alarm.formattedAlarmTime
            : null,
      );
      final id = await _db.insertSleepRecord(record);





      await _audio.startMonitoring();


      if (mounted) {
        setState(() {
          _activeSession = record.copyWith(id: id);
          _isSleeping    = true;
          _elapsed       = Duration.zero;
        });
        _startTimer();
      }
    }
  }


  void _showQualityDialog(SleepRecord record) {

    String? quality;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) => AlertDialog(
            backgroundColor: _C.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
            title: Text('Как вы спали?',
                style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _C.cream)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(record.formattedDuration,
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: _C.accent,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                ...{
                  'Плохо':      _C.danger,
                  'Сносно':     const Color(0xFFFFB74D),
                  'Хорошо':     _C.accent,
                  'Отлично':    _C.success,
                }.entries.map((e) {
                  final sel = quality == e.key;
                  return GestureDetector(
                    onTap: () => setS(() => quality = e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: sel
                            ? e.value.withValues(alpha: 0.12)
                            : _C.glass.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: sel
                                ? e.value
                                : _C.divider,
                            width: 1),
                      ),
                      child: Row(children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: sel ? e.value : _C.muted,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(e.key,
                            style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: sel ? e.value : _C.muted)),
                      ]),
                    ),
                  );
                }),

                if (_alarm.wakeMoodEnabled) ...[
                  const Divider(color: _C.divider, height: 24),
                  Text('Настроение',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, color: _C.muted)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['😴', '😕', '😐', '🙂', '😄'].map((e) =>
                      GestureDetector(
                        onTap: () {},
                        child: Text(e,
                            style: const TextStyle(fontSize: 28)),
                      )).toList(),
                  ),
                ],
              ],
            ),
            actions: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _C.accent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 12),
                ),
                onPressed: () async {
                  await _db.updateSleepRecord(
                      record.copyWith(quality: quality ?? 'Хорошо'));
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  setState(() {
                    _isSleeping    = false;
                    _activeSession = null;
                    _elapsed       = Duration.zero;
                  });
                },
                child: Text('Сохранить',
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }


  String get _elapsedStr {
    final h = _elapsed.inHours.toString().padLeft(2, '0');
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }


  void _openAlarmSettings() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AlarmSettingsPage(provider: widget.alarmProvider),
    ));
  }

  void _openSleepMonitor() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SnoreDetectionPage(provider: _audio),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(

      listenable: Listenable.merge([widget.alarmProvider, _audio]),
      builder: (context, _) => Scaffold(
        backgroundColor: _C.bg,
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildStatusCard()),
                  if (_isSleeping) ...[
                    SliverToBoxAdapter(child: _buildTimerCard()),
                    SliverToBoxAdapter(child: _buildMonitorCard()),
                    SliverToBoxAdapter(child: _buildTimelineSection()),
                  ] else ...[
                    SliverToBoxAdapter(child: _buildAlarmCard()),
                    SliverToBoxAdapter(child: _buildBedtimeCard()),
                    SliverToBoxAdapter(child: _buildTipsCard()),
                  ],
                  SliverToBoxAdapter(child: _buildSleepButton()),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBackground() => Container(
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-0.3, -0.5),
        radius: 1.2,
        colors: [Color(0xFF14203A), _C.bg],
      ),
    ),
  );


  Widget _buildHeader() {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_greeting(),
                style: GoogleFonts.montserrat(
                    fontSize: 13, color: _C.muted, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text('Sleep.ly',
                style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _C.cream)),
          ]),

          _GlassChip(
            child: Text(DateFormat('HH:mm').format(now),
                style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _C.accent)),
          ),
        ],
      ),
    );
  }


  Widget _buildStatusCard() {
    final isActive = _audio.isActive;
    final isRec    = _audio.status == MonitoringStatus.recording;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: _GlassCard(
        child: Row(children: [

          if (isActive)
            PulseIndicator(
              color: isRec ? const Color(0xFF7C5FDB) : _C.accent,
              size: 36,
              ringCount: 2,
              child: Icon(
                isRec ? Icons.mic_rounded : Icons.hearing_rounded,
                color: isRec ? const Color(0xFF7C5FDB) : _C.accent,
                size: 16,
              ),
            )
          else
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: _C.muted.withValues(alpha: 0.3), width: 1),
              ),
              child: const Icon(Icons.mic_off_rounded,
                  color: _C.muted, size: 20),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                isRec ? 'Запись звука...'
                    : isActive ? 'Слушаю окружение'
                    : 'Мониторинг не активен',
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isRec
                        ? const Color(0xFF7C5FDB)
                        : isActive ? _C.accent : _C.muted),
              ),
              Text(
                isActive
                    ? 'VAD -35 dBFS · Cooldown 1.5s'
                    : 'Начните сон для мониторинга',
                style: GoogleFonts.montserrat(
                    fontSize: 11, color: _C.muted),
              ),
            ]),
          ),

          if (_audio.events.isNotEmpty)
            _GlassChip(
              child: Text('${_audio.events.length}',
                  style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.accent)),
            ),
        ]),
      ),
    );
  }


  Widget _buildTimerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: _GlassCard(
        child: Column(children: [
          Text('Сон в процессе',
              style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: _C.accent,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(_elapsedStr,
              style: GoogleFonts.montserrat(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: _C.cream,
                  letterSpacing: 2)),
          const SizedBox(height: 4),
          Text(
            'Начало: ${DateFormat('HH:mm').format(_activeSession!.startTime)}',
            style: GoogleFonts.montserrat(
                fontSize: 12, color: _C.muted),
          ),
        ]),
      ),
    );
  }


  Widget _buildMonitorCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GestureDetector(
        onTap: _openSleepMonitor,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_C.accent.withValues(alpha: 0.15), _C.glass],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: _C.accent.withValues(alpha: 0.35), width: 0.8),
            boxShadow: [
              BoxShadow(
                  color: _C.accent.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _C.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.hearing_rounded,
                  color: _C.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Монитор сна',
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.cream)),
                Text('Запись храпа и разговоров',
                    style: GoogleFonts.montserrat(
                        fontSize: 11, color: _C.muted)),
              ]),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: _C.accent, size: 14),
          ]),
        ),
      ),
    );
  }


  Widget _buildTimelineSection() {
    final events = _audio.events;
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: _GlassCard(
          child: Column(children: [
            Icon(Icons.nights_stay_outlined,
                size: 40, color: _C.muted.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('Тишина за ночь',
                style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.muted)),
            Text('Обнаруженные звуки появятся здесь',
                style: GoogleFonts.montserrat(
                    fontSize: 12, color: _C.muted.withValues(alpha: 0.6)),
                textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text('Звуки за ночь',
              style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _C.cream)),
        ),
        ...events.take(5).map((e) => _EventTile(event: e)),
        if (events.length > 5)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: _openSleepMonitor,
              child: Text('Показать все (${events.length})',
                  style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: _C.accent,
                      fontWeight: FontWeight.w600)),
            ),
          ),
      ],
    );
  }


  Widget _buildAlarmCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: GestureDetector(
        onTap: _openAlarmSettings,
        child: _GlassCard(
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _C.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.alarm_rounded,
                  color: _C.accent, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Будильник',
                    style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: _C.muted,
                        fontWeight: FontWeight.w500)),
                Text(
                  _alarm.alarmEnabled
                      ? _alarm.formattedAlarmTime
                      : 'Не установлен',
                  style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _alarm.alarmEnabled ? _C.cream : _C.muted),
                ),
              ]),
            ),
            _GlassChip(
              color: _alarm.alarmEnabled
                  ? _C.accent.withValues(alpha: 0.15)
                  : null,
              child: Text(_alarm.alarmEnabled ? 'Вкл.' : 'Настроить',
                  style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _alarm.alarmEnabled ? _C.accent : _C.muted)),
            ),
          ]),
        ),
      ),
    );
  }


  Widget _buildBedtimeCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: GestureDetector(
        onTap: _openAlarmSettings,
        child: _GlassCard(
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF7C5FDB).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bedtime_rounded,
                  color: Color(0xFF7C5FDB), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Время отхода ко сну',
                    style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: _C.muted,
                        fontWeight: FontWeight.w500)),
                Text(_alarm.formattedBedtime,
                    style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _C.cream)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: _C.muted, size: 20),
          ]),
        ),
      ),
    );
  }


  Widget _buildTipsCard() {
    const tips = [
      (Icons.thermostat_outlined, '18–20°C — оптимальная температура для сна'),
      (Icons.phone_android_outlined, 'Без экранов за час до сна'),
      (Icons.schedule_outlined, '7–9 часов — норма для взрослых'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: _GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Советы',
                style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.cream)),
            const SizedBox(height: 12),
            ...tips.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Icon(t.$1, color: _C.accent, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(t.$2,
                      style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: _C.muted,
                          fontWeight: FontWeight.w500)),
                ),
              ]),
            )),
          ],
        ),
      ),
    );
  }


  Widget _buildSleepButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: ScaleTransition(
        scale: _btnScale,
        child: GestureDetector(
          onTap: _toggleSleep,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isSleeping
                    ? [const Color(0xFFE05C6A), const Color(0xFF9B2C3E)]
                    : [_C.accent, const Color(0xFF3A5BC7)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (_isSleeping ? _C.danger : _C.accent)
                      .withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isSleeping
                      ? Icons.wb_sunny_rounded
                      : Icons.bedtime_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  _isSleeping ? 'Завершить сон' : 'Начать сон',
                  style: GoogleFonts.montserrat(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 6)  return 'Доброй ночи 🌙';
    if (h < 12) return 'Доброе утро ☀️';
    if (h < 17) return 'Добрый день 🌤';
    return 'Добрый вечер 🌙';
  }
}






class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: _C.glass.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.07), width: 0.8),
          ),
          child: child,
        ),
      ),
    );
  }
}


class _GlassChip extends StatelessWidget {
  final Widget child;
  final Color? color;

  const _GlassChip({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color ?? _C.glass.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.08), width: 0.8),
      ),
      child: child,
    );
  }
}


class _EventTile extends StatelessWidget {
  final SoundEvent event;
  const _EventTile({required this.event});

  static const _typeColors = {
    0: Color(0xFF4F6EF7),
    1: Color(0xFF4F6EF7),
    2: Color(0xFF7C5FDB),
  };

  @override
  Widget build(BuildContext context) {
    final color = _typeColors[event.typeIndex] ?? _C.accent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: Row(
        children: [

          Container(
            width: 3, height: 40,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text('${event.type.emoji}  ${event.type.label}',
                  style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color)),
              Text(DateFormat('HH:mm:ss').format(event.startTime),
                  style: GoogleFonts.montserrat(
                      fontSize: 11, color: _C.muted)),
            ]),
          ),
          Text(event.formattedDuration,
              style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.cream)),
        ],
      ),
    );
  }
}
