import 'package:flutter/material.dart';

extension TimeOfDayExtension on TimeOfDay {
  int compare(TimeOfDay other) {
    return inMinutes() - other.inMinutes();
  }

  int inMinutes() {
    return hour * 60 + minute;
  }

  static TimeOfDay fromMinutes(int minutes) {
    final m = minutes % (24 * 60);
    return TimeOfDay(hour: (m ~/ 60) % 24, minute: m % 60);
  }

  bool before(TimeOfDay other) {
    return compare(other) < 0;
  }

  bool after(TimeOfDay other) {
    return compare(other) > 0;
  }

  TimeOfDay add({required int minutes}) {
    final total = inMinutes() + minutes;
    return fromMinutes(total);
  }

  TimeOfDay subtract({required int minutes}) {
    final total = inMinutes() - minutes;
    return fromMinutes(total);
  }

  bool beforeOrEqual(TimeOfDay other) {
    return compare(other) <= 0;
  }

  bool afterOrEqual(TimeOfDay other) {
    return compare(other) >= 0;
  }
}
