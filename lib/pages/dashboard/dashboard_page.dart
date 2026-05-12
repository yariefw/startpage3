part of 'dashboard.dart';

class DashboardPageArgs {
  String? envConfig;
  DashboardPageArgs({this.envConfig});
}

class DashboardPage extends StatefulWidget {
  static String route = '/startpage';

  const DashboardPage({super.key, required this.args});
  final DashboardPageArgs args;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with
        DashboardMethods,
        DashboardParamMethods,
        BookmarksLoaderMethods,
        WallpaperLoaderMethods,
        WorkTimeLoaderMethods,
        DashboardConfigurationMethods {
  DashboardPageArgs get args => widget.args;

  RunAfterPause delayed = RunAfterPause(
    delay: Duration(milliseconds: 300),
  );

  double get bookmarksMinWidth => 325;
  double get bookmarksMaxWidth => context.screenWidth * 0.18;
  double get bookmarksNoTimerMaxWidth => context.screenWidth * 0.65;

  double get timerMinWidth => 650;

  bool get isDisplayInfoPanel => context.screenWidth > timerMinWidth;

  Future<dynamic> showPageSettings({
    bool isFirstLoad = false,
  }) async {
    DashboardConfigurationData savedConfig = getConfiguration(
      envConfig: args.envConfig,
    );

    return showDialogSettings(
      context: context,
      configuration: DashboardConfigurationData(
        bookmarks: (args.envConfig?.isNotEmpty ?? false)
            ? args.envConfig ?? ''
            : (pBookmarksDirect.isNotEmpty)
                ? pBookmarksDirect
                : (pBookmarksUrl.isNotEmpty)
                    ? pBookmarksUrl
                    : savedConfig.bookmarks,
        bookmarksKey: (pBookmarksKey.isNotEmpty)
            ? pBookmarksKey
            : savedConfig.bookmarksKey,
        wallpaperUrl: (pWallpaperUrl.isNotEmpty)
            ? pWallpaperUrl
            : savedConfig.wallpaperUrl,
        wallpaperOpacity: (pWallpaperOpacity.isNotEmpty)
            ? pWallpaperOpacity.toDouble(orElse: 0.5)
            : savedConfig.wallpaperOpacity,
        workStart: (pWorkStart.isNotEmpty) ? pWorkStart : savedConfig.workStart,
        workFinish:
            (pWorkFinish.isNotEmpty) ? pWorkFinish : savedConfig.workFinish,
      ),
      isFirstLoad: isFirstLoad,
      onConfirm: (configuration) => applyConfiguration(
        configuration: configuration,
        isFirstLoad: isFirstLoad,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // html.window.localStorage['config_startpage'] = '';
    // html.window.localStorage['config_startpage_key'] = '';

    if (!isSavedBookmarksAvailable) {
      // First launch, show settings
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showPageSettings(isFirstLoad: true),
      );
    } else {
      // Not first launch, auto apply
      DashboardConfigurationData savedConfig = getConfiguration(
        envConfig: args.envConfig,
      );

      applyConfiguration(configuration: savedConfig);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: ValueListenableBuilder(
          valueListenable: pageLoadingNotifier,
          builder: (context, isPageLoading, child) {
            if (isPageLoading) return viewLoading();
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
                    ValueListenableBuilder(
                      valueListenable: errorNotifier,
                      builder: (context, errorMessage, child) {
                        if (errorMessage != null) {
                          return viewError(message: errorMessage);
                        }

                        return Align(
                          alignment: (isDisplayInfoPanel)
                              ? Alignment.topLeft
                              : Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (!isDisplayInfoPanel)
                                  ? max(bookmarksNoTimerMaxWidth,
                                      bookmarksMinWidth)
                                  : max(bookmarksMaxWidth, bookmarksMinWidth),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: viewBookmarks(),
                            ),
                          ),
                        );
                      },
                    ),
                    if (isDisplayInfoPanel)
                      Align(
                        alignment: Alignment.topRight,
                        child: viewInfoPanel(),
                      ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => showPageSettings(),
                        child: ButtonSettingsWidget(),
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

  Widget viewInfoPanel() {
    return IntervalRefresherWidget(
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
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ProgressBarWidget(
              title: 'Hour Progress',
              currentProgress: progressTimeHour,
              foregroundColor: Colors.blue,
            ),
          ),
          ValueListenableBuilder(
            valueListenable: workTimeNotifier,
            builder: (context, workTime, child) {
              if (workTime.start.isEmpty || workTime.finish.isEmpty) {
                return SizedBox.shrink();
              }

              return ProgressBarWidget(
                title: 'Work Progress',
                currentProgress: progressTimeWork,
                foregroundColor: Colors.yellow,
              );
            },
          ),
        ],
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

  Widget viewLoading() {
    return SizedBox.shrink();
  }
}
