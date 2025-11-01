import 'package:flutter/material.dart';

class HorizontalDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final Function onDateChanged;

  const HorizontalDatePicker({
    Key? key,
    required this.initialDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  State<HorizontalDatePicker> createState() => _HorizontalDatePickerState();
}

class _HorizontalDatePickerState extends State<HorizontalDatePicker> {
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController dayController;
  late FixedExtentScrollController yearController;

  final List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  late int selectedMonth;
  late int selectedDay;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialDate.month;
    selectedDay = widget.initialDate.day;
    selectedYear = widget.initialDate.year;

    monthController = FixedExtentScrollController(
      initialItem: selectedMonth - 1,
    );
    dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    yearController = FixedExtentScrollController(
      initialItem: selectedYear - 1900,
    );
  }

  @override
  void dispose() {
    monthController.dispose();
    dayController.dispose();
    yearController.dispose();
    super.dispose();
  }

  void updateDate() {
    final date = DateTime(selectedYear, selectedMonth, selectedDay);
    widget.onDateChanged(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Month picker
          Expanded(
            child: _buildPicker(
              controller: monthController,
              itemCount: 12,
              itemBuilder: (index) => months[index],
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedMonth = index + 1;
                  updateDate();
                });
              },
            ),
          ),
          const SizedBox(width: 20),
          // Day picker
          Expanded(
            child: _buildPicker(
              controller: dayController,
              itemCount: 31,
              itemBuilder: (index) => (index + 1).toString().padLeft(2, '0'),
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedDay = index + 1;
                  updateDate();
                });
              },
            ),
          ),
          const SizedBox(width: 20),
          // Year picker
          Expanded(
            child: _buildPicker(
              controller: yearController,
              itemCount: 151, // 1900 to 2050
              itemBuilder: (index) => (1900 + index).toString(),
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedYear = 1900 + index;
                  updateDate();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPicker({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) itemBuilder,
    required Function(int) onSelectedItemChanged,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Selection indicator
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white, width: 1),
              bottom: BorderSide(color: Colors.white, width: 1),
            ),
          ),
        ),
        // Scroll wheel
        ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: 50,
          perspective: 0.005,
          diameterRatio: 1.2,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: onSelectedItemChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) {
              return Center(
                child: Text(
                  itemBuilder(index),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            },
            childCount: itemCount,
          ),
        ),
      ],
    );
  }
}
