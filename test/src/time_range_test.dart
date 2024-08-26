import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_range/src/time_list.dart';
import 'package:time_range/src/time_range.dart';
import 'package:time_range/src/util/key_extension.dart';

import '../helpers/pump_app.dart';
import '../utils/param_factory.dart';

void main() {
  group(
    'TimeRange',
    () {
      group(
        'Render',
        () {
          testWidgets('two list of time', (WidgetTester tester) async {
            await tester.pumpApp(
              TimeRange(
                timeBlock: ParamFactory.timeBlock,
                firstTime: ParamFactory.firstTime,
                lastTime: ParamFactory.secondTime,
                timeStep: ParamFactory.timeStep,
                onRangeCompleted: (range) {},
              ),
            );

            final timeList = find.byType(TimeList);

            expect(timeList, findsNWidgets(2));
          });
          testWidgets(
            'title for to and from widget if we pass those arguments',
            (WidgetTester tester) async {
              await tester.pumpApp(
                TimeRange(
                  timeBlock: ParamFactory.timeBlock,
                  firstTime: ParamFactory.firstTime,
                  lastTime: ParamFactory.secondTime,
                  timeStep: ParamFactory.timeStep,
                  toTitle: const Text(ParamFactory.toTitle),
                  fromTitle: const Text(ParamFactory.fromTitle),
                  onRangeCompleted: (range) {},
                ),
              );

              final toTitleWidget = find.text(ParamFactory.toTitle);
              final fromTitleWidget = find.text(ParamFactory.fromTitle);

              expect(toTitleWidget, findsOneWidget);
              expect(fromTitleWidget, findsOneWidget);
            },
          );
          testWidgets(
            'morning-to-afternoon time range',
            (WidgetTester tester) async {
              await tester.pumpApp(
                TimeRange(
                  timeBlock: 5,
                  firstTime: const TimeOfDay(hour: 9, minute: 15),
                  lastTime: const TimeOfDay(hour: 21, minute: 45),
                  timeStep: 30,
                  toTitle: const Text(ParamFactory.toTitle),
                  fromTitle: const Text(ParamFactory.fromTitle),
                  onRangeCompleted: (range) {},
                ),
              );
              final lateMorning = find.textContaining('11:15 AM');
              expect(lateMorning, findsOneWidget);

              final lateNight = find.textContaining('11:15 PM');
              expect(lateNight, findsNothing);
            },
          );
          testWidgets(
            'afternoon-to-morning time range',
            (WidgetTester tester) async {
              await tester.pumpApp(
                TimeRange(
                  timeBlock: 5,
                  firstTime: const TimeOfDay(hour: 21, minute: 15),
                  lastTime: const TimeOfDay(hour: 9, minute: 45),
                  timeStep: 30,
                  toTitle: const Text(ParamFactory.toTitle),
                  fromTitle: const Text(ParamFactory.fromTitle),
                  onRangeCompleted: (range) {},
                ),
              );
              final lateMorning = find.textContaining('11:15 AM');
              expect(lateMorning, findsNothing);

              final lateNight = find.textContaining('11:15 PM');
              expect(lateNight, findsOneWidget);
            },
          );
        },
      );
      group(
        'Change',
        () {
          testWidgets(
            'selected [from] and [to] times if we tap a child of its '
            'respective list',
            (WidgetTester tester) async {
              await tester.pumpApp(
                TimeRange(
                  key: const Key('tr'),
                  timeBlock: ParamFactory.timeBlock,
                  firstTime: ParamFactory.firstTime,
                  lastTime: ParamFactory.secondTime,
                  timeStep: ParamFactory.timeStep,
                  toTitle: const Text(ParamFactory.toTitle),
                  fromTitle: const Text(ParamFactory.fromTitle),
                  activeBackgroundColor: ParamFactory.blue,
                  onRangeCompleted: (range) {},
                ),
              );

              var activeTimes = find.byWidgetPredicate(
                (widget) => ParamFactory.isContainerWithColor(
                  widget,
                  ParamFactory.blue,
                ),
              );
              expect(activeTimes, findsNothing);

              final fromTime = find.byKey(const Key('tr_start_10:10'));
              expect(fromTime, findsOneWidget);

              await tester.tap(fromTime);
              await tester.pumpAndSettle();

              activeTimes = find.byWidgetPredicate(
                (widget) => ParamFactory.isContainerWithColor(
                  widget,
                  ParamFactory.blue,
                ),
              );
              expect(activeTimes, findsOneWidget);

              final toTime = find.byKey(const Key('tr_end_10:30'));
              expect(toTime, findsOneWidget);

              await tester.tap(toTime);
              await tester.pumpAndSettle();

              activeTimes = find.byWidgetPredicate(
                (widget) => ParamFactory.isContainerWithColor(
                  widget,
                  ParamFactory.blue,
                ),
              );
              expect(activeTimes, findsNWidgets(2));
            },
          );
          testWidgets(
            'reselected [from] keeps [to] if to is actually after from '
            '(morning-to-afternoon)',
            (WidgetTester tester) async {
              await tester.pumpApp(
                TimeRange(
                  key: const Key('tr'),
                  timeBlock: 30,
                  firstTime: const TimeOfDay(hour: 11, minute: 45),
                  lastTime: const TimeOfDay(hour: 13, minute: 15),
                  timeStep: 15,
                  toTitle: const Text(ParamFactory.toTitle),
                  fromTitle: const Text(ParamFactory.fromTitle),
                  activeBackgroundColor: ParamFactory.blue,
                  onRangeCompleted: (range) {},
                  alwaysUse24HourFormat: true,
                ),
              );

              final fromTime = find.byKey(const Key('tr_start_11:45'));
              expect(fromTime, findsOneWidget);
              await tester.tap(fromTime);
              await tester.pumpAndSettle();

              final toTime = find.byKey(const Key('tr_end_13:15'));
              expect(toTime, findsOneWidget);
              await tester.tap(toTime);
              await tester.pumpAndSettle();

              final newFromTime = find.byKey(const Key('tr_start_12:15'));
              expect(newFromTime, findsOneWidget);
              await tester.tap(newFromTime);
              await tester.pumpAndSettle();

              final activeTimes = find.byWidgetPredicate(
                (widget) => ParamFactory.isContainerWithColor(
                  widget,
                  ParamFactory.blue,
                ),
              );
              expect(activeTimes, findsNWidgets(2));
            },
          );

          testWidgets(
            'reselected [from] keeps [to] if to is actually after from '
            '(afternoon-to-morning)',
            (WidgetTester tester) async {
              await tester.pumpApp(
                TimeRange(
                  key: const Key('tr'),
                  timeBlock: 30,
                  firstTime: const TimeOfDay(hour: 23, minute: 45),
                  lastTime: const TimeOfDay(hour: 1, minute: 15),
                  timeStep: 15,
                  toTitle: const Text(ParamFactory.toTitle),
                  fromTitle: const Text(ParamFactory.fromTitle),
                  activeBackgroundColor: ParamFactory.blue,
                  onRangeCompleted: (range) {},
                  alwaysUse24HourFormat: true,
                ),
              );

              final fromTime = find.byKey(const Key('tr_start_23:45'));
              expect(fromTime, findsOneWidget);
              await tester.tap(fromTime);
              await tester.pumpAndSettle();

              final toTime = find.byKey(const Key('tr_end_1:15'));
              expect(toTime, findsOneWidget);
              await tester.tap(toTime);
              await tester.pumpAndSettle();

              final newFromTime = find.byKey(const Key('tr_start_0:15'));
              expect(newFromTime, findsOneWidget);
              await tester.tap(newFromTime);
              await tester.pumpAndSettle();

              final activeTimes = find.byWidgetPredicate(
                (widget) => ParamFactory.isContainerWithColor(
                  widget,
                  ParamFactory.blue,
                ),
              );
              expect(activeTimes, findsNWidgets(2));
            },
          );

          testWidgets(
            'reselected [from] cancels [to] if to is actually before from '
            '(morning-to-afternoon)',
            (WidgetTester tester) async {
              await tester.pumpApp(
                TimeRange(
                  key: const Key('tr'),
                  timeBlock: 30,
                  firstTime: const TimeOfDay(hour: 11, minute: 45),
                  lastTime: const TimeOfDay(hour: 23, minute: 15),
                  timeStep: 15,
                  toTitle: const Text(ParamFactory.toTitle),
                  fromTitle: const Text(ParamFactory.fromTitle),
                  activeBackgroundColor: ParamFactory.blue,
                  onRangeCompleted: (range) {},
                  alwaysUse24HourFormat: true,
                ),
              );

              final fromTime = find.byKey(const Key('tr_start_11:45'));
              expect(fromTime, findsOneWidget);
              await tester.tap(fromTime);
              await tester.pumpAndSettle();

              final toTime = find.byKey(const Key('tr_end_12:15'));
              expect(toTime, findsOneWidget);
              await tester.tap(toTime);
              await tester.pumpAndSettle();

              final newFromTime = find.byKey(const Key('tr_start_13:15'));
              expect(newFromTime, findsOneWidget);
              await tester.tap(newFromTime);
              await tester.pumpAndSettle();

              final activeTimes = find.byWidgetPredicate(
                (widget) => ParamFactory.isContainerWithColor(
                  widget,
                  ParamFactory.blue,
                ),
              );
              expect(activeTimes, findsNWidgets(1));
            },
          );

          testWidgets(
            'reselected [from] cancels [to] if to is actually before from '
            '(afternoon-to-morning)',
            (WidgetTester tester) async {
              await tester.pumpApp(
                TimeRange(
                  key: const Key('tr'),
                  timeBlock: 15,
                  firstTime: const TimeOfDay(hour: 23, minute: 45),
                  lastTime: const TimeOfDay(hour: 11, minute: 15),
                  timeStep: 15,
                  toTitle: const Text(ParamFactory.toTitle),
                  fromTitle: const Text(ParamFactory.fromTitle),
                  activeBackgroundColor: ParamFactory.blue,
                  onRangeCompleted: (range) {},
                  alwaysUse24HourFormat: true,
                ),
              );

              final fromTime = find.byKey(const Key('tr_start_23:45'));
              expect(fromTime, findsOneWidget);
              await tester.tap(fromTime);
              await tester.pumpAndSettle();

              final toTime = find.byKey(const Key('tr_end_0:0'));
              expect(toTime, findsOneWidget);
              await tester.tap(toTime);
              await tester.pumpAndSettle();

              final newFromTime = find.byKey(const Key('tr_start_0:15'));
              expect(newFromTime, findsOneWidget);
              await tester.tap(newFromTime);
              await tester.pumpAndSettle();

              final activeTimes = find.byWidgetPredicate(
                (widget) => ParamFactory.isContainerWithColor(
                  widget,
                  ParamFactory.blue,
                ),
              );
              expect(activeTimes, findsNWidgets(1));
            },
          );

          testWidgets(
            'reselected [from] cancels [to] if to is inconsistent with block '
            'duration (morning-to-afternoon)',
            (WidgetTester tester) async {
              await tester.pumpApp(
                TimeRange(
                  key: const Key('tr'),
                  timeBlock: 60,
                  firstTime: const TimeOfDay(hour: 11, minute: 45),
                  lastTime: const TimeOfDay(hour: 23, minute: 15),
                  timeStep: 15,
                  toTitle: const Text(ParamFactory.toTitle),
                  fromTitle: const Text(ParamFactory.fromTitle),
                  activeBackgroundColor: ParamFactory.blue,
                  onRangeCompleted: (range) {},
                  alwaysUse24HourFormat: true,
                ),
              );

              final fromTime = find.byKey(const Key('tr_start_11:45'));
              expect(fromTime, findsOneWidget);
              await tester.tap(fromTime);
              await tester.pumpAndSettle();

              final toTime = find.byKey(const Key('tr_end_13:45'));
              expect(toTime, findsOneWidget);
              await tester.tap(toTime);
              await tester.pumpAndSettle();

              final newFromTime = find.byKey(const Key('tr_start_12:0'));
              expect(newFromTime, findsOneWidget);
              await tester.tap(newFromTime);
              await tester.pumpAndSettle();

              final activeTimes = find.byWidgetPredicate(
                (widget) => ParamFactory.isContainerWithColor(
                  widget,
                  ParamFactory.blue,
                ),
              );
              expect(activeTimes, findsNWidgets(1));
            },
          );

          testWidgets(
            'reselected [from] cancels [to] if to is inconsistent with block '
            'duration (morning-to-afternoon)',
            (WidgetTester tester) async {
              await tester.pumpApp(
                TimeRange(
                  key: const Key('tr'),
                  timeBlock: 60,
                  firstTime: const TimeOfDay(hour: 23, minute: 45),
                  lastTime: const TimeOfDay(hour: 11, minute: 15),
                  timeStep: 15,
                  toTitle: const Text(ParamFactory.toTitle),
                  fromTitle: const Text(ParamFactory.fromTitle),
                  activeBackgroundColor: ParamFactory.blue,
                  onRangeCompleted: (range) {},
                  alwaysUse24HourFormat: true,
                ),
              );

              final fromTime = find.byKey(const Key('tr_start_23:45'));
              expect(fromTime, findsOneWidget);
              await tester.tap(fromTime);
              await tester.pumpAndSettle();

              final toTime = find.byKey(const Key('tr_end_1:45'));
              expect(toTime, findsOneWidget);
              await tester.tap(toTime);
              await tester.pumpAndSettle();

              final newFromTime = find.byKey(const Key('tr_start_0:0'));
              expect(newFromTime, findsOneWidget);
              await tester.tap(newFromTime);
              await tester.pumpAndSettle();

              final activeTimes = find.byWidgetPredicate(
                (widget) => ParamFactory.isContainerWithColor(
                  widget,
                  ParamFactory.blue,
                ),
              );
              expect(activeTimes, findsNWidgets(1));
            },
          );
        },
      );
      group(
        'Function',
        () {
          testWidgets(
            'callback function is called when press a button',
            (WidgetTester tester) async {
              var callbackCalls = false;

              await tester.pumpApp(
                TimeRange(
                  timeBlock: ParamFactory.timeBlock,
                  firstTime: ParamFactory.firstTime,
                  lastTime: ParamFactory.secondTime,
                  timeStep: ParamFactory.timeStep,
                  toTitle: const Text(ParamFactory.toTitle),
                  fromTitle: const Text(ParamFactory.fromTitle),
                  activeBackgroundColor: ParamFactory.blue,
                  onRangeCompleted: (_) => callbackCalls = true,
                ),
              );

              final fromTime = find.textContaining(RegExp('10:10'));
              await tester.tap(fromTime);
              await tester.pumpAndSettle();

              final toTime = find.textContaining(RegExp('10:30'));
              await tester.tap(toTime);
              await tester.pumpAndSettle();

              expect(callbackCalls, isTrue);
            },
          );
        },
      );

      group(
        'Format',
        () {
          testWidgets(
            'format for time shown in time button is 24 hour format if we pass [alwaysUse24HourFormat] as true and 12 hr format if we pass false',
            (WidgetTester tester) async {
              final twelveHrFormat =
                  RegExp(r'^(1[0-2]|0?[1-9]):[0-5][0-9] (AM|PM)$');
              final twentyFourHrFormat =
                  RegExp('r^(([01]?[0-9]|2[0-3]):[0-5][0-9])');

              await tester.pumpApp(
                TimeRange(
                  timeBlock: ParamFactory.timeBlock,
                  firstTime: ParamFactory.firstTime,
                  lastTime: ParamFactory.secondTime,
                  onRangeCompleted: (result) {},
                  alwaysUse24HourFormat: ParamFactory.alwaysUser24HourFormat,
                ),
              );

              final fromTime = find.textContaining(
                ParamFactory.alwaysUser24HourFormat
                    ? twentyFourHrFormat
                    : twelveHrFormat,
              );

              final toTime = find.textContaining(
                ParamFactory.alwaysUser24HourFormat
                    ? twentyFourHrFormat
                    : twelveHrFormat,
              );

              expect(fromTime, findsWidgets);
              expect(toTime, findsWidgets);
            },
          );
        },
      );
    },
  );
}

void debugRelevantWidgets() {
  // debug print all widgets whose key starts with 'tr_'
  final relevantWidgets = find.byWidgetPredicate(
    (widget) => widget.key?.value.startsWith('tr_') ?? false,
  );
  for (final widget in relevantWidgets.evaluate()) {
    debugPrint(widget.widget.key?.value);
  }
}
