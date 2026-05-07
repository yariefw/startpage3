part of '../dashboard.dart';

mixin DashboardMethods {
  final LocalStorage storage = LocalStorage();

  final ValueNotifier<bool> pageLoadingNotifier = ValueNotifier(true);
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);

  final ValueNotifier<List<MenuItem>> fullBookmarksNotifier = ValueNotifier([]);
  final ValueNotifier<List<MenuItem>> displayedBookmarksNotifier =
      ValueNotifier([]);

  final ValueNotifier<({String uri, double? opacity})> wallpaperNotifier =
      ValueNotifier((uri: '', opacity: null));

  final ValueNotifier<({String start, String finish})> workTimeNotifier =
      ValueNotifier((start: '', finish: ''));

  DateTime get now => DateTime.now();

  List<MenuItem> searchBookmarks({
    required String query,
    List<MenuItem> bookmarks = const [],
  }) {
    if (query.isEmpty) return bookmarks;

    List<MenuItem> result = [];
    query = query.toLowerCase();

    // Search per category
    for (MenuItem category in bookmarks) {
      String? categoryLabel = category.label;
      List<MenuItem> categoryItems = [];

      if (category.items.isNotEmpty) {
        for (MenuItem item in category.items) {
          // If item label match input
          if (item.label.toLowerCase().contains(query)) {
            categoryItems.add(item);
          }
        }
      }

      if (categoryItems.isEmpty) {
        // Try to match the label too
        if (categoryLabel.toLowerCase().contains(query)) {
          // If label match, add all items
          categoryItems = category.items;
        }
      }

      MenuItem item = MenuItem(
        label: categoryLabel,
        items: categoryItems,
      );

      // If items not empty, add to result
      if (categoryItems.isNotEmpty) result.add(item);
    }

    return result;
  }

  double? getTimeProgress({
    required DateTime start,
    required DateTime finish,
    required DateTime current,
  }) {
    int totalTime;
    int remainingTime;

    bool isOvernight = finish.isBefore(start);

    if (!isOvernight) {
      // No need to calculate progress outside work hours
      if (current.isBefore(start) || current.isAfter(finish)) return null;

      totalTime = finish.difference(start).inMinutes;
      remainingTime = finish.difference(current).inMinutes;
    } else {
      // No need to calculate progress outside work hours
      if (current.isAfter(finish) && current.isBefore(start)) {
        return null;
      }

      // Start of overnight shift
      if (current == start) return 0;

      DateTime dayEnd = current.copyWith(hour: 23, minute: 59, second: 59);
      Duration dayEndDiff = dayEnd.difference(current) + Duration(seconds: 1);

      DateTime shiftedCurrent = current.add(dayEndDiff);
      DateTime shiftedFinish = finish.add(dayEndDiff);

      if (shiftedCurrent.day == shiftedFinish.day) {
        // Current is same day as (overnight) finish (ie after midnight)

        remainingTime = shiftedFinish.difference(shiftedCurrent).inMinutes;

        totalTime =
            current.copyWith(day: current.day + 1).difference(start).inMinutes +
                remainingTime;
      } else {
        // Current is same day as (overnight) start (ie before midnight)

        shiftedFinish = shiftedFinish.copyWith(day: shiftedFinish.day + 1);

        remainingTime = shiftedFinish.difference(shiftedCurrent).inMinutes;
        totalTime = current.difference(start).inMinutes + remainingTime;
      }
    }

    double progress = (totalTime - remainingTime) / totalTime;
    double progressNormalized = max(0, min(1, progress));

    return progressNormalized;
  }

  double? get progressTimeDay => getTimeProgress(
        start: now.copyWith(hour: 0, minute: 0, second: 0),
        finish: now.copyWith(hour: 23, minute: 59, second: 59),
        current: now,
      );

  double? get progressTimeHour => getTimeProgress(
        start: now.copyWith(minute: 0, second: 0),
        finish: now.copyWith(hour: now.hour + 1, minute: 0, second: 0),
        current: now,
      );

  double? get progressTimeWork => getProgressTimeWork(
        workTimeStart: workTimeNotifier.value.start,
        workTimeFinish: workTimeNotifier.value.finish,
      );

  // ----- Work Time Calculation -----

  ({
    int? hour,
    int? minute,
  }) decodeTimeString(
    String timeString,
  ) {
    List<String> time = timeString.split(':');

    int? hour = int.tryParse(time[0]);
    int? minute = int.tryParse(time[1]);

    return (hour: hour, minute: minute);
  }

  double? getProgressTimeWork({
    String? workTimeStart,
    String? workTimeFinish,
  }) {
    try {
      ({int? hour, int? minute}) decodedWorkTimeStart = decodeTimeString(
        workTimeStart ?? '',
      );

      ({int? hour, int? minute}) decodedWorkTimeFinish = decodeTimeString(
        workTimeFinish ?? '',
      );

      if (decodedWorkTimeStart.hour == null ||
          decodedWorkTimeStart.minute == null ||
          decodedWorkTimeFinish.hour == null ||
          decodedWorkTimeFinish.minute == null) {
        return null;
      }

      if (decodedWorkTimeStart.hour == decodedWorkTimeFinish.hour &&
          decodedWorkTimeStart.minute == decodedWorkTimeFinish.minute) {
        return null;
      }

      DateTime startTime = now.copyWith(
        hour: decodedWorkTimeStart.hour,
        minute: decodedWorkTimeStart.minute,
        second: 0,
      );

      DateTime finishTime = now.copyWith(
        hour: decodedWorkTimeFinish.hour,
        minute: decodedWorkTimeFinish.minute,
        second: 0,
      );

      double? progressTimeWork = getTimeProgress(
        start: startTime,
        finish: finishTime,
        current: now,
      );

      return progressTimeWork;
    } catch (e) {
      return null;
    }
  }
}
