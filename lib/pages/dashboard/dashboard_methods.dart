part of 'dashboard.dart';

mixin DashboardMethods {
  ValueNotifier<List<MenuItem>> displayedBookmarksNotifier = ValueNotifier([]);

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

  double getTimeProgress({
    required DateTime start,
    required DateTime finish,
    required DateTime current,
  }) {
    int totalTime = finish.difference(start).inMinutes;
    int remainingTime = finish.difference(current).inMinutes;

    double progress = (totalTime - remainingTime) / totalTime;
    double progressNormalized = max(0, min(1, progress));

    return progressNormalized;
  }

  double get progressTimeDay => getTimeProgress(
        start: now.copyWith(hour: 0, minute: 0, second: 0),
        finish: now.copyWith(hour: 23, minute: 59, second: 59),
        current: now,
      );

  double get progressTimeHour => getTimeProgress(
        start: now.copyWith(minute: 0, second: 0),
        finish: now.copyWith(hour: now.hour + 1, minute: 0, second: 0),
        current: now,
      );

  // ----- Work Time Calculation -----

  ({int? hour, int? minute})? decodedWorkTimeStart;
  ({int? hour, int? minute})? decodedWorkTimeFinish;

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
      // If cache empty, try to fill from params
      if (decodedWorkTimeStart == null || decodedWorkTimeFinish == null) {
        // If params empty, nothing to work with
        if ((workTimeStart?.isEmpty ?? true) ||
            (workTimeFinish?.isEmpty ?? true)) {
          return null;
        }

        // Decode params
        decodedWorkTimeStart = decodeTimeString(workTimeStart ?? '');
        decodedWorkTimeFinish = decodeTimeString(workTimeFinish ?? '');
      }

      if (decodedWorkTimeStart?.hour == null ||
          decodedWorkTimeStart?.minute == null ||
          decodedWorkTimeFinish?.hour == null ||
          decodedWorkTimeFinish?.minute == null) {
        return null;
      }

      double progressTimeWork = getTimeProgress(
        start: now.copyWith(
          hour: decodedWorkTimeStart?.hour,
          minute: decodedWorkTimeStart?.minute,
          second: 0,
        ),
        finish: now.copyWith(
          hour: decodedWorkTimeFinish?.hour,
          minute: decodedWorkTimeFinish?.minute,
          second: 0,
        ),
        current: now,
      );

      return progressTimeWork;
    } catch (e) {
      return null;
    }
  }
}
