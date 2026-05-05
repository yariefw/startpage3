part of 'dashboard.dart';

class DashboardPageArgs {
  String? config;
  DashboardPageArgs({this.config});
}

class DashboardPage extends StatefulWidget {
  static String route = '/startpage';

  const DashboardPage({super.key, required this.args});
  final DashboardPageArgs args;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with DashboardMethods, DashboardLoaderMethods {
  DashboardPageArgs get args => widget.args;

  String get paramConfig => (args.config != null && args.config!.isNotEmpty)
      ? args.config!
      : (paramConfigDirect.isNotEmpty)
          ? paramConfigDirect
          : paramConfigUrl;

  RunAfterPause delayed = RunAfterPause(
    delay: Duration(milliseconds: 300),
  );

  final TextEditingController _configController = TextEditingController();
  final TextEditingController _configKeyController = TextEditingController();
  final TextEditingController _configWallpaperController =
      TextEditingController();

  double get bookmarksMinWidth => 325;
  double get bookmarksMaxWidth => context.screenWidth * 0.18;
  double get bookmarksNoTimerMaxWidth => context.screenWidth * 0.65;

  double get timerMinWidth => 650;

  bool get isDisplayRightPanel => context.screenWidth > timerMinWidth;

  Future<void> showDialogEditConfig({
    bool isFirstLoad = false,
    bool allowEditSource = true,
  }) async {
    // For auto decrypting purposes, currently saved permanently
    bool saveKey = false;

    // Get config and key from param
    _configController.text = paramConfig;
    _configKeyController.text = paramConfigKey;

    if (!isFirstLoad) {
      // Use config and key from local

      String encConfig = storage.getConfigUndecrypted();
      if (encConfig.isNotEmpty) _configController.text = encConfig;

      String encKey = storage.getKey();
      if (encKey.isNotEmpty) {
        _configKeyController.text = encKey;
        saveKey = true;
      }
    }

    // Local Overrides
    double localWallpaperOpacity = 0.5;

    if (!isFirstLoad) {
      String localWallpaper = storage.getWallpaper();

      if (localWallpaper.isNotEmpty) {
        _configWallpaperController.text = localWallpaper;

        localWallpaperOpacity =
            double.tryParse(storage.getWallpaperOpacity()) ?? 0.5;
      }
    }

    // Disable source edit if using direct config
    if (paramConfigDirect.isNotEmpty) allowEditSource = false;

    // Show edit config dialog
    dialogEditConfig(
      keyController: _configKeyController,
      configController: (allowEditSource) ? _configController : null,
      saveKeyInitial: saveKey,
      onSaveKeyChanged: (isCheck) => saveKey = isCheck,
      wallpaperUrlController:
          (!isFirstLoad) ? _configWallpaperController : null,
      wallpaperOpacityInitial: localWallpaperOpacity,
      onWallpaperOpacityChanged: (newValue) => localWallpaperOpacity = newValue,
      onConfirm: () async {
        await Future.delayed(Duration(milliseconds: 100));

        await processConfig(
          config: _configController.text,
          key: _configKeyController.text,
          saveKey: saveKey,
        ).then(
          (value) {
            if (isFirstLoad) {
              overrideUriConfig();
              overrideLocalConfig();
            }
          },
        );

        if (!isFirstLoad) {
          overrideUriConfig();

          processConfigOverrideLocal(
            wallpaperUrl: _configWallpaperController.text,
            wallpaperOpacity: localWallpaperOpacity,
          );
        }

        _configKeyController.clear();
        _configController.clear();
      },
      onCancel: (isFirstLoad) ? () => processConfigLocal() : null,
    );
  }

  Future<void> processConfig({
    required String config,
    required String key,
    bool saveKey = false,
  }) async {
    if (config.startsWith('http')) {
      await processConfigUrl(
        key: key,
        configUrl: config,
        saveKey: saveKey,
      );
    } else if (config.isNotEmpty) {
      await processConfigDirect(
        key: key,
        config: config,
        saveKey: saveKey,
      );
    } else {
      loadPageError(errorMessage: 'Error: Config not provided');
    }
  }

  void processConfigOverrideLocal({
    required String wallpaperUrl,
    double wallpaperOpacity = 0.5,
  }) {
    processConfigWallpaper(
      wallpaperUrl: wallpaperUrl,
      wallpaperOpacity: wallpaperOpacity,
    );
  }

  void processConfigWallpaper({
    required String wallpaperUrl,
    double wallpaperOpacity = 0.5,
  }) {
    updateLocalWallpaper(
      wallpaperUrl: wallpaperUrl,
      wallpaperOpacity: wallpaperOpacity,
    );

    overrideLocalWallpaper();
  }

  @override
  void initState() {
    super.initState();

    // html.window.localStorage['config_startpage'] = '';
    // html.window.localStorage['config_startpage_key'] = '';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (paramConfig.isNotEmpty && paramConfigKey.isNotEmpty) {
        // Params with key, ignore local
        processConfig(config: paramConfig, key: paramConfigKey).then(
          (value) {
            overrideUriConfig();
            overrideLocalConfig();
          },
        );
      } else if (paramConfig.isNotEmpty) {
        // Params without key, ask for key
        showDialogEditConfig(isFirstLoad: true);
      } else if (isLocalConfigAvailable) {
        // No params, use local
        processConfigLocal().then(
          (value) {
            overrideUriConfig();
            overrideLocalConfig();
          },
        );
      } else {
        // Nothing provided, ask user for config
        showDialogEditConfig(isFirstLoad: true);
      }
    });
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

            return ValueListenableBuilder(
              valueListenable: errorNotifier,
              builder: (context, errorMessage, child) {
                if (errorMessage != null) {
                  return viewError(message: errorMessage);
                }

                return viewDashboard();
              },
            );
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
                    Align(
                      alignment: Alignment.bottomRight,
                      child: buttonConfig(),
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
    return Stack(
      children: [
        Center(
          child: Text(
            (message.isNotEmpty) ? message : 'An unexpected error occurred.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade300,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: buttonConfig(),
          ),
        ),
      ],
    );
  }

  Widget viewLoading() {
    return SizedBox.shrink();
  }

  Widget buttonConfig() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showDialogEditConfig(isFirstLoad: false),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            Icons.settings,
            color: Colors.grey,
            size: 16,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Text(
              'Config',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> dialogEditConfig({
    required TextEditingController keyController,
    TextEditingController? configController,
    bool saveKeyInitial = false,
    Function(bool isCheck)? onSaveKeyChanged,
    TextEditingController? wallpaperUrlController,
    double wallpaperOpacityInitial = 0.5,
    Function(double newValue)? onWallpaperOpacityChanged,
    Function? onConfirm,
    Function? onCancel,
  }) {
    return displayPopup(
      context: context,
      barrierDismissible: false,
      type: DisplayPopupType.dialog,
      title: 'Settings',
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (wallpaperUrlController != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Bookmarks',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    left: (wallpaperUrlController != null) ? 20 : 0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (configController != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: InputTextWidget(
                            controller: configController,
                            labelText: 'Config',
                          ),
                        ),
                      InputTextWidget(
                        controller: keyController,
                        obscureText: true,
                        labelText: 'Encryption Key',
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: InputCheckboxWidget(
                          labelText: 'Save Key',
                          initialValue: saveKeyInitial,
                          onChanged: (isCheck) {
                            if (onSaveKeyChanged != null) {
                              onSaveKeyChanged(isCheck);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (wallpaperUrlController != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        'Wallpaper',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InputTextWidget(
                            controller: wallpaperUrlController,
                            labelText: 'Wallpaper Url',
                          ),
                          if (onWallpaperOpacityChanged != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: InputSliderWidget(
                                labelText: 'Wallpaper Opacity',
                                reversed: true,
                                initialValue: wallpaperOpacityInitial,
                                onChanged: (newValue) =>
                                    onWallpaperOpacityChanged(newValue),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }
}
