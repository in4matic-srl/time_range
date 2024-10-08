import 'package:flutter/material.dart';
import 'package:time_range/src/time_button.dart';
import 'package:time_range/src/util/key_extension.dart';
import 'package:time_range/src/util/time_of_day_extension.dart';

typedef TimeSelectedCallback = void Function(TimeOfDay hour);

class TimeList extends StatefulWidget {
  const TimeList({
    super.key,
    this.padding = 0,
    required this.timeStep,
    required this.firstTime,
    required this.lastTime,
    required this.onHourSelected,
    this.initialTime,
    this.borderColor,
    this.activeBorderColor,
    this.backgroundColor,
    this.activeBackgroundColor,
    this.textStyle,
    this.activeTextStyle,
    this.alwaysUse24HourFormat = false,
  });

  final TimeOfDay firstTime;
  final TimeOfDay lastTime;
  final TimeOfDay? initialTime;
  final int timeStep;
  final double padding;
  final TimeSelectedCallback onHourSelected;
  final Color? borderColor;
  final Color? activeBorderColor;
  final Color? backgroundColor;
  final Color? activeBackgroundColor;
  final TextStyle? textStyle;
  final TextStyle? activeTextStyle;
  final bool alwaysUse24HourFormat;

  @override
  State<TimeList> createState() => _TimeListState();
}

class _TimeListState extends State<TimeList> {
  final ScrollController _scrollController = ScrollController();
  final double itemExtent = 90;
  TimeOfDay? _selectedHour;
  List<TimeOfDay?> hours = [];

  @override
  void initState() {
    super.initState();
    _initialData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateScroll(hours.indexOf(widget.initialTime));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(TimeList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.firstTime != widget.firstTime ||
        oldWidget.timeStep != widget.timeStep ||
        oldWidget.initialTime != widget.initialTime) {
      _initialData();
      _animateScroll(hours.indexOf(widget.initialTime));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initialData() {
    _selectedHour = widget.initialTime;
    _loadHours();
  }

  void _loadHours() {
    hours.clear();
    var minutes = widget.firstTime.inMinutes();
    var endMinutes = widget.lastTime.inMinutes();
    if (minutes > endMinutes) {
      endMinutes += TimeOfDay.hoursPerDay * TimeOfDay.minutesPerHour;
    }
    while (minutes <= endMinutes) {
      hours.add(TimeOfDayExtension.fromMinutes(minutes));
      minutes += widget.timeStep;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: widget.padding),
        itemCount: hours.length,
        itemExtent: itemExtent,
        itemBuilder: (BuildContext context, int index) {
          final hour = hours[index]!;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TimeButton(
              key: widget.key?.withSuffix('_${hour.hour}:${hour.minute}'),
              borderColor: widget.borderColor,
              activeBorderColor: widget.activeBorderColor,
              backgroundColor: widget.backgroundColor,
              activeBackgroundColor: widget.activeBackgroundColor,
              textStyle: widget.textStyle,
              activeTextStyle: widget.activeTextStyle,
              time: MaterialLocalizations.of(context).formatTimeOfDay(
                hour,
                alwaysUse24HourFormat: widget.alwaysUse24HourFormat,
              ),
              value: _selectedHour == hour,
              onSelect: (_) => _selectHour(index, hour),
            ),
          );
        },
      ),
    );
  }

  void _selectHour(int index, TimeOfDay hour) {
    _selectedHour = hour;
    _animateScroll(index);
    widget.onHourSelected(hour);
    setState(() {});
  }

  void _animateScroll(int index) {
    var offset = index < 0 ? 0.0 : index * itemExtent;
    if (offset > _scrollController.position.maxScrollExtent) {
      offset = _scrollController.position.maxScrollExtent;
    }
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }
}
