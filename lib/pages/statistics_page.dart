import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/sleep_record.dart';
import '../theme/app_colors.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});
  @override State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final DatabaseHelper _db = DatabaseHelper();
  List<SleepRecord> _records = [];
  double _avgDuration = 0;
  int _totalNights = 0;
  bool _loading = true;

  @override void initState() { super.initState(); _loadStats(); }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final records = await _db.getAllRecords();
    final avg = await _db.averageSleepDuration();
    final total = await _db.totalNightsLogged();
    if (mounted) {
      setState(() {
        _records = records.where((r) => r.durationMinutes != null).toList();
        _avgDuration = avg; _totalNights = total; _loading = false;
      });
    }
  }

  Future<void> _deleteRecord(int id) async {
    await _db.deleteSleepRecord(id); _loadStats();
  }

  Color _qualityColor(String? q) {
    switch (q) {
      case 'Poor':      return const Color(0xFFE57373);
      case 'Fair':      return const Color(0xFFFFB74D);
      case 'Excellent': return const Color(0xFF66BB6A);
      default:          return AppColors.of(context).accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: c.accent, strokeWidth: 2.5))
            : RefreshIndicator(
                onRefresh: _loadStats,
                color: c.accent,
                backgroundColor: c.cardBg,
                child: CustomScrollView(slivers: [
                  SliverToBoxAdapter(child: _buildHeader(c)),
                  SliverToBoxAdapter(child: _buildStatCards(c)),
                  if (_records.isNotEmpty)
                    SliverToBoxAdapter(child: _buildBarChart(c)),
                  SliverToBoxAdapter(child: _buildHistoryLabel(c)),
                  if (_records.isEmpty)
                    SliverFillRemaining(child: _buildEmpty(c)),
                  if (_records.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _buildRecordTile(_records[i], c),
                          childCount: _records.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ]),
              ),
      ),
    );
  }

  Widget _buildHeader(AppColors c) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Statistics', style: GoogleFonts.montserrat(
          fontSize: 26, fontWeight: FontWeight.w800, color: c.textPrimary)),
      const SizedBox(height: 4),
      Text('Your sleep analytics at a glance',
          style: GoogleFonts.montserrat(fontSize: 14, color: c.textSecondary)),
    ]),
  );

  Widget _buildStatCards(AppColors c) {
    final avgH = (_avgDuration / 60).floor();
    final avgM = (_avgDuration % 60).round();
    final avgStr = _totalNights == 0 ? '--' : '${avgH}h ${avgM.toString().padLeft(2, '0')}m';
    final bestStr = _records.isEmpty ? '--'
        : _records.reduce((a, b) => (a.durationMinutes ?? 0) > (b.durationMinutes ?? 0) ? a : b).formattedDuration;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(children: [
        Expanded(child: _StatCard(label: 'Avg Sleep', value: avgStr, icon: Icons.bedtime_rounded, c: c)),
        const SizedBox(width: 14),
        Expanded(child: _StatCard(label: 'Nights', value: '$_totalNights', icon: Icons.nights_stay_rounded, c: c)),
        const SizedBox(width: 14),
        Expanded(child: _StatCard(label: 'Best', value: bestStr, icon: Icons.emoji_events_rounded, c: c)),
      ]),
    );
  }

  Widget _buildBarChart(AppColors c) {
    final recent = _records.take(7).toList().reversed.toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        height: 220,
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
        decoration: c.cardPressed(radius: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text('Last ${recent.length} nights',
                style: GoogleFonts.montserrat(
                    fontSize: 13, fontWeight: FontWeight.w700, color: c.textPrimary)),
          ),
          Expanded(
            child: BarChart(BarChartData(
              gridData: FlGridData(
                show: true, horizontalInterval: 120, drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(color: c.divider, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true, reservedSize: 30, interval: 120,
                  getTitlesWidget: (val, _) => Text('${(val / 60).floor()}h',
                      style: GoogleFonts.montserrat(fontSize: 10, color: c.textSecondary)),
                )),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, _) {
                    final idx = val.toInt();
                    if (idx < 0 || idx >= recent.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(DateFormat('E').format(recent[idx].startTime),
                          style: GoogleFonts.montserrat(fontSize: 10, color: c.textSecondary)),
                    );
                  },
                )),
              ),
              barGroups: List.generate(recent.length, (i) {
                final r = recent[i];
                final color = _qualityColor(r.quality);
                return BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: (r.durationMinutes ?? 0).toDouble(),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter, end: Alignment.topCenter,
                      colors: [color.withValues(alpha: 0.5), color],
                    ),
                    width: 20,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    backDrawRodData: BackgroundBarChartRodData(
                        show: true, toY: 600, color: c.chartBg),
                  ),
                ]);
              }),
              maxY: 600,
            )),
          ),
        ]),
      ),
    );
  }

  Widget _buildHistoryLabel(AppColors c) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
    child: Row(children: [
      Text('Sleep History', style: GoogleFonts.montserrat(
          fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary)),
      const SizedBox(width: 12),
      Expanded(child: Divider(color: c.divider, thickness: 1)),
    ]),
  );

  Widget _buildRecordTile(SleepRecord record, AppColors c) {
    final qc = _qualityColor(record.quality);
    return Dismissible(
      key: Key('record_${record.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: const Color(0xFFE57373).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE57373)),
      ),
      onDismissed: (_) => _deleteRecord(record.id!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: c.cardRaised(radius: 16),
        child: Row(children: [
          Container(width: 4, height: 48,
              decoration: BoxDecoration(color: qc, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(DateFormat('EEE, MMM d').format(record.startTime),
                style: GoogleFonts.montserrat(
                    fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary)),
            const SizedBox(height: 3),
            Text(
              '${DateFormat('hh:mm a').format(record.startTime)} → '
              '${record.endTime != null ? DateFormat('hh:mm a').format(record.endTime!) : 'Active'}',
              style: GoogleFonts.montserrat(fontSize: 12, color: c.textSecondary),
            ),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(record.formattedDuration,
                style: GoogleFonts.montserrat(
                    fontSize: 15, fontWeight: FontWeight.w800, color: qc)),
            if (record.quality != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: qc.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(record.quality!,
                    style: GoogleFonts.montserrat(
                        fontSize: 9, fontWeight: FontWeight.w700, color: qc)),
              ),
            ],
          ]),
        ]),
      ),
    );
  }

  Widget _buildEmpty(AppColors c) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        padding: const EdgeInsets.all(28),
        decoration: c.cardRaised(radius: 80),
        child: Icon(Icons.bedtime_off_outlined, size: 52, color: c.textDisabled),
      ),
      const SizedBox(height: 24),
      Text('No data yet', style: GoogleFonts.montserrat(
          fontSize: 18, fontWeight: FontWeight.w700, color: c.textSecondary)),
      const SizedBox(height: 8),
      Text('Start tracking your sleep\nto see analytics here.',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
              fontSize: 14, color: c.textDisabled, height: 1.5)),
    ]),
  );
}

class _StatCard extends StatelessWidget {
  final String label; final String value; final IconData icon; final AppColors c;
  const _StatCard({required this.label, required this.value, required this.icon, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: c.cardRaised(radius: 16),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: c.iconBadge(radius: 10),
          child: Icon(icon, color: c.accent, size: 20),
        ),
        const SizedBox(height: 10),
        Text(value, style: GoogleFonts.montserrat(
            fontSize: 14, fontWeight: FontWeight.w800, color: c.textPrimary),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.montserrat(
            fontSize: 10, fontWeight: FontWeight.w500, color: c.textSecondary),
            textAlign: TextAlign.center),
      ]),
    );
  }
}
