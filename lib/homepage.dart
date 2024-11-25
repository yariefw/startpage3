import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:startpage/menu_item.dart';
import 'package:universal_html/js.dart' as js;
import 'package:startpage/config.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  double width = 300;

  DateTime get now => DateTime.now();

  String get currentTime => DateFormat.jm().format(now);
  String get currentDate => DateFormat("EEEE, MMMM d").format(now);

  double get progressHour {
    DateTime start = now.copyWith(minute: 0, second: 0);
    DateTime finish = now.copyWith(hour: now.hour + 1, minute: 0, second: 0);

    return getProgress(start: start, finish: finish, current: now);
  }

  double get progressWorkTime {
    DateTime start = now.copyWith(hour: 8, minute: 30, second: 0);
    DateTime finish = now.copyWith(hour: 17, minute: 30, second: 0);

    return getProgress(start: start, finish: finish, current: now);
  }

  double get progressDayTime {
    DateTime start = now.copyWith(hour: 0, minute: 0, second: 0);
    DateTime finish = now.copyWith(hour: 23, minute: 59, second: 0);

    return getProgress(start: start, finish: finish, current: now);
  }

  double getProgress({
    required DateTime start,
    required DateTime finish,
    required DateTime current,
  }) {
    Duration totalTime = finish.difference(start);
    Duration remainingTime = finish.difference(current);

    return (totalTime.inMinutes - remainingTime.inMinutes) /
        totalTime.inMinutes;
  }

  TextEditingController searchBookmarkController = TextEditingController();
  List<MenuItem> filteredBookmarks = [];

  List<MenuItem> get displayedBookmarks =>
      (searchBookmarkController.text.isNotEmpty)
          ? filteredBookmarks
          : bookmarks;

  List<MenuItem> searchBookmarks({required String input}) {
    if (input.isEmpty) return bookmarks;

    List<MenuItem> filtered = [];
    input = input.toLowerCase();

    for (var category in bookmarks) {
      String? label = category.label;
      List<MenuItem> submenu = [];

      if (category.submenu.isNotEmpty) {
        for (var item in category.submenu) {
          if (item.label.toLowerCase().contains(input)) {
            submenu.add(item);
          }
        }
      }

      if (submenu.isEmpty) {
        if (label.toLowerCase().contains(input)) {
          submenu = category.submenu;
        }
      }

      MenuItem item = MenuItem(
        label: label,
        submenu: submenu,
      );

      if (submenu.isNotEmpty) filtered.add(item);
    }

    return filtered;
  }

  void periodicUpdate() {
    Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) => setState(() {}),
    );
  }

  @override
  void initState() {
    super.initState();
    periodicUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, raints) {
          return Stack(
            children: [
              SizedBox(
                height: raints.maxHeight, //696
                width: raints.maxWidth, //1280
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Image.asset('assets/images/$wallpaper'),
                ),
              ),
              Container(
                width: width,
                margin: EdgeInsets.only(
                  top: 120,
                  left: 20,
                ),
                child: Column(
                  children: [
                    if (bookmarks.isNotEmpty)
                      Container(
                        height: 38,
                        width: width - 20,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextFormField(
                          controller: searchBookmarkController,
                          onChanged: (value) {
                            setState(() {
                              filteredBookmarks = searchBookmarks(input: value);
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(18, 8, 18, 0),
                            isDense: true,
                            border: InputBorder.none,
                            suffixIcon: Icon(
                              Icons.search,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 10),
                    (searchBookmarkController.text.isNotEmpty &&
                            displayedBookmarks.isEmpty)
                        ? Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: Text(
                              'Not found',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Flexible(
                            child: ScrollConfiguration(
                              behavior:
                                  ScrollConfiguration.of(context).copyWith(
                                scrollbars: false,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: displayedBookmarks.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: width,
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade300,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: width,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            displayedBookmarks[index].label,
                                            style: const TextStyle(
                                              color: Colors.blueGrey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            child: GridView.builder(
                                              shrinkWrap: true,
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 4,
                                                childAspectRatio: 0.65,
                                              ),
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  displayedBookmarks[index]
                                                      .submenu
                                                      .length,
                                              itemBuilder: (context, index2) {
                                                return IconLink(
                                                  icon: Text(
                                                    displayedBookmarks[index]
                                                        .submenu[index2]
                                                        .label[0]
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  label:
                                                      displayedBookmarks[index]
                                                          .submenu[index2]
                                                          .label,
                                                  url: displayedBookmarks[index]
                                                      .submenu[index2]
                                                      .url,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currentTime,
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Text(
                        currentDate,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 130,
                right: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ProgressBar(
                      title: 'Day Progress',
                      currentProgress: progressDayTime,
                      foregroundColor: Colors.red,
                    ),
                    ProgressBar(
                      title: 'Work Progress',
                      currentProgress: progressWorkTime,
                      foregroundColor: Colors.yellow,
                    ),
                    ProgressBar(
                      title: 'Hour Progress',
                      currentProgress: progressHour,
                      foregroundColor: Colors.blue,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 30,
                left: 30,
                child: Row(
                  children: [
                    SizedBox(
                      height: 64,
                      width: 64,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.blue,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(45),
                          child: Image.asset('assets/images/$profile'),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullname,
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Startpage',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final String title;
  final double currentProgress;
  final Color foregroundColor;

  const ProgressBar({
    super.key,
    required this.title,
    required this.currentProgress,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
        SizedBox(height: 5),
        Stack(
          children: [
            Container(
              height: 20,
              width: 195,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            Container(
              height: 20,
              width: currentProgress * 195,
              decoration: BoxDecoration(
                color: foregroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
      ],
    );
  }
}

class IconLink extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color labelColor;
  final Color backgroundColor;
  final String url;

  const IconLink({
    super.key,
    required this.icon,
    this.label = '',
    this.labelColor = Colors.white,
    this.backgroundColor = Colors.blueGrey,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        js.context.callMethod("open", [url, "_self"]);
      },
      onLongPress: () {
        js.context.callMethod("open", [url]);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 48,
            width: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              boxShadow: kElevationToShadow[2],
            ),
            child: icon,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}
