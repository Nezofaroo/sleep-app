import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/sleep_record.dart';
import '../theme/cyberpunk_theme.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final DatabaseHelper _db = DatabaseHelper();
  List<SleepRecord> _records = [];
  double _avgDuration = 0;
  int _totalNights = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final records = await _db.getAllRecords();
    final avg = await _db.averageSleepDuration();
    final total = await _db.totalNightsLogged();
    if (mounted) {
      setState(() {
        _records = records.where((r) => r.durationMinutes != null).toList();
        _avgDuration = avg;
        _totalNights = total;
        _loading = false;
      });
    }
  }

  Future<void> _deleteRecord(int id) async {
    await _db.deleteSleepRecord(id);
    _loadStats();
  }

  Color _qualityColor(String? q) {
    switch (q) {
      case 'Poor': return CyberpunkColors.neonPink;
      case 'Fair': return CyberpunkColors.neonYellow;
      case 'Good': return CyberpunkColors.neonCyan;
      case 'Excellent': return CyberpunkColors.neonGreen;
      default: return CyberpunkColors.textDisabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberpunkColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: CyberpunkColors.neonCyan),
              )
            : RefreshIndicator(
                onRefresh: _loadStats,
                color: CyberpunkColors.neonCyan,
                backgroundColor: CyberpunkColors.surface,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildStatCards()),
                    if (_records.isNotEmpty)
                      SliverToBoxAdapter(child: _buildBarChart()),
                    SliverToBoxAdapter(child: _buildHistoryHeader()),
                    if (_records.isEmpty)
                      SliverFillRemaining(child: _buildEmpty()),
                    if (_records.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _buildRecordTile(_records[i]),
                            childCount: _records.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STATISTICS',
            style: GoogleFonts.orbitron(
              fontSize: 12,
              color: CyberpunkColors.neonCyan,
              letterSpacing: 4,
              shadows: neonGlow(CyberpunkColors.neonCyan),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sleep Analytics',
            style: GoogleFonts.rajdhani(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: CyberpunkColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    final avgH = (_avgDuration / 60).floor();
    final avgM = (_avgDuration % 60).round();
    final avgStr = _totalNights == 0 ? '--' : '${avgH}h ${avgM.toString().padLeft(2, '0')}m';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'AVG SLEEP',
              value: avgStr,
              icon: Icons.bedtime_outlined,
              color: CyberpunkColors.neonCyan,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'NIGHTS LOGGED',
              value: '$_totalNights',
              icon: Icons.nights_stay_outlined,
              color: CyberpunkColors.neonPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'BEST SLEEP',
              value: _records.isEmpty
                  ? '--'
                  : _records
                      .reduce((a, b) =>
                          (a.durationMinutes ?? 0) > (b.durationMinutes ?? 0) ? a : b)
                      .formattedDuration,
              icon: Icons.emoji_events_outlined,
              color: CyberpunkColors.neonYellow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final recent = _records.take(7).toList().reversed.toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 220,
        decoration: cyberpunkCardDecoration(
          borderColor: CyberpunkColors.neonCyan.withOpacity(0.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LAST ${recent.length} NIGHTS',
              style: GoogleFonts.orbitron(
                fontSize: 10,
                color: CyberpunkColors.textSecondary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 120,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: CyberpunkColors.textDisabled.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 120,
                        getTitlesWidget: (val, meta) => Text(
                          '${(val / 60).floor()}h',
                          style: GoogleFonts.rajdhani(
                            color: CyberpunkColors.textDisabled,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final idx = val.toInt();
                          if (idx < 0 || idx >= recent.length) return const SizedBox();
                          return Text(
                            DateFormat('E').format(recent[idx].startTime),
                            style: GoogleFonts.rajdhani(
                              color: CyberpunkColors.textSecondary,
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(recent.length, (i) {
                    final r = recent[i];
                    final color = _qualityColor(r.quality);
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: (r.durationMinutes ?? 0).toDouble(),
                          color: color,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 600,
                            color: CyberpunkColors.surfaceVariant,
                          ),
                        ),
                      ],
                    );
                  }),
                  maxY: 600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        children: [
          Text(
            'SLEEP HISTORY',
            style: GoogleFonts.orbitron(
              fontSize: 11,
              color: CyberpunkColors.textSecondary,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: CyberpunkColors.textDisabled.withOpacity(0.3))),
        ],
      ),
    );
  }

  Widget _buildRecordTile(SleepRecord record) {
    final color = _qualityColor(record.quality);
    return Dismissible(
      key: Key('record_${record.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: CyberpunkColors.neonPink.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CyberpunkColors.neonPink.withOpacity(0.5)),
        ),
        child: const Icon(Icons.delete_outline, color: CyberpunkColors.neonPink),
      ),
      onDismissed: (_) => _deleteRecord(record.id!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: cyberpunkCardDecoration(borderColor: color.withOpacity(0.3)),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEE, MMM d').format(record.startTime),
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: CyberpunkColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('hh:mm a').format(record.startTime)} → ${record.endTime != null ? DateFormat('hh:mm a').format(record.endTime!) : 'Active'}',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: CyberpunkColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  record.formattedDuration,
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                    shadows: neonGlow(color),
                  ),
                ),
                if (record.quality != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.quality!.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      fontSize: 9,
                      color: color,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bedtime_off_outlined, size: 64, color: CyberpunkColors.textDisabled),
          const SizedBox(height: 16),
          Text(
            'NO DATA YET',
            style: GoogleFonts.orbitron(
              fontSize: 14,
              color: CyberpunkColors.textDisabled,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your sleep\nto see analytics here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: CyberpunkColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: cyberpunkCardDecoration(
        borderColor: color.withOpacity(0.4),
        glowRadius: 6,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
              shadows: neonGlow(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: 8,
              color: CyberpunkColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
