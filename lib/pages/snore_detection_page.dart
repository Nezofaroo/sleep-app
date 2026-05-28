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
  static const indigo     = Color(0xFF4B6FDB);
  static const indigoSoft = Color(0xFF3A5BC7);
  static const cream      = Color(0xFFEAEBF2);
  static const muted      = Color(0xFF7A84A8);
  static const snore      = Color(0xFF4B6FDB);
  static const talk       = Color(0xFF7C5FDB);
  static const mumble     = Color(0xFF3FA8C7);
  static const danger     = Color(0xFFDB5F6F);
}

/// Full-screen sleep monitor dashboard with glassmorphism design.
/// Uses [SleepAudioProvider] directly (inject via constructor for testability).
class SnoreDetectionPage extends StatefulWidget {
  final SleepAudioProvider provider;
  const SnoreDetectionPage({super.key, required this.provider});

  @override
  State<SnoreDetectionPage> createState() => _SnoreDetectionPageState();
}

class _SnoreDetectionPageState extends State<SnoreDetectionPage> {
  SleepAudioProvider get _p => widget.provider;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _p,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _C.bg1,
          body: Stack(
            children: [
              _buildBackground(),
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildStatusCard()),
                    SliverToBoxAdapter(child: _buildControlButton()),
                    if (_p.errorMsg != null)
                      SliverToBoxAdapter(child: _buildErrorBanner()),
                    SliverToBoxAdapter(child: _buildTimelineHeader()),
                    if (_p.events.isEmpty)
                      SliverFillRemaining(child: _buildEmptyState()),
                    if (_p.events.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                        sliver: SliverList.builder(
                          itemCount: _p.events.length,
                          itemBuilder: (_, i) =>
                              _buildEventTile(_p.events[i]),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Background radial gradient ────────────────────────────────────────────
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.4, -0.6),
          radius: 1.4,
          colors: [Color(0xFF152040), _C.bg1],
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
          // Event count badge
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

  // ── Listening status card with pulse ──────────────────────────────────────
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
          // Pulse indicator — only animated when active
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
                border: Border.all(color: _C.muted.withValues(alpha: 0.3), width: 1.5),
              ),
              child: const Icon(Icons.mic_off_rounded, color: _C.muted, size: 30),
            ),
          const SizedBox(height: 16),
          Text(statusText,
              style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: statusColor)),
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
            // Если уже работает — просто останавливаем
            _p.stopMonitoring();
          } else {
            // --- ДОБАВЛЕННЫЙ БЛОК ПРОВЕРКИ ---
            // 1. Запрашиваем микрофон и уведомления через permission_handler
            // Импорт пакета должен быть в начале файла:
            // import 'package:permission_handler/permission_handler.dart';

            Map<Permission, PermissionStatus> statuses = await [
              Permission.microphone,
              Permission.notification,
            ].request();

            if (statuses[Permission.microphone]!.isGranted &&
                statuses[Permission.notification]!.isGranted) {

              // 2. Если разрешения даны, запускаем мониторинг
              _p.startMonitoring();

            } else {
              // 3. Если пользователь отказал, показываем подсказку
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Для работы трекера нужны разрешения на микрофон и уведомления'),
                    backgroundColor: _C.danger,
                  ),
                );
              }
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

  // ── Error banner ─────────────────────────────────────────────────────────
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

  // ── Timeline header ───────────────────────────────────────────────────────
  Widget _buildTimelineHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(children: [
        Text('Timeline',
            style: GoogleFonts.montserrat(
                fontSize: 16, fontWeight: FontWeight.w700, color: _C.cream)),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: _C.muted.withValues(alpha: 0.25))),
        if (_p.events.isNotEmpty) ...[
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _p.clearEvents,
            child: Text('Clear',
                style: GoogleFonts.montserrat(fontSize: 12, color: _C.danger)),
          ),
        ],
      ]),
    );
  }

  // ── Single event tile ─────────────────────────────────────────────────────
  Widget _buildEventTile(SoundEvent event) {
    final typeColor = switch (event.type) {
      SoundEventType.snore  => _C.snore,
      SoundEventType.talk   => _C.talk,
      SoundEventType.mumble => _C.mumble,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(event.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _C.danger.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: _C.danger),
        ),
        onDismissed: (_) => _p.deleteEvent(event),
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          borderRadius: 16,
          child: Row(children: [
            // Left: type dot + time column
            Container(
              width: 3, height: 44,
              decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(event.type.emoji,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(event.type.label,
                      style: GoogleFonts.montserrat(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: typeColor)),
                ]),
                const SizedBox(height: 3),
                Text(
                  DateFormat('HH:mm:ss').format(event.startTime),
                  style: GoogleFonts.montserrat(
                      fontSize: 12, color: _C.muted),
                ),
              ]),
            ),
            // Right: duration + amplitude
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(event.formattedDuration,
                  style: GoogleFonts.montserrat(
                      fontSize: 14, fontWeight: FontWeight.w800, color: _C.cream)),
              const SizedBox(height: 2),
              Text('${event.peakAmplitude.toStringAsFixed(1)} dBFS',
                  style: GoogleFonts.montserrat(
                      fontSize: 10, color: _C.muted)),
            ]),
          ]),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.nights_stay_outlined,
            size: 64, color: _C.muted.withValues(alpha: 0.4)),
        const SizedBox(height: 16),
        Text('No events yet',
            style: GoogleFonts.montserrat(
                fontSize: 16, fontWeight: FontWeight.w600, color: _C.muted)),
        const SizedBox(height: 8),
        Text('Detected sounds will appear here\nas a live timeline.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 13, color: _C.muted.withValues(alpha: 0.6))),
      ]),
    );
  }
}
