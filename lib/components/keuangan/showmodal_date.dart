import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimerPicker extends StatefulWidget {
  final String selectedMonth;
  final String selectedYear;
  final Function(String) onMonthChanged;
  final Function(String) onYearChanged;
  final Function() onConfirm;

  const TimerPicker({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onConfirm,
  });

  @override
  _TimerPickerState createState() => _TimerPickerState();
}

class _TimerPickerState extends State<TimerPicker> {
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Bulan',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        height: 100,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: months.contains(widget.selectedMonth)
                                ? months.indexOf(widget.selectedMonth)
                                : 0,
                          ),
                          itemExtent: 30,
                          onSelectedItemChanged: (index) {
                            widget.onMonthChanged(months[index]);
                          },
                          children: months.map((month) {
                            return Text(
                              month,
                              style: TextStyle(
                                color: month == widget.selectedMonth
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Tahun',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        height: 100,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: int.parse(widget.selectedYear) - 2024,
                          ),
                          itemExtent: 30,
                          onSelectedItemChanged: (index) {
                            widget.onYearChanged((2024 + index).toString());
                          },
                          children: List.generate(3, (index) {
                            return Text(
                              (2024 + index).toString(),
                              style: TextStyle(
                                color: (2024 + index).toString() ==
                                        widget.selectedYear
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (mounted) {
                widget.onConfirm();
              }
            },
            child: const Text('Pilih'),
          ),
        ],
      ),
    );
  }
}
