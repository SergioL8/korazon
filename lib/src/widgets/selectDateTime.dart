import 'package:korazon/src/utilities/design_variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:korazon/src/utilities/utils.dart';


class SelectDateTime extends StatefulWidget {
  const SelectDateTime({super.key, required this.onDateChanged, required this.dateTimeUse});

  final void Function(DateTime? startDateTime, DateTime? endDateTime) onDateChanged;
  final DateTimeUse dateTimeUse;

  @override
  State<SelectDateTime> createState() => _SelectDateTimeState();
}


class _SelectDateTimeState extends State<SelectDateTime> {

  bool _expanded = false; // variable to check if the widget is expanded or not
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  bool _isEndDateTime = false;


  Widget _pillButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: whiteBody
        ),
      ),
    );
  }



  void _showScrollDatePicker(bool isStartTime) {
    // temp holder so cancelling doesn’t immediately clobber your state
    // DateTime tempPickedDate = _startDate ?? DateTime.now();
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: Colors.white, // or transparent if you want
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: isStartTime ? _startDate : _endDate ?? DateTime.now(),
          minimumDate: DateTime.now(),
          maximumDate: DateTime(2100),
          onDateTimeChanged: (newDate) {
            setState(() {
              if (isStartTime) { _startDate = newDate; }
              else { _endDate = newDate; }
            });
            DateTime? startDateTime;
            DateTime? endDateTime;
            if (_startDate != null) {
              startDateTime = DateTime(
                _startDate!.year,
                _startDate!.month,
                _startDate!.day,
                _startTime!.hour,
                _startTime?.minute ?? 0,
              );
            }
            if (_endDate != null) {
              endDateTime = DateTime(
                _endDate!.year,
                _endDate!.month,
                _endDate!.day,
                _endTime!.hour,
                _endTime?.minute ?? 0,
              );
            }
            widget.onDateChanged(startDateTime, endDateTime);
          }
        ),
      ),
    );
  }


  void _showScrollTimePicker(bool isStartTime) {
    final now = DateTime.now();
    DateTime tempPickedTime = DateTime(
      now.year,
      now.month,
      now.day,
      (isStartTime ? _startTime?.hour : _endTime?.hour) ?? now.hour,
      (isStartTime ? _startTime?.minute : _endTime?.minute) ?? now.minute,
    );
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: Colors.white,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          initialDateTime: tempPickedTime,
          use24hFormat: false,
          onDateTimeChanged: (newDateTime) {
            setState(() {
              if (isStartTime) { _startTime = TimeOfDay.fromDateTime(newDateTime); }
              else { _endTime = TimeOfDay.fromDateTime(newDateTime); }
            });
            DateTime? startDateTime;
            DateTime? endDateTime;
            if (_startDate != null) {
              startDateTime = DateTime(
                _startDate!.year,
                _startDate!.month,
                _startDate!.day,
                _startTime!.hour,
                _startTime?.minute ?? 0,
              );
            }
            if (_endDate != null) {
              endDateTime = DateTime(
                _endDate!.year,
                _endDate!.month,
                _endDate!.day,
                _endTime!.hour,
                _endTime?.minute ?? 0,
              );
            }
            widget.onDateChanged(startDateTime, endDateTime);
          }
        ),
      ),
    );
  }





  @override
  Widget build(context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: ExpansionTile(
        backgroundColor: Colors.white.withOpacity(0.07),
        collapsedBackgroundColor: Colors.white.withOpacity(0.07),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: Colors.white,
            width: 1,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), 
          side: BorderSide(
            color: Colors.white,
            width: 1,
          ),
        ),
        leading: const Icon(Icons.calendar_today, color: korazonColor,),
        title: Text(
          widget.dateTimeUse == DateTimeUse.event
            ? 'Date'
            : 'Entry Time',
          style: whiteBody,),
        trailing: SizedBox(
          width: 140,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _expanded
              ? const SizedBox()
              : Text(
                style: _startDate == null || _startTime == null
                  ? whiteBody.copyWith(color: korazonColor)
                  : whiteBody.copyWith(fontSize: 14),
                _startDate == null || _startTime == null
                  ? widget.dateTimeUse == DateTimeUse.event ? '*Required' : ''
                  : '${DateFormat('d MMM').format(_startDate!)} ${_startTime!.format(context)}',
              ),
              Icon(
                color: Colors.white,
                _expanded
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_right
              ),
            ],
          ),
        ),
        onExpansionChanged: (open) {
          setState(() => _expanded = open);
          if (_startDate == null || _startTime == null) {
            final startDateTime = DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              22,
              0,
            );
            widget.onDateChanged(startDateTime, null);
          }
          _startDate ??= DateTime.now().add(Duration(days: 1));
          _startTime ??= TimeOfDay(hour: 22, minute: 0);
        },
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Start', style: whiteBody,),
                Spacer(),
                _pillButton(
                  text: _startDate != null
                      ? DateFormat('d MMM').format(_startDate!)
                      : 'Select date',
                  onTap: () {
                    _showScrollDatePicker(true);
                  } 
                ),
                const SizedBox(width: 8),
                _pillButton(
                  text: _startTime != null
                      ? _startTime!.format(context)
                      : 'Select time',
                  onTap: () {
                    _showScrollTimePicker(true);
                  } 
                ),
      
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_isEndDateTime)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('End', style: whiteBody,),
                  Spacer(),
                  _pillButton(
                    text: _endDate != null
                        ? DateFormat('d MMM').format(_endDate!)
                        : 'Select date',
                    onTap:() {
                    _showScrollDatePicker(false);
                  } 
                  ),
                  const SizedBox(width: 8),
                  _pillButton(
                    text: _endTime != null
                        ? _endTime!.format(context)
                        : 'Select time',
                    onTap: () {
                    _showScrollTimePicker(false);
                  } 
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isEndDateTime = !_isEndDateTime;
                    if (_isEndDateTime) {
                      final start = DateTime(
                        _startDate!.year,
                        _startDate!.month,
                        _startDate!.day,
                        _startTime!.hour,
                        _startTime!.minute,
                      );
                      final end = start.add(const Duration(hours: 6));
                      _endDate = DateTime(end.year, end.month, end.day);
                      _endTime = TimeOfDay.fromDateTime(end);
                    } else {
                      _endDate = null;
                      _endTime = null;
                    }
                  });
                },
                child: Text(
                  _isEndDateTime ? '-Clear end date' : '+Set end date',
                  style: whiteBody.copyWith(
                    color: korazonColor,
                    decoration: TextDecoration.underline,
                    decorationColor: korazonColor,
                    decorationThickness: 2,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}