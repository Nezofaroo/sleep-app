import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/alarm_settings.dart';
import '../providers/alarm_settings_provider.dart';
import '../widgets/time_drum_picker.dart';
import '../widgets/glassmorphism_card.dart';


class _C {
  static const bg      = Color(0xFF080C14);
  static const surface = Color(0xFF111827);
  static const accent  = Color(0xFF4F6EF7);
  static const cream   = Color(0xFFEEF0F8);
  static const muted   = Color(0xFF7A84A8);
  static const divider = Color(0xFF1E2D50);
}



class AlarmSettingsPage extends StatefulWidget {
  final AlarmSettingsProvider provider;
  const AlarmSettingsPage({super.key, required this.provider});

  @override
  State<AlarmSettingsPage> createState() => _AlarmSettingsPageState();
}

class _AlarmSettingsPageState extends State<AlarmSettingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  late final PageController _pageCtrl;

  AlarmSettings get _s => widget.provider.settings;

  @override
  void initState() {
    super.initState();
    _tabCtrl  = TabController(length: 2, vsync: this);
    _pageCtrl = PageController();
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        _pageCtrl.animateToPage(_tabCtrl.index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _update(AlarmSettings Function(AlarmSettings) fn) =>
      widget.provider.update(fn);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, _) => Scaffold(
        backgroundColor: _C.bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  onPageChanged: _tabCtrl.animateTo,
                  children: [
                    _AlarmTab(s: _s, onUpdate: _update),
                    _BedtimeTab(s: _s, onUpdate: _update),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _C.muted, size: 18),
        ),
        const SizedBox(width: 16),
        Text('Настройки',
            style: GoogleFonts.montserrat(
                fontSize: 20, fontWeight: FontWeight.w800, color: _C.cream)),
      ]),
    );
  }


  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.divider, width: 0.8),
        ),
        child: TabBar(
          controller: _tabCtrl,
          indicator: BoxDecoration(
            color: _C.accent,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelPadding: EdgeInsets.zero,
          dividerColor: Colors.transparent,
          labelStyle: GoogleFonts.montserrat(
              fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.montserrat(
              fontSize: 13, fontWeight: FontWeight.w500),
          labelColor: Colors.white,
          unselectedLabelColor: _C.muted,
          tabs: const [
            Tab(text: '  Будильник  '),
            Tab(text: '  Сон  '),
          ],
        ),
      ),
    );
  }
}




class _AlarmTab extends StatelessWidget {
  final AlarmSettings s;
  final Future<void> Function(AlarmSettings Function(AlarmSettings)) onUpdate;

