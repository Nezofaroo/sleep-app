import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/sleep_record.dart';
import '../theme/cyberpunk_theme.dart';

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

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 6, end: 24).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
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
      // Wake up: end session
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
      // Go to sleep: start session
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
    String selectedQuality = 'Good';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: CyberpunkColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: CyberpunkColors.neonCyan, width: 1),
          ),
          title: Text(
            'SLEEP QUALITY',
            style: GoogleFonts.orbitron(
              color: CyberpunkColors.neonCyan,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Sleep: ${record.copyWith(durationMinutes: record.durationMinutes).formattedDuration}',
                style: GoogleFonts.rajdhani(
                  color: CyberpunkColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ...['Poor', 'Fair', 'Good', 'Excellent'].map((q) {
                final colors = {
                  'Poor': CyberpunkColors.neonPink,
                  'Fair': CyberpunkColors.neonYellow,
                  'Good': CyberpunkColors.neonCyan,
                  'Excellent': CyberpunkColors.neonGreen,
                };
                return GestureDetector(
                  onTap: () => setS(() => selectedQuality = q),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selectedQuality == q
                          ? colors[q]!.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedQuality == q
                            ? colors[q]!
                            : CyberpunkColors.textDisabled,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.circle,
                            size: 10, color: selectedQuality == q ? colors[q]! : CyberpunkColors.textDisabled),
                        const SizedBox(width: 12),
                        Text(q,
                            style: GoogleFonts.rajdhani(
                              color: selectedQuality == q ? colors[q]! : CyberpunkColors.textSecondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            )),
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
                final finalRecord = record.copyWith(quality: selectedQuality);
                await _db.updateSleepRecord(finalRecord);
                if (ctx.mounted) Navigator.of(ctx).pop();
                setState(() {
                  _isSleeping = false;
                  _activeSession = null;
                  _elapsed = Duration.zero;
                });
              },
              child: Text(
                'SAVE',
                style: GoogleFonts.orbitron(
                  color: CyberpunkColors.neonCyan,
                  letterSpacing: 2,
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
            backgroundColor: CyberpunkColors.surface,
            hourMinuteColor: CyberpunkColors.cardBg,
            hourMinuteTextColor: CyberpunkColors.neonCyan,
            dialBackgroundColor: CyberpunkColors.cardBg,
            dialHandColor: CyberpunkColors.neonCyan,
            dialTextColor: CyberpunkColors.textPrimary,
            entryModeIconColor: CyberpunkColors.neonCyan,
            dayPeriodColor: CyberpunkColors.surfaceVariant,
            dayPeriodTextColor: CyberpunkColors.neonCyan,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: CyberpunkColors.neonCyan, width: 1),
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _alarmTime = picked);
  }

  String get _elapsedFormatted {
    final h = _elapsed.inHours;
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '${h.toString().padLeft(2, '0')}:$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);
    final dateStr = DateFormat('EEE, MMM d').format(now);

    return Scaffold(
      backgroundColor: CyberpunkColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────────
                _buildHeader(timeStr, dateStr),
                const SizedBox(height: 32),

                // ── Alarm Card ───────────────────────────────────────────────
                _buildAlarmCard(),
                const SizedBox(height: 24),

                // ── Sleep Status ─────────────────────────────────────────────
                if (_isSleeping) _buildSleepingStatus(),
                if (!_isSleeping) _buildSleepTips(),
                const SizedBox(height: 32),

                // ── Sleep Button ─────────────────────────────────────────────
                Center(child: _buildSleepButton()),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    _isSleeping ? 'TAP TO WAKE UP' : 'TAP TO START SLEEPING',
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      color: CyberpunkColors.textSecondary,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String timeStr, String dateStr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SLEEP TRACKER',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                color: CyberpunkColors.neonCyan,
                letterSpacing: 4,
                shadows: neonGlow(CyberpunkColors.neonCyan),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateStr.toUpperCase(),
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                color: CyberpunkColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: cyberpunkCardDecoration(borderColor: CyberpunkColors.neonPurple, glowRadius: 8),
          child: Text(
            timeStr,
            style: GoogleFonts.orbitron(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: CyberpunkColors.neonPurple,
              shadows: neonGlow(CyberpunkColors.neonPurple),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlarmCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cyberpunkCardDecoration(
        borderColor: _alarmTime != null ? CyberpunkColors.neonYellow : CyberpunkColors.neonCyan,
        glowRadius: _alarmTime != null ? 12 : 6,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CyberpunkColors.neonYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CyberpunkColors.neonYellow.withOpacity(0.5)),
            ),
            child: Icon(Icons.alarm, color: CyberpunkColors.neonYellow, size: 24,
                shadows: neonGlow(CyberpunkColors.neonYellow).map((s) => Shadow(color: s.color, blurRadius: s.blurRadius)).toList()),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WAKE ALARM',
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    color: CyberpunkColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _alarmTime != null
                      ? '${_alarmTime!.hour.toString().padLeft(2, '0')}:${_alarmTime!.minute.toString().padLeft(2, '0')}'
                      : 'Not Set',
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: _alarmTime != null ? CyberpunkColors.neonYellow : CyberpunkColors.textSecondary,
                    shadows: _alarmTime != null ? neonGlow(CyberpunkColors.neonYellow) : [],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _pickAlarm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: CyberpunkColors.neonYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CyberpunkColors.neonYellow.withOpacity(0.7)),
              ),
              child: Text(
                _alarmTime != null ? 'EDIT' : 'SET',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  color: CyberpunkColors.neonYellow,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          if (_alarmTime != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _alarmTime = null),
              child: Icon(Icons.close, color: CyberpunkColors.neonPink, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSleepingStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cyberpunkCardDecoration(
        borderColor: CyberpunkColors.neonPurple,
        glowRadius: 16,
      ),
      child: Column(
        children: [
          Text(
            'SLEEP IN PROGRESS',
            style: GoogleFonts.orbitron(
              fontSize: 11,
              color: CyberpunkColors.neonPurple,
              letterSpacing: 3,
              shadows: neonGlow(CyberpunkColors.neonPurple),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, _) => Text(
              _elapsedFormatted,
              style: GoogleFonts.orbitron(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: CyberpunkColors.neonCyan,
                shadows: [
                  Shadow(color: CyberpunkColors.neonCyan.withOpacity(0.8), blurRadius: _glowAnimation.value),
                  Shadow(color: CyberpunkColors.neonCyan.withOpacity(0.4), blurRadius: _glowAnimation.value * 2),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Started: ${DateFormat('hh:mm a').format(_activeSession!.startTime)}',
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: CyberpunkColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepTips() {
    final tips = [
      ('💤', 'Optimal sleep is 7–9 hours'),
      ('🌡️', 'Keep room temp 65–68°F (18–20°C)'),
      ('📵', 'Avoid screens 1 hour before bed'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SLEEP TIPS',
          style: GoogleFonts.orbitron(
            fontSize: 11,
            color: CyberpunkColors.textSecondary,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 12),
        ...tips.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text(t.$1, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.$2,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: CyberpunkColors.textSecondary,
                    letterSpacing: 0.5,
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
    final color = _isSleeping ? CyberpunkColors.neonPink : CyberpunkColors.neonCyan;
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Transform.scale(
        scale: _isSleeping ? _pulseAnimation.value : 1.0,
        child: child,
      ),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, _) => GestureDetector(
          onTap: _toggleSleep,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CyberpunkColors.cardBg,
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: _isSleeping ? _glowAnimation.value * 1.5 : 20,
                  spreadRadius: _isSleeping ? 8 : 2,
                ),
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: _isSleeping ? _glowAnimation.value * 3 : 40,
                  spreadRadius: _isSleeping ? 16 : 8,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isSleeping ? Icons.wb_sunny_outlined : Icons.bedtime_outlined,
                  color: color,
                  size: 52,
                  shadows: neonGlow(color).map((s) => Shadow(color: s.color, blurRadius: s.blurRadius)).toList(),
                ),
                const SizedBox(height: 10),
                Text(
                  _isSleeping ? 'WAKE UP' : 'SLEEP',
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 4,
                    shadows: neonGlow(color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
