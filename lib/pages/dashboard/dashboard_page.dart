part of 'dashboard.dart';

class DashboardPage extends StatefulWidget {
  static String route = '/';

  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with DashboardMethods, DashboardLoaderMethods {
  RunAfterPause delayed = RunAfterPause(
    delay: Duration(milliseconds: 300),
  );

  double get bookmarksMinWidth => 325;
  double get bookmarksMaxWidth => context.screenWidth * 0.18;
  double get bookmarksNoTimerMaxWidth => context.screenWidth * 0.65;

  double get timerMinWidth => 650;

  bool get isDisplayRightPanel => context.screenWidth > timerMinWidth;

  @override
  void initState() {
    super.initState();
    loadConfig();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: ValueListenableBuilder(
          valueListenable: errorNotifier,
          builder: (context, errorMessage, child) {
            if (errorMessage != null) return viewError(message: errorMessage);
            return viewDashboard();
          },
        ),
      ),
    );
  }

  Widget viewDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            viewBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Stack(
                  children: [
                    Align(
                      alignment: (isDisplayRightPanel)
                          ? Alignment.topLeft
                          : Alignment.center,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: (!isDisplayRightPanel)
                              ? max(bookmarksNoTimerMaxWidth, bookmarksMinWidth)
                              : max(bookmarksMaxWidth, bookmarksMinWidth),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: viewBookmarks(),
                        ),
                      ),
                    ),
                    if (isDisplayRightPanel)
                      Align(
                        alignment: Alignment.topRight,
                        child: IntervalRefresherWidget(
                          interval: Duration(seconds: 1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 50),
                                child: DateTimeWidget(),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: ProgressBarWidget(
                                  title: 'Day Progress',
                                  currentProgress: progressTimeDay,
                                  foregroundColor: Colors.red,
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable: workTimeNotifier,
                                builder: (context, workTime, child) {
                                  if (workTime.start.isEmpty ||
                                      workTime.finish.isEmpty) {
                                    return SizedBox.shrink();
                                  }

                                  double? progressTimeWork =
                                      getProgressTimeWork(
                                    workTimeStart: workTime.start,
                                    workTimeFinish: workTime.finish,
                                  );

                                  if (progressTimeWork == null) {
                                    return SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: ProgressBarWidget(
                                      title: 'Work Progress',
                                      currentProgress: progressTimeWork,
                                      foregroundColor: Colors.yellow,
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: ProgressBarWidget(
                                  title: 'Hour Progress',
                                  currentProgress: progressTimeHour,
                                  foregroundColor: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget viewBackground() {
    return ValueListenableBuilder(
      valueListenable: wallpaperNotifier,
      builder: (context, wallpaper, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: (wallpaper.uri.isEmpty)
                  ? Container()
                  : (wallpaper.uri.contains('http'))
                      ? CachedNetworkImage(
                          imageUrl: wallpaper.uri,
                          fit: BoxFit.fitWidth,
                        )
                      : Image.asset(wallpaper.uri),
            ),
            Opacity(
              opacity: wallpaper.opacity ?? 0.5,
              child: Container(
                color: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget viewBookmarks() {
    return ValueListenableBuilder(
      valueListenable: fullBookmarksNotifier,
      builder: (context, fullBookmarks, child) {
        if (fullBookmarks.isEmpty) {
          return SizedBox.shrink();
        }

        return ValueListenableBuilder(
          valueListenable: displayedBookmarksNotifier,
          builder: (context, bookmarks, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: viewBookmarksSearchBar(
                    onChanged: (query) {
                      delayed.run(() {
                        List<MenuItem> result = searchBookmarks(
                          query: query,
                          bookmarks: fullBookmarks,
                        );

                        displayedBookmarksNotifier.value = result;
                      });
                    },
                  ),
                ),
                (bookmarks.isNotEmpty)
                    ? Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: bookmarks.length,
                          itemBuilder: (context, index) {
                            return ShortcutCategoryDisplayWidget(
                              label: bookmarks[index].label,
                              items: bookmarks[index].items,
                              onTap: (item) {
                                js.context.callMethod(
                                  "open",
                                  [item.url, "_self"],
                                );
                              },
                              onDoubleTap: (item) {
                                js.context.callMethod(
                                  "open",
                                  [item.url],
                                );
                              },
                              onLongPress: (item) {
                                Clipboard.setData(ClipboardData(text: item.url))
                                    .then(
                                  (_) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "URL copied to clipboard",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            );
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          'No bookmarks',
                          style: TextStyle(
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
              ],
            );
          },
        );
      },
    );
  }

  Widget viewBookmarksSearchBar({
    TextEditingController? controller,
    Function(String query)? onChanged,
  }) {
    return Container(
      height: 38,
      margin: EdgeInsets.symmetric(
        horizontal: 12,
      ),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 10),
          isDense: true,
          border: InputBorder.none,
          suffixIcon: Icon(
            Icons.search,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget viewError({
    String message = '',
  }) {
    return Center(
      child: Text(
        (message.isNotEmpty) ? message : 'An unexpected error occurred.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}