  const _AlarmTab({required this.s, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildTimeCard(context),
          const SizedBox(height: 16),

          _buildMainToggle(context),

          if (s.alarmEnabled) ...[
            const SizedBox(height: 16),
            _buildRingtoneSection(context),
          ],
          const SizedBox(height: 16),

          _buildSmartAlarmSection(context),
          const SizedBox(height: 16),

          _buildSnoozeSection(context),
          const SizedBox(height: 16),

          _buildMoodSection(context),
        ],
      ),
    );
  }


  Widget _buildTimeCard(BuildContext context) {
    return GlassCard(
      tintColor: const Color(0xFF1A2540),
      child: Column(children: [
        Text('Время будильника',
            style: GoogleFonts.montserrat(
                fontSize: 12, color: _C.muted, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        TimeDrumPicker(
          initialHour:   s.alarmHour,
          initialMinute: s.alarmMinute,
          onChanged: (h, m) =>
              onUpdate((s) => s.copyWith(alarmHour: h, alarmMinute: m)),
        ),
      ]),
    );
  }


  Widget _buildMainToggle(BuildContext context) {
    return _SettingsRow(
      icon: Icons.alarm_rounded,
      label: 'Будильник',
      trailing: Switch.adaptive(
        value: s.alarmEnabled,
        activeThumbColor: _C.accent,
        onChanged: (v) => onUpdate((s) => s.copyWith(alarmEnabled: v)),
      ),
    );
  }


  Widget _buildRingtoneSection(BuildContext context) {
    return GlassCard(
      tintColor: const Color(0xFF1A2540),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Мелодия будильника'),
        const SizedBox(height: 12),

        ...BuiltInRingtone.all.map((r) => _RingtoneOption(
              ringtone: r,
              selected: s.ringtone == r.id,
              onTap: () => onUpdate((s) => s.copyWith(ringtone: r.id)),
            )),
        const Divider(color: _C.divider, height: 24),

        GestureDetector(
          onTap: () => _pickCustomFile(context),
          child: Row(children: [
            const Icon(Icons.upload_file_rounded, color: _C.accent, size: 20),
            const SizedBox(width: 10),
            Text('Загрузить свой файл',
                style: GoogleFonts.montserrat(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _C.accent)),
          ]),
        ),
        const Divider(color: _C.divider, height: 24),

        Row(children: [
          const Icon(Icons.volume_down_rounded, color: _C.muted, size: 18),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _C.accent,
                inactiveTrackColor: _C.divider,
                thumbColor: _C.accent,
                overlayColor: _C.accent.withValues(alpha: 0.15),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: s.alarmVolume,
                onChanged: (v) =>
                    onUpdate((s) => s.copyWith(alarmVolume: v)),
              ),
            ),
          ),
          const Icon(Icons.volume_up_rounded, color: _C.muted, size: 18),
        ]),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Вибрация',
                style: GoogleFonts.montserrat(
                    fontSize: 14, color: _C.cream, fontWeight: FontWeight.w500)),
            Switch.adaptive(
              value: s.vibrationEnabled,
              activeThumbColor: _C.accent,
              onChanged: (v) =>
                  onUpdate((s) => s.copyWith(vibrationEnabled: v)),
            ),
          ],
        ),
      ]),
    );
  }

  void _pickCustomFile(BuildContext context) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _C.surface,
        content: Text('Выбор файла: интеграция с file_picker',
            style: GoogleFonts.montserrat(color: _C.cream, fontSize: 12)),
      ),
    );
  }


  Widget _buildSmartAlarmSection(BuildContext context) {
    return GlassCard(
      tintColor: const Color(0xFF1A2540),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Умный будильник'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(children: [
                Text('Умный будильник',
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: _C.cream,
                        fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),

                GestureDetector(
                  onTap: () => _showSmartAlarmInfo(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _C.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.question_mark_rounded,
                        color: _C.accent, size: 12),
                  ),
                ),
              ]),
            ),
            Switch.adaptive(
              value: s.smartAlarmEnabled,
              activeThumbColor: _C.accent,
              onChanged: (v) =>
                  onUpdate((s) => s.copyWith(smartAlarmEnabled: v)),
            ),
          ],
        ),
        if (s.smartAlarmEnabled) ...[
          const Divider(color: _C.divider, height: 20),

          GestureDetector(
            onTap: () => _showWakeWindowPicker(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Период просыпания',
                    style: GoogleFonts.montserrat(
                        fontSize: 14, color: _C.cream, fontWeight: FontWeight.w500)),
                Row(children: [
                  Text('${s.wakeWindowMinutes} мин.',
                      style: GoogleFonts.montserrat(
                          fontSize: 14, color: _C.accent, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded,
                      color: _C.muted, size: 18),
                ]),
              ],
            ),
          ),
        ],
      ]),
    );
  }

  void _showSmartAlarmInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _InfoBottomSheet(
        title: 'Что такое умный будильник?',
        body:
            'Доказано, что пробуждение в фазе неглубокого сна придаёт энергии утром. '
            'Умный будильник определит этот момент и разбудит вас в заданный вами период пробуждения.',
      ),
    );
  }

  void _showWakeWindowPicker(BuildContext context) {
    final values = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60];
    int selected = s.wakeWindowMinutes;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => _PickerBottomSheet(
          title: 'Период просыпания',
          child: _WheelPicker(
            items: values.map((v) => '$v мин.').toList(),
            initialIndex: values.indexOf(selected).clamp(0, values.length - 1),
            onChanged: (i) => setS(() => selected = values[i]),
          ),
          onSave: () {
            onUpdate((s) => s.copyWith(wakeWindowMinutes: selected));
            Navigator.of(ctx).pop();
          },
          onCancel: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }


  Widget _buildSnoozeSection(BuildContext context) {
    return _SettingsRow(
      icon: Icons.snooze_rounded,
      label: 'Отложить',
      subtitle: s.formattedSnooze,
      onTap: () => _showSnoozePicker(context),
    );
  }

  void _showSnoozePicker(BuildContext context) {

    final values  = [0, 5, 10, 15, 20, 25, 30];
    final labels  = ['Выкл.', ...values.skip(1).map((v) => '$v мин.')];
    int selMinutes    = s.snoozeMinutes;
    bool selSmartSnooze = s.smartSnoozeEnabled;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => _PickerBottomSheet(
          title: 'Время откладывания',
          child: Column(
            children: [
              _WheelPicker(
                items: labels,
                initialIndex: values.indexOf(selMinutes).clamp(0, values.length - 1),
                onChanged: (i) => setS(() => selMinutes = values[i]),
              ),
              const SizedBox(height: 16),
              const Divider(color: _C.divider),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Смарт-пробуждение',
                            style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: _C.cream,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          'Постепенное уменьшение времени, на которое откладывается будильник, '
                          'для более мягкого пробуждения',
                          style: GoogleFonts.montserrat(
                              fontSize: 11, color: _C.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch.adaptive(
                    value: selSmartSnooze,
                    activeThumbColor: _C.accent,
                    onChanged: (v) => setS(() => selSmartSnooze = v),
                  ),
                ],
              ),
            ],
          ),
          onSave: () {
            onUpdate((s) => s.copyWith(
                snoozeMinutes: selMinutes,
                smartSnoozeEnabled: selSmartSnooze));
            Navigator.of(ctx).pop();
          },
          onCancel: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }


  Widget _buildMoodSection(BuildContext context) {
    return _SettingsRow(
      icon: Icons.mood_rounded,
      label: 'Настроение при пробуждении',
      subtitle: 'Опрос настроения после сигнала',
      trailing: Switch.adaptive(
        value: s.wakeMoodEnabled,
        activeThumbColor: _C.accent,
        onChanged: (v) => onUpdate((s) => s.copyWith(wakeMoodEnabled: v)),
      ),
    );
  }
}




