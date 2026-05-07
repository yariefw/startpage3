part of '../dashboard.dart';

mixin DashboardConfigurationMethods
    on BookmarksLoaderMethods, WallpaperLoaderMethods, WorkTimeLoaderMethods {
  final TextEditingController bookmarksController = TextEditingController();
  final TextEditingController bookmarksKeyController = TextEditingController();
  final ValueNotifier<bool> bookmarksKeySaveToLocal = ValueNotifier(false);
  final TextEditingController wallpaperUrlController = TextEditingController();
  final ValueNotifier<double> wallpaperOpacity = ValueNotifier(0.5);
  final TextEditingController workStartController = TextEditingController();
  final TextEditingController workFinishController = TextEditingController();

  DashboardConfigurationData get settings => DashboardConfigurationData(
        bookmarks: bookmarksController.text,
        bookmarksKey: bookmarksKeyController.text,
        bookmarksKeySaveToLocal: bookmarksKeySaveToLocal.value,
        wallpaperUrl: wallpaperUrlController.text,
        wallpaperOpacity: wallpaperOpacity.value,
        workStart: workStartController.text,
        workFinish: workFinishController.text,
      );

  Future<dynamic> showDialogSettings({
    required BuildContext context,
    bool isFirstLoad = false,
    DashboardConfigurationData? configuration,
    Function(DashboardConfigurationData configuration)? onConfirm,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DialogSimple(
        title: 'Settings',
        onConfirm: () {
          if (onConfirm != null) onConfirm(settings);
        },
        children: [
          SettingsWidget(
            isFirstLoad: isFirstLoad,
            configuration: configuration,
            bookmarksController: bookmarksController,
            bookmarksKeyController: bookmarksKeyController,
            bookmarksKeySaveToLocal: bookmarksKeySaveToLocal,
            wallpaperUrlController: wallpaperUrlController,
            wallpaperOpacity: wallpaperOpacity,
            workStartController: workStartController,
            workFinishController: workFinishController,
          ),
        ],
      ),
    );
  }

  DashboardConfigurationData getSavedConfiguration() {
    DashboardConfigurationData savedConfig = DashboardConfigurationData(
      bookmarks: '',
    );

    String savedBookmarks = storage.getBookmarksUndecrypted();

    if (savedBookmarks.isNotEmpty) {
      savedConfig.bookmarks = savedBookmarks;
    }

    String savedBookmarksKey = storage.getBookmarksKey();

    if (savedBookmarksKey.isNotEmpty) {
      savedConfig.bookmarksKey = savedBookmarksKey;
    }

    String savedWallpaper = storage.getWallpaperUrl();

    if (savedWallpaper.isNotEmpty) {
      savedConfig.wallpaperUrl = savedWallpaper;
    }

    String savedWallpaperOpacity = storage.getWallpaperOpacity();

    if (savedWallpaperOpacity.isNotEmpty) {
      savedConfig.wallpaperOpacity =
          double.tryParse(savedWallpaperOpacity) ?? 0.5;
    }

    String savedWorkStart = storage.getWorkStart();
    String savedWorkFinish = storage.getWorkFinish();

    if (savedWorkStart.isNotEmpty && savedWorkFinish.isNotEmpty) {
      savedConfig.workStart = savedWorkStart;
      savedConfig.workFinish = savedWorkFinish;
    }

    return savedConfig;
  }

  Future<void> applyConfiguration({
    required DashboardConfigurationData configuration,
    bool isFirstLoad = false,
  }) async {
    await Future.delayed(Duration(milliseconds: 100));

    await loadBookmarks(
      bookmarks: configuration.bookmarks,
      key: configuration.bookmarksKey ?? '',
      saveKey: configuration.bookmarksKeySaveToLocal ?? false,
    );

    applyWallpaper(
      wallpaperUrl: configuration.wallpaperUrl ?? '',
      wallpaperOpacity: configuration.wallpaperOpacity ?? 0.5,
    );

    applyWorkProgressTracker(
      workStart: configuration.workStart ?? '',
      workFinish: configuration.workFinish ?? '',
    );
  }
}
