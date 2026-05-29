import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/sound_event.dart';
import '../providers/sleep_audio_provider.dart';
import '../widgets/glassmorphism_card.dart';
import '../widgets/pulse_indicator.dart';

// ── Colour constants ──────────────────────────────────────────────────────────
class _C {
  static const bg1        = Color(0xFF060B18);
  static const grad       = Color(0xFF152040);
  static const indigo     = Color(0xFF4B6FDB);
  static const indigoSoft = Color(0xFF3A5BC7);
  static const cream      = Color(0xFFEAEBF2);
  static const muted      = Color(0xFF7A84A8);
  static const snore      = Color(0xFF4B6FDB);  // indigo
  static const talk       = Color(0xFF7C5FDB);  // violet
  static const mumble     = Color(0xFF3FA8C7);  // teal
  static const danger     = Color(0xFFDB5F6F);  // red

  /// Цвет по типу события
  static Color forType(SoundEventType t) => switch (t) {
    SoundEventType.snore  => snore,
    SoundEventType.talk   => talk,
    SoundEventType.mumble => mumble,
  };
}

/// Full-screen sleep monitor dashboard — Timeline / Sleep History / Sound Records.
class SnoreDetectionPage extends StatefulWidget {
  final SleepAudioProvider provider;
  const SnoreDetectionPage({super.key, required this.provider});

  @override
  State<SnoreDetectionPage> createState() => _SnoreDetectionPageState();
}

class _SnoreDetectionPageState extends State<SnoreDetectionPage> {
  SleepAudioProvider get _p => widget.provider;

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _p,
      builder: (context, _) => Scaffold(
        backgroundColor: _C.bg1,
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  // ── Header ─────────────────────────────────────────────────
                  SliverToBoxAdapter(child: _buildHeader()),

                  // ── Status card ────────────────────────────────────────────
                  SliverToBoxAdapter(child: _buildStatusCard()),

                  // ── Control button ─────────────────────────────────────────
                  SliverToBoxAdapter(child: _buildControlButton()),

                  // ── Error banner ───────────────────────────────────────────
                  if (_p.errorMsg != null)
                    SliverToBoxAdapter(child: _buildErrorBanner()),

                  // ══ СЕКЦИЯ 1: Timeline ══════════════════════════════════════
                  SliverToBoxAdapter(child: _buildSectionHeader(
                    label: 'Timeline',
                    trailing: _p.events.isNotEmpty
                        ? GestureDetector(
                            onTap: _p.clearEvents,
                            child: Text('Clear',
                                style: GoogleFonts.montserrat(
                                    fontSize: 12, color: _C.danger)),
                          )
                        : null,
                  )),
                  if (_p.events.isEmpty)
                    SliverToBoxAdapter(
                      child: _buildEmptyHint(
                        icon: Icons.nights_stay_outlined,
                        label: 'No events yet',
                        hint: 'Detected sounds appear here\nas a live timeline.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      sliver: SliverList.builder(
                        itemCount: _p.events.length,
                        itemBuilder: (_, i) => _buildEventTile(_p.events[i]),
                      ),
                    ),

                  // ══ СЕКЦИЯ 2: Sleep History ══════════════════════════════════
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(label: 'Sleep History'),
                  ),
                  SliverToBoxAdapter(child: _buildHistorySection()),