class _BedtimeTab extends StatelessWidget {
  final AlarmSettings s;
  final Future<void> Function(AlarmSettings Function(AlarmSettings)) onUpdate;

  const _BedtimeTab({required this.s, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildBedtimeCard(),
          const SizedBox(height: 16),

          _buildReminderSection(context),
          const SizedBox(height: 16),

          _buildSleepFactorsSection(context),
        ],
      ),
    );
  }

  Widget _buildBedtimeCard() {
    return GlassCard(
      tintColor: const Color(0xFF1A2540),
      child: Column(children: [
        Text('Целевое время сна',
            style: GoogleFonts.montserrat(
                fontSize: 12, color: _C.muted, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        TimeDrumPicker(
          initialHour:   s.bedtimeHour,
          initialMinute: s.bedtimeMinute,
          onChanged: (h, m) =>
              onUpdate((s) => s.copyWith(bedtimeHour: h, bedtimeMinute: m)),
        ),
      ]),
    );
  }

  Widget _buildReminderSection(BuildContext context) {
    return GlassCard(
      tintColor: const Color(0xFF1A2540),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Напоминание'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Напомнить лечь спать',
                style: GoogleFonts.montserrat(
                    fontSize: 14, color: _C.cream, fontWeight: FontWeight.w500)),
            Switch.adaptive(
              value: s.bedtimeReminderEnabled,
              activeThumbColor: _C.accent,
              onChanged: (v) =>
                  onUpdate((s) => s.copyWith(bedtimeReminderEnabled: v)),
            ),
          ],
        ),
        if (s.bedtimeReminderEnabled) ...[
          const Divider(color: _C.divider, height: 20),
          GestureDetector(
            onTap: () => _showReminderOffsetPicker(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Напомнить заранее',
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: _C.cream,
                        fontWeight: FontWeight.w500)),
                Row(children: [
                  Text(s.formattedReminderOffset,
                      style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: _C.accent,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded,
                      color: _C.muted, size: 18),
                ]),
              ],
            ),
          ),
        ],
      ]),
    );
  }

  void _showReminderOffsetPicker(BuildContext context) {

    final hours   = List.generate(4, (i) => i);
    final minutes = List.generate(12, (i) => i * 5);

    int selH = s.reminderOffsetHours;
    int selM = s.reminderOffsetMinutes;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => _PickerBottomSheet(
          title: 'Напомнить заранее',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(children: [
                Text('Часы', style: GoogleFonts.montserrat(
                    fontSize: 11, color: _C.muted)),
                const SizedBox(height: 8),
                SizedBox(
                  width: 80,
                  height: 180,
                  child: _WheelPicker(
                    items: hours.map((h) => '$h ч.').toList(),
                    initialIndex: hours.indexOf(selH).clamp(0, hours.length - 1),
                    onChanged: (i) => setS(() => selH = hours[i]),
                  ),
                ),
              ]),
              const SizedBox(width: 16),
              Column(children: [
                Text('Минуты', style: GoogleFonts.montserrat(
                    fontSize: 11, color: _C.muted)),
                const SizedBox(height: 8),
                SizedBox(
                  width: 80,
                  height: 180,
                  child: _WheelPicker(
                    items: minutes.map((m) => '$m мин.').toList(),
                    initialIndex: minutes.indexOf(selM).clamp(0, minutes.length - 1),
                    onChanged: (i) => setS(() => selM = minutes[i]),
                  ),
                ),
              ]),
            ],
          ),
          onSave: () {
            onUpdate((s) => s.copyWith(
                reminderOffsetHours: selH,
                reminderOffsetMinutes: selM));
            Navigator.of(ctx).pop();
          },
          onCancel: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  Widget _buildSleepFactorsSection(BuildContext context) {
    return _SettingsRow(
      icon: Icons.edit_note_rounded,
      label: 'Заметки о факторах сна',
      subtitle:
          'Записывайте факторы, которые влияют на сон, чтобы мы могли лучше выполнить анализ вашего сна',
      trailing: Switch.adaptive(
        value: s.sleepFactorsEnabled,
        activeThumbColor: _C.accent,
        onChanged: (v) =>
            onUpdate((s) => s.copyWith(sleepFactorsEnabled: v)),
      ),
    );
  }
}






