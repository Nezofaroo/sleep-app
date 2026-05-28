import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/sleep_record.dart';
import '../theme/app_colors.dart';
import '../providers/sleep_audio_provider.dart';
import 'snore_detection_page.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});
  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> with TickerProviderStateMixin {
  final DatabaseHelper _db = DatabaseHelper();
  bool _isSleeping = false;
  SleepRecord? _activeSession;
  TimeOfDay? _alarmTime;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _loadActiveSession();
  }

  Future<void> _loadActiveSession() async {
    final s = await _db.getActiveSession();
    if (s != null && mounted) {
      setState(() {
        _activeSession = s;
        _isSleeping = true;
        _elapsed = DateTime.now().difference(s.startTime);
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _activeSession != null) {
        setState(() => _elapsed = DateTime.now().difference(_activeSession!.startTime));
      }
    });
  }

  Future<void> _toggleSleep() async {
    if (_isSleeping) {
      _timer?.cancel();
      final end = DateTime.now();
      final mins = end.difference(_activeSession!.startTime).inMinutes;
      final updated = _activeSession!.copyWith(endTime: end, durationMinutes: mins);
      await _db.updateSleepRecord(updated);
      _showQualityDialog(updated);
    } else {
      final now = DateTime.now();
      final record = SleepRecord(
        startTime: now,
        alarmTime: _alarmTime != null
            ? '${_alarmTime!.hour.toString().padLeft(2, '0')}:${_alarmTime!.minute.toString().padLeft(2, '0')}'
            : null,
      );
      final id = await _db.insertSleepRecord(record);
      setState(() {
        _activeSession = record.copyWith(id: id);
        _isSleeping = true;
        _elapsed = Duration.zero;
      });
      _startTimer();
    }
  }

  void _showQualityDialog(SleepRecord record) {
    String selected = 'Good';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final c = AppColors.of(ctx);
        return StatefulBuilder(
          builder: (ctx, setS) => AlertDialog(
            backgroundColor: c.cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('How did you sleep?',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700, fontSize: 18, color: c.textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total: ${record.formattedDuration}',
                    style: GoogleFonts.montserrat(
                        fontSize: 14, color: c.accent, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                ...['Poor', 'Fair', 'Good', 'Excellent'].map((q) {
                  final qc = {'Poor': const Color(0xFFE57373), 'Fair': const Color(0xFFFFB74D), 'Good': c.accent, 'Excellent': const Color(0xFF66BB6A)}[q]!;
                  final isSelected = selected == q;
                  return GestureDetector(
                    onTap: () => setS(() => selected = q),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: qc.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: qc, width: 1.5))
                          : c.cardRaised(radius: 12),
                      child: Row(
                        children: [
                          Container(width: 10, height: 10,
                              decoration: BoxDecoration(
                                  color: isSelected ? qc : c.textDisabled,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 14),
                          Text(q, style: GoogleFonts.montserrat(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: isSelected ? qc : c.textSecondary)),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await _db.updateSleepRecord(record.copyWith(quality: selected));
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  setState(() { _isSleeping = false; _activeSession = null; _elapsed = Duration.zero; });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: AppColors.of(ctx).accentButton(radius: 30),
                  child: Text('Save', style: GoogleFonts.montserrat(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAlarm() async {
    final c = AppColors.of(context);
    final picked = await showTimePicker(
      context: context,
      initialTime: _alarmTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: c.cardBg,
            hourMinuteColor: c.chartBg,
            hourMinuteTextColor: c.accent,
            dialBackgroundColor: c.chartBg,
            dialHandColor: c.accent,
            dialTextColor: c.textPrimary,
            entryModeIconColor: c.accent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _alarmTime = picked);
  }

  String get _elapsedFormatted {
    final h = _elapsed.inHours.toString().padLeft(2, '0');
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h : $m : $s';
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }

  @override
  void dispose() { _timer?.cancel(); _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final now = DateTime.now();
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Good ${_greeting()},',
                        style: GoogleFonts.montserrat(
                            fontSize: 14, color: c.textSecondary, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text('Sleep Tracker',
                        style: GoogleFonts.montserrat(
                            fontSize: 22, fontWeight: FontWeight.w800, color: c.textPrimary)),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: c.cardRaised(radius: 50),
                    child: Text(DateFormat('HH:mm').format(now),
                        style: GoogleFonts.montserrat(
                            fontSize: 18, fontWeight: FontWeight.w700, color: c.accent)),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Alarm card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: c.cardRaised(radius: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: c.iconBadge(radius: 14),
                      child: Icon(Icons.alarm_rounded, color: c.accent, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Wake Alarm',
                            style: GoogleFonts.montserrat(
                                fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(
                          _alarmTime != null
                              ? '${_alarmTime!.hour.toString().padLeft(2, '0')}:${_alarmTime!.minute.toString().padLeft(2, '0')}'
                              : 'Not set',
                          style: GoogleFonts.montserrat(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _alarmTime != null ? c.textPrimary : c.textDisabled),
                        ),
                      ]),
                    ),
                    Column(children: [
                      GestureDetector(
                        onTap: _pickAlarm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: c.accentButton(radius: 30),
                          child: Text(_alarmTime != null ? 'Edit' : 'Set',
                              style: GoogleFonts.montserrat(
                                  fontSize: 12, fontWeight: FontWeight.w700, color: c.white)),
                        ),
                      ),
                      if (_alarmTime != null) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => setState(() => _alarmTime = null),
                          child: Icon(Icons.close_rounded, size: 18, color: c.textSecondary),
                        ),
                      ],
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Sleep status or tips
              if (_isSleeping) ...[  
                // ── Sleep timer card ───────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: c.cardPressed(radius: 20),
                  child: Column(children: [
                    Text('Sleep in Progress',
                        style: GoogleFonts.montserrat(
                            fontSize: 13, fontWeight: FontWeight.w600, color: c.accent)),
                    const SizedBox(height: 12),
                    Text(_elapsedFormatted,
                        style: GoogleFonts.montserrat(
                            fontSize: 36, fontWeight: FontWeight.w800, color: c.textPrimary)),
                    const SizedBox(height: 6),
                    Text('Started at ${DateFormat('hh:mm a').format(_activeSession!.startTime)}',
                        style: GoogleFonts.montserrat(fontSize: 12, color: c.textSecondary)),
                  ]),
                ),
                const SizedBox(height: 16),
                // ── Sleep Monitor button ──────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SnoreDetectionPage(
                        provider: SleepAudioProvider(),
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1E2D50),
                          const Color(0xFF0E1628),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4B6FDB).withValues(alpha: 0.30),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4B6FDB).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.hearing_rounded,
                            color: Color(0xFF4B6FDB),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sleep Monitor',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFEAEBF2))),
                              Text('Snore & sleep-talk detection',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      color: const Color(0xFF7A84A8))),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFF4B6FDB),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sleep Tips',
                        style: GoogleFonts.montserrat(
                            fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary)),
                    const SizedBox(height: 14),
                    ...[
                      (Icons.thermostat_outlined, 'Keep room at 65–68°F (18–20°C)'),
                      (Icons.phone_android_outlined, 'No screens 1 hour before bed'),
                      (Icons.schedule_outlined, '7–9 hours is ideal for most adults'),
                    ].map((t) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: c.cardRaised(radius: 14),
                          child: Row(children: [
                            Icon(t.$1, color: c.accent, size: 20),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(t.$2,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      color: c.textSecondary,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ]),
                        )),
                  ],
                ),
              const SizedBox(height: 36),
              // Sleep button
              Center(
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) => Transform.scale(
                      scale: _isSleeping ? _pulseAnim.value : 1.0, child: child),
                  child: GestureDetector(
                    onTap: _toggleSleep,
                    child: Container(
                      width: 190, height: 190,
                      decoration: _isSleeping
                          ? BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: c.accentGradient),
                              boxShadow: [
                                BoxShadow(
                                    color: c.accent.withValues(alpha: 0.45),
                                    blurRadius: 30,
                                    offset: const Offset(0, 12)),
                                BoxShadow(
                                    color: c.shadowLight.withValues(
                                        alpha: c.isDark ? 0.05 : 1.0),
                                    blurRadius: 16,
                                    offset: const Offset(-8, -8)),
                              ])
                          : BoxDecoration(
                              shape: BoxShape.circle,
                              color: c.cardBg,
                              boxShadow: [
                                BoxShadow(
                                    color: c.shadowDark,
                                    offset: const Offset(10, 10),
                                    blurRadius: 20),
                                BoxShadow(
                                    color: c.shadowLight.withValues(
                                        alpha: c.isDark ? 0.05 : 1.0),
                                    offset: const Offset(-10, -10),
                                    blurRadius: 20),
                              ]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isSleeping ? Icons.wb_sunny_rounded : Icons.bedtime_rounded,
                            size: 52,
                            color: _isSleeping ? c.white : c.accent,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _isSleeping ? 'Wake Up' : 'Sleep',
                            style: GoogleFonts.montserrat(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: _isSleeping ? c.white : c.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _isSleeping ? 'Tap to wake up' : 'Tap to start sleeping',
                  style: GoogleFonts.montserrat(fontSize: 13, color: c.textSecondary, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
