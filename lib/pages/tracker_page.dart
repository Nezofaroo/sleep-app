import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/sleep_record.dart';
import '../theme/neumorphic_theme.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage>
    with TickerProviderStateMixin {
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
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _loadActiveSession();
  }

  Future<void> _loadActiveSession() async {
    final session = await _db.getActiveSession();
    if (session != null && mounted) {
      setState(() {
        _activeSession = session;
        _isSleeping = true;
        _elapsed = DateTime.now().difference(session.startTime);
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _activeSession != null) {
        setState(() {
          _elapsed = DateTime.now().difference(_activeSession!.startTime);
        });
      }
    });
  }

  Future<void> _toggleSleep() async {
    if (_isSleeping) {
      _timer?.cancel();
      final endTime = DateTime.now();
      final duration = endTime.difference(_activeSession!.startTime);
      final updated = _activeSession!.copyWith(
        endTime: endTime,
        durationMinutes: duration.inMinutes,
      );
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
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: NeumorphicColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'How did you sleep?',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: NeumorphicColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total: ${record.formattedDuration}',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: NeumorphicColors.coral,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ...['Poor', 'Fair', 'Good', 'Excellent'].map((q) {
                final colors = {
                  'Poor': const Color(0xFFE57373),
                  'Fair': const Color(0xFFFFB74D),
                  'Good': NeumorphicColors.coral,
                  'Excellent': const Color(0xFF66BB6A),
                };
                final c = colors[q]!;
                final isSelected = selected == q;
                return GestureDetector(
                  onTap: () => setS(() => selected = q),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: c.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: c, width: 1.5),
                          )
                        : neumorphicRaised(radius: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isSelected ? c : NeumorphicColors.textDisabled,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          q,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? c : NeumorphicColors.textSecondary,
                          ),
                        ),
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
                final finalRecord = record.copyWith(quality: selected);
                await _db.updateSleepRecord(finalRecord);
                if (ctx.mounted) Navigator.of(ctx).pop();
                setState(() {
                  _isSleeping = false;
                  _activeSession = null;
                  _elapsed = Duration.zero;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: coralButtonDecoration(radius: 30),
                child: Text(
                  'Save',
                  style: GoogleFonts.montserrat(
                    color: NeumorphicColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAlarm() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _alarmTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: NeumorphicColors.background,
            hourMinuteColor: NeumorphicColors.chartBg,
            hourMinuteTextColor: NeumorphicColors.coral,
            dialBackgroundColor: NeumorphicColors.chartBg,
            dialHandColor: NeumorphicColors.coral,
            dialTextColor: NeumorphicColors.textPrimary,
            entryModeIconColor: NeumorphicColors.coral,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
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

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      backgroundColor: NeumorphicColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(now),
              const SizedBox(height: 28),
              _buildAlarmCard(),
              const SizedBox(height: 24),
              if (_isSleeping) _buildSleepingCard(),
              if (!_isSleeping) _buildSleepTips(),
              const SizedBox(height: 36),
              Center(child: _buildSleepButton()),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _isSleeping ? 'Tap to wake up' : 'Tap to start sleeping',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: NeumorphicColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DateTime now) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_greeting()},',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: NeumorphicColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Sleep Tracker',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: NeumorphicColors.textPrimary,
              ),
            ),
          ],
        ),
        // Clock chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: neumorphicRaised(radius: 50),
          child: Text(
            DateFormat('HH:mm').format(now),
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: NeumorphicColors.coral,
            ),
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }

  Widget _buildAlarmCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: neumorphicRaised(radius: 20),
      child: Row(
        children: [
          // Icon badge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NeumorphicColors.coral.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.alarm_rounded,
              color: NeumorphicColors.coral,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wake Alarm',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: NeumorphicColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _alarmTime != null
                      ? '${_alarmTime!.hour.toString().padLeft(2, '0')}:${_alarmTime!.minute.toString().padLeft(2, '0')}'
                      : 'Not set',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _alarmTime != null
                        ? NeumorphicColors.textPrimary
                        : NeumorphicColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Column(
            children: [
              GestureDetector(
                onTap: _pickAlarm,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: coralButtonDecoration(radius: 30),
                  child: Text(
                    _alarmTime != null ? 'Edit' : 'Set',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: NeumorphicColors.white,
                    ),
                  ),
                ),
              ),
              if (_alarmTime != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => _alarmTime = null),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: NeumorphicColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: neumorphicPressed(radius: 20),
      child: Column(
        children: [
          Text(
            'Sleep in Progress',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: NeumorphicColors.coral,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _elapsedFormatted,
            style: GoogleFonts.montserrat(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: NeumorphicColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Started at ${DateFormat('hh:mm a').format(_activeSession!.startTime)}',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: NeumorphicColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepTips() {
    final tips = [
      (Icons.thermostat_outlined, 'Keep room at 65–68°F (18–20°C)'),
      (Icons.phone_android_outlined, 'No screens 1 hour before bed'),
      (Icons.schedule_outlined, '7–9 hours is ideal for most adults'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sleep Tips',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: NeumorphicColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        ...tips.map((t) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: neumorphicRaised(radius: 14),
              child: Row(
                children: [
                  Icon(t.$1, color: NeumorphicColors.coral, size: 20),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      t.$2,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: NeumorphicColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildSleepButton() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) => Transform.scale(
        scale: _isSleeping ? _pulseAnim.value : 1.0,
        child: child,
      ),
      child: GestureDetector(
        onTap: _toggleSleep,
        child: Container(
          width: 190,
          height: 190,
          decoration: _isSleeping
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF9B72), Color(0xFFFF6A30)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: NeumorphicColors.coral.withOpacity(0.45),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                    const BoxShadow(
                      color: NeumorphicColors.shadowLight,
                      blurRadius: 16,
                      offset: Offset(-8, -8),
                    ),
                  ],
                )
              : BoxDecoration(
                  shape: BoxShape.circle,
                  color: NeumorphicColors.background,
                  boxShadow: const [
                    BoxShadow(
                      color: NeumorphicColors.shadowDark,
                      offset: Offset(10, 10),
                      blurRadius: 20,
                    ),
                    BoxShadow(
                      color: NeumorphicColors.shadowLight,
                      offset: Offset(-10, -10),
                      blurRadius: 20,
                    ),
                  ],
                ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isSleeping ? Icons.wb_sunny_rounded : Icons.bedtime_rounded,
                size: 52,
                color: _isSleeping
                    ? NeumorphicColors.white
                    : NeumorphicColors.coral,
              ),
              const SizedBox(height: 10),
              Text(
                _isSleeping ? 'Wake Up' : 'Sleep',
                style: GoogleFonts.montserrat(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _isSleeping
                      ? NeumorphicColors.white
                      : NeumorphicColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
