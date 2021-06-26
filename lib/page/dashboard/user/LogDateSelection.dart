import 'package:do_an_da_nganh/utils/utils.dart';
import 'package:flutter/material.dart';

class LogDateSelection extends StatefulWidget {
  final Function(DateTime, DateTime) viewFunction;
  LogDateSelection(this.viewFunction);
  @override
  _LogDateSelectionState createState() => _LogDateSelectionState();
}

class _LogDateSelectionState extends State<LogDateSelection> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _fromTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _toTime = TimeOfDay.now();

  TextEditingController _dateController = TextEditingController();
  TextEditingController _fromTimeController = TextEditingController();
  TextEditingController _toTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = getDate(_selectedDate);
    _fromTimeController.text = getTime(_fromTime);
    _toTimeController.text = getTime(_toTime);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _fromTimeController.dispose();
    _toTimeController.dispose();
    super.dispose();
  }

  Future<DateTime?> _selectDate(BuildContext context,
      {DateTime? initialDate}) async {
    if (initialDate == null) {
      initialDate = DateTime.now();
    }
    return await showDatePicker(
        context: context,
        initialDate: initialDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2020),
        lastDate: DateTime.now());
  }

  Future<TimeOfDay?> _selectTime(BuildContext context,
      {TimeOfDay initialTime = const TimeOfDay(hour: 0, minute: 0)}) async {
    return await showTimePicker(context: context, initialTime: initialTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyScrollView(
        slivers: [
          MySliverAppBar(
            title: MySliverAppBar.defaultTitle("Chọn thời điểm xem"),
            leading: MySliverAppBar.defaultLedding(context),
          ),
          MySliverBody(
            child: Column(
              children: [
                SizedBox(height: 40),
                MyTextFormField(
                  labelText: 'Ngày Xem',
                  controller: _dateController,
                  readOnly: true,
                  onTap: () {
                    _selectDate(context, initialDate: _selectedDate)
                        .then((date) {
                      setState(() {
                        if (date != null) {
                          _dateController.text = getDate(date);
                          _selectedDate = date;
                        }
                      });
                    });
                  },
                ),
                MyTextFormField(
                  labelText: 'Từ',
                  controller: _fromTimeController,
                  readOnly: true,
                  onTap: () {
                    _selectTime(context, initialTime: _fromTime).then((time) {
                      setState(() {
                        if (time != null) {
                          _fromTimeController.text = getTime(time);
                          _fromTime = time;
                        }
                      });
                    });
                  },
                ),
                MyTextFormField(
                  labelText: 'Đến',
                  controller: _toTimeController,
                  readOnly: true,
                  onTap: () {
                    _selectTime(context, initialTime: _toTime).then((time) {
                      setState(() {
                        if (time != null) {
                          _toTimeController.text = getTime(time);
                          _toTime = time;
                        }
                      });
                    });
                  },
                ),
                MyButton(
                    child: MyButton.defaultText('Xem'.toUpperCase()),
                    onPressed: () {
                      DateTime fromTime = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _fromTime.hour,
                        _fromTime.minute,
                      );
                      DateTime toTime = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _toTime.hour,
                        _toTime.minute,
                        59,
                      );
                      widget.viewFunction(fromTime, toTime);
                    }),
                SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