                  // ══ СЕКЦИЯ 3: Sound Records ══════════════════════════════════
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(label: 'Sound Records'),
                  ),
                  SliverToBoxAdapter(child: _buildRecordsSection()),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Background radial gradient ────────────────────────────────────────────
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.4, -0.6),
          radius: 1.4,
          colors: [_C.grad, _C.bg1],
        ),
      ),
    );
  }

  // ── App bar / header ──────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: _C.muted, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Sleep Monitor',
                  style: GoogleFonts.montserrat(
                      fontSize: 20, fontWeight: FontWeight.w800, color: _C.cream)),
              Text('Snore & sleep-talk detection',
                  style: GoogleFonts.montserrat(fontSize: 12, color: _C.muted)),
            ]),
          ),
          if (_p.events.isNotEmpty)
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              borderRadius: 30,
              child: Text('${_p.events.length} events',
                  style: GoogleFonts.montserrat(
                      fontSize: 11, fontWeight: FontWeight.w600, color: _C.indigo)),
            ),
        ],
      ),
    );
  }

  // ── Listening status card ─────────────────────────────────────────────────
  Widget _buildStatusCard() {
    final statusText = switch (_p.status) {
      MonitoringStatus.monitoring => 'Listening…',
      MonitoringStatus.recording  => 'Recording!',
      MonitoringStatus.error      => 'Error',
      MonitoringStatus.idle       => 'Inactive',
    };
    final statusColor = switch (_p.status) {
      MonitoringStatus.monitoring => _C.indigo,
      MonitoringStatus.recording  => _C.talk,
      MonitoringStatus.error      => _C.danger,
      MonitoringStatus.idle       => _C.muted,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlassCard(
        child: Column(children: [
          if (_p.isActive)
            PulseIndicator(
              color: statusColor,
              size: 64,
              child: Icon(
                _p.status == MonitoringStatus.recording
                    ? Icons.mic_rounded
                    : Icons.hearing_rounded,
                color: statusColor,
                size: 28,
              ),
            )
          else
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.muted.withValues(alpha: 0.12),
                border: Border.all(
                    color: _C.muted.withValues(alpha: 0.3), width: 1.5),
              ),
              child: const Icon(Icons.mic_off_rounded, color: _C.muted, size: 30),
            ),
          const SizedBox(height: 16),
          Text(statusText,
              style: GoogleFonts.montserrat(
                  fontSize: 18, fontWeight: FontWeight.w700, color: statusColor)),
          const SizedBox(height: 4),
          Text(
            _p.isActive
                ? 'VAD threshold: −35 dBFS · Cooldown: 1.5 s'
                : 'Tap Start to begin monitoring',
            style: GoogleFonts.montserrat(fontSize: 11, color: _C.muted),
          ),
        ]),
      ),
    );
  }

  // ── Start / Stop button ───────────────────────────────────────────────────
  Widget _buildControlButton() {
    final isActive = _p.isActive;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () async {
          if (isActive) {
            _p.stopMonitoring();
          } else {
            final statuses = await [
              Permission.microphone,
              Permission.notification,
            ].request();

            if (statuses[Permission.microphone]!.isGranted &&
                statuses[Permission.notification]!.isGranted) {
              _p.startMonitoring();
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Для работы трекера нужны разрешения на микрофон и уведомления'),
                  backgroundColor: _C.danger,
                ),
              );
            }
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isActive
                  ? [_C.danger.withValues(alpha: 0.8), const Color(0xFF9B2C3E)]
                  : [_C.indigo, _C.indigoSoft],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isActive ? _C.danger : _C.indigo).withValues(alpha: 0.4),
                blurRadius: 20, offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(isActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
                color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(isActive ? 'Stop Monitoring' : 'Start Monitoring',
                style: GoogleFonts.montserrat(
                    fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          ]),
        ),
      ),
    );
  }

  // ── Error banner ──────────────────────────────────────────────────────────
  Widget _buildErrorBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: GlassCard(
        tintColor: _C.danger,
        padding: const EdgeInsets.all(14),
        borderRadius: 12,
        child: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: _C.danger, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_p.errorMsg ?? 'Unknown error',
                style: GoogleFonts.montserrat(fontSize: 12, color: _C.cream)),
          ),
        ]),
      ),
    );
  }

  // ── Section header (универсальный) ────────────────────────────────────────
  Widget _buildSectionHeader({required String label, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(children: [
        Text(label,
            style: GoogleFonts.montserrat(
                fontSize: 16, fontWeight: FontWeight.w700, color: _C.cream)),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: _C.muted.withValues(alpha: 0.25))),
        if (trailing != null) ...[ const SizedBox(width: 12), trailing ],
      ]),
    );
  }

  // ── Empty hint helper ─────────────────────────────────────────────────────
  Widget _buildEmptyHint({
    required IconData icon,
    required String label,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 48, color: _C.muted.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(label,
              style: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w600, color: _C.muted)),
          const SizedBox(height: 6),
          Text(hint,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                  fontSize: 12, color: _C.muted.withValues(alpha: 0.6))),
        ]),
      ),
    );
  }

  // ══ СЕКЦИЯ 1: Timeline — плитки живой сессии ══════════════════════════════
  Widget _buildEventTile(SoundEvent event) {
    final typeColor = _C.forType(event.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key('timeline_${event.id}'),
        direction: DismissDirection.endToStart,
        background: _dismissBg(),
        onDismissed: (_) => _p.deleteEvent(event),
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          borderRadius: 16,
          child: Row(children: [
            // Левый акцентный бар
            Container(
              width: 3, height: 44,
              decoration: BoxDecoration(
                  color: typeColor, borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(event.type.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(event.type.label,
                      style: GoogleFonts.montserrat(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: typeColor)),
                ]),
                const SizedBox(height: 3),
                Text(DateFormat('HH:mm:ss').format(event.startTime),
                    style: GoogleFonts.montserrat(fontSize: 12, color: _C.muted)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(event.formattedDuration,
                  style: GoogleFonts.montserrat(
                      fontSize: 14, fontWeight: FontWeight.w800, color: _C.cream)),
              const SizedBox(height: 2),
              Text('${event.peakAmplitude.toStringAsFixed(1)} dBFS',
                  style: GoogleFonts.montserrat(fontSize: 10, color: _C.muted)),
            ]),
          ]),
        ),
      ),
    );
  }

  // ══ СЕКЦИЯ 2: Sleep History — архив сессий ════════════════════════════════
  Widget _buildHistorySection() {
    final records = _p.allRecords;
    if (records.isEmpty) {
      return _buildEmptyHint(
        icon: Icons.history_rounded,
        label: 'No history yet',
        hint: 'Past sleep sessions will appear here\ngrouped by night.',
      );
    }

    // Группируем по дате (yyyy-MM-dd)
    final Map<String, List<SoundEvent>> grouped = {};
    for (final e in records) {
      final key = DateFormat('yyyy-MM-dd').format(e.startTime);
      grouped.putIfAbsent(key, () => []).add(e);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: grouped.entries.map((entry) {
          final date = DateFormat('yyyy-MM-dd').parse(entry.key);
          final label = DateFormat('d MMMM', 'ru_RU').format(date);
          final events = entry.value;
          final snoreCount  = events.where((e) => e.type == SoundEventType.snore).length;
          final talkCount   = events.where((e) => e.type == SoundEventType.talk).length;
          final mumbleCount = events.where((e) => e.type == SoundEventType.mumble).length;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              child: Row(children: [
                // Левый блок — дата
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: _C.indigo.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(DateFormat('d').format(date),
                        style: GoogleFonts.montserrat(
                            fontSize: 16, fontWeight: FontWeight.w800, color: _C.indigo)),
                    Text(DateFormat('MMM').format(date).toUpperCase(),
                        style: GoogleFonts.montserrat(fontSize: 9, color: _C.muted)),
                  ]),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Ночь $label',
                        style: GoogleFonts.montserrat(
                            fontSize: 14, fontWeight: FontWeight.w700, color: _C.cream)),
                    const SizedBox(height: 4),
                    Wrap(spacing: 8, children: [
                      if (snoreCount  > 0) _typeBadge('😴 $snoreCount',  _C.snore),
                      if (talkCount   > 0) _typeBadge('🗣️ $talkCount',   _C.talk),
                      if (mumbleCount > 0) _typeBadge('💤 $mumbleCount', _C.mumble),
                    ]),
                  ]),
                ),
                // Всего событий
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${events.length}',
                      style: GoogleFonts.montserrat(
                          fontSize: 22, fontWeight: FontWeight.w800, color: _C.cream)),
                  Text('событий',
                      style: GoogleFonts.montserrat(fontSize: 10, color: _C.muted)),
                ]),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _typeBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Text(label,
          style: GoogleFonts.montserrat(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  // ══ СЕКЦИЯ 3: Sound Records — все аудиозаписи с плеером ══════════════════
  Widget _buildRecordsSection() {
    final records = _p.allRecords;
    if (records.isEmpty) {
      return _buildEmptyHint(
        icon: Icons.audio_file_outlined,
        label: 'No recordings yet',
        hint: 'Audio recordings will appear here\nafter sleep monitoring.',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: records.map((event) => _buildRecordCard(event)).toList(),
      ),
    );
  }

  Widget _buildRecordCard(SoundEvent event) {
    final typeColor    = _C.forType(event.type);
    final isPlaying    = _p.isPlaying(event.id);
    final isActive     = _p.currentlyPlayingId == event.id;
    final progress     = isActive ? (_p.playProgress ?? 0.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key('record_${event.id}'),
        direction: DismissDirection.endToStart,
        background: _dismissBg(),
        onDismissed: (_) => _p.deleteEvent(event),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                // Меняем цвет тинта по типу события
                color: (isActive ? typeColor : const Color(0xFF1E2D50))
                    .withValues(alpha: isActive ? 0.22 : 0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? typeColor.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.09),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Основная строка ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: Row(children: [
                      // Кнопка Play/Pause
                      _buildPlayButton(event, typeColor, isPlaying, isActive),
                      const SizedBox(width: 14),
                      // Инфо: тип, время, дата
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(event.type.emoji,
                                  style: const TextStyle(fontSize: 13)),
                              const SizedBox(width: 6),
                              Text(event.type.label,
                                  style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: typeColor)),
                            ]),
                            const SizedBox(height: 3),
                            Text(
                              DateFormat('d MMM · HH:mm:ss').format(event.startTime),
                              style: GoogleFonts.montserrat(
                                  fontSize: 11, color: _C.muted),
                            ),
                          ],
                        ),
                      ),
                      // Длительность
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(event.formattedDuration,
                            style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _C.cream)),
                        Text('${event.peakAmplitude.toStringAsFixed(1)} dBFS',
                            style: GoogleFonts.montserrat(
                                fontSize: 10, color: _C.muted)),
                      ]),
                    ]),
                  ),

                  // ── Прогресс-бар (только при активном воспроизведении) ────
                  if (isActive)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              backgroundColor:
                                  typeColor.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(typeColor),
                              minHeight: 3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatProgress(progress, event.durationSeconds),
                                style: GoogleFonts.montserrat(
                                    fontSize: 10, color: _C.muted),
                              ),
                              Text(
                                event.formattedDuration,
                                style: GoogleFonts.montserrat(
                                    fontSize: 10, color: _C.muted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Круглая кнопка Play/Pause с цветом по типу события.
  Widget _buildPlayButton(
    SoundEvent event, Color typeColor, bool isPlaying, bool isActive,
  ) {
    return GestureDetector(
      onTap: () => _p.playEvent(event),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44, height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? typeColor.withValues(alpha: 0.25)
              : typeColor.withValues(alpha: 0.12),
          border: Border.all(
            color: typeColor.withValues(alpha: isActive ? 0.8 : 0.4),
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: typeColor.withValues(alpha: 0.35),
                    blurRadius: 12, spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: isActive ? typeColor : typeColor.withValues(alpha: 0.7),
          size: 22,
        ),
      ),
    );
  }

  /// Форматирует текущую позицию воспроизведения: "0:23 / 1:05"
  String _formatProgress(double progress, int totalSeconds) {
    final elapsed = (progress * totalSeconds).round();
    final m = elapsed ~/ 60;
    final s = (elapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Красный фон для Dismissible (свайп влево → удалить)
  Widget _dismissBg() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _C.danger.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: _C.danger),
    );
  }
}