class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        tintColor: const Color(0xFF1A2540),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _C.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _C.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: _C.cream,
                          fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!,
                        style: GoogleFonts.montserrat(
                            fontSize: 11, color: _C.muted)),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!
            else if (onTap != null)
              const Icon(Icons.chevron_right_rounded, color: _C.muted, size: 18),
          ],
        ),
      ),
    );
  }
}


class _RingtoneOption extends StatelessWidget {
  final BuiltInRingtone ringtone;
  final bool selected;
  final VoidCallback onTap;

  const _RingtoneOption({
    required this.ringtone,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: selected ? _C.accent : _C.muted, width: 1.5),
              color: selected ? _C.accent : Colors.transparent,
            ),
            child: selected
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(ringtone.name,
              style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: selected ? _C.cream : _C.muted,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400)),
        ]),
      ),
    );
  }
}


class _InfoBottomSheet extends StatelessWidget {
  final String title;
  final String body;

  const _InfoBottomSheet({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.divider, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _C.cream)),
          const SizedBox(height: 12),
          Text(body,
              style: GoogleFonts.montserrat(
                  fontSize: 14, color: _C.muted, height: 1.5)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _C.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Готово',
                  style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}



class _PickerBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _PickerBottomSheet({
    required this.title,
    required this.child,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.divider, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: _C.muted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(title,
              style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _C.cream)),
          const SizedBox(height: 20),
          child,
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _C.muted,
                  side: const BorderSide(color: _C.divider),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: onCancel,
                child: Text('Отмена',
                    style: GoogleFonts.montserrat(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _C.accent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: onSave,
                child: Text('Сохранить',
                    style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}


class _WheelPicker extends StatelessWidget {
  final List<String> items;
  final int initialIndex;
  final void Function(int) onChanged;

  const _WheelPicker({
    required this.items,
    required this.initialIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: initialIndex),
        itemExtent: 44,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        perspective: 0.003,
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length,
          builder: (_, i) => Center(
            child: Text(
              items[i],
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _C.cream,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


Widget _sectionLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _C.accent,
              letterSpacing: 0.8)),
    );
