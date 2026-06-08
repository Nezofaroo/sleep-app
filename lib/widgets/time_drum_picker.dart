import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';







class TimeDrumPicker extends StatefulWidget {
  final int initialHour;
  final int initialMinute;
  final int minuteStep;
  final void Function(int hour, int minute) onChanged;

  const TimeDrumPicker({
    super.key,
    required this.initialHour,
    required this.initialMinute,
    required this.onChanged,
    this.minuteStep = 1,
  });

  @override
  State<TimeDrumPicker> createState() => _TimeDrumPickerState();
}

class _TimeDrumPickerState extends State<TimeDrumPicker> {
  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minCtrl;
  late int _hour;
  late int _minute;

  static const double _itemExtent = 56.0;
  static const double _diameterRatio = 1.4;

  @override
  void initState() {
    super.initState();
    _hour   = widget.initialHour;

    final minuteItems = _minuteList();
    final minIdx = minuteItems.indexWhere((m) => m >= widget.initialMinute);
    _minute = minuteItems[minIdx < 0 ? 0 : minIdx];

    _hourCtrl = FixedExtentScrollController(initialItem: _hour);
    _minCtrl  = FixedExtentScrollController(
        initialItem: minuteItems.indexOf(_minute));
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  List<int> _minuteList() {
    final list = <int>[];
    for (int m = 0; m < 60; m += widget.minuteStep) {
      list.add(m);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final minuteItems = _minuteList();

    return SizedBox(
      height: _itemExtent * 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          _buildDrum(
            controller: _hourCtrl,
            itemCount: 24,
            labelBuilder: (i) => i.toString().padLeft(2, '0'),
            onSelected: (i) {
              _hour = i;
              widget.onChanged(_hour, _minute);
            },
          ),


          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(':',
                style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4F6EF7))),
          ),


          _buildDrum(
            controller: _minCtrl,
            itemCount: minuteItems.length,
            labelBuilder: (i) => minuteItems[i].toString().padLeft(2, '0'),
            onSelected: (i) {
              _minute = minuteItems[i];
              widget.onChanged(_hour, _minute);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrum({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) labelBuilder,
    required void Function(int) onSelected,
  }) {
    return SizedBox(
      width: 72,
      child: Stack(
        children: [

          Center(
            child: Container(
              height: _itemExtent,
              decoration: BoxDecoration(
                color: const Color(0xFF4F6EF7).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF4F6EF7).withValues(alpha: 0.35),
                    width: 1),
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: _itemExtent,
            diameterRatio: _diameterRatio,
            physics: const FixedExtentScrollPhysics(),
            perspective: 0.003,
            onSelectedItemChanged: onSelected,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: itemCount,
              builder: (context, index) {
                final isSelected =
                    controller.hasClients &&
                    controller.selectedItem == index;
                return Center(
                  child: Text(
                    labelBuilder(index),
                    style: GoogleFonts.montserrat(
                      fontSize: isSelected ? 28 : 20,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w400,
                      color: isSelected
                          ? const Color(0xFFEEF0F8)
                          : const Color(0xFF7A84A8),
                    ),
                  ),
                );
              },
            ),
          ),

          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF080C14),
                    Colors.transparent,
                    Colors.transparent,
                    const Color(0xFF080C14),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
