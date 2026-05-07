part of '../dashboard.dart';

mixin BookmarksLoaderMethods on DashboardMethods, DashboardParamMethods {
  bool get isSavedBookmarksAvailable => storage.isSavedBookmarksAvailable;

  Future<void> loadBookmarks({
    required String bookmarks,
    required String key,
    bool saveKey = false,
  }) async {
    if (bookmarks.isEmpty) return;

    try {
      errorNotifier.value = null;
      pageLoadingNotifier.value = true;

      if (bookmarks.startsWith('http')) {
        bookmarks = await http.read(Uri.parse(bookmarks));
      }

      String decrypted = await decryptBookmarks(encrypted: bookmarks, key: key);

      Map<String, dynamic> decodedBookmarks = decodeBookmarks(
        bookmarks: decrypted,
      );

      // Save to local

      storage.updateBookmarks(bookmarks: bookmarks);
      if (saveKey) storage.updateBookmarksKey(key: key);

      fullBookmarksNotifier.value = parseBookmarks(decodedBookmarks);
      displayedBookmarksNotifier.value = fullBookmarksNotifier.value;

      pageLoadingNotifier.value = false;
    } catch (e, stackTrace) {
      Logging.log(
        e,
        stackTrace: stackTrace,
        prefix: 'DashboardLoaderMethods.loadBookmarks',
      );

      displayError(errorMessage: e.toString());
    }
  }

  Future<String> decryptBookmarks({
    required String encrypted,
    String key = '',
  }) async =>
      storage.decryptBookmarks(encrypted: encrypted, key: key);

  Map<String, dynamic> decodeBookmarks({
    required String bookmarks,
  }) {
    try {
      Map<String, dynamic> decoded = jsonDecode(bookmarks);
      return decoded;
    } catch (e, stackTrace) {
      Logging.log(
        e,
        stackTrace: stackTrace,
        prefix: 'DashboardLoaderMethods.decodeBookmarks',
      );

      rethrow;
    }
  }

  List<MenuItem> parseBookmarks(Map<String, dynamic> data) {
    List<MenuItem> jsonMenu = [];

    for (Map<String, dynamic> item in data['bookmarks'] ?? []) {
      MenuItem menuItem = MenuItem.fromJson(item);
      jsonMenu.add(menuItem);
    }

    return jsonMenu;
  }

  void displayError({
    required String errorMessage,
  }) {
    if (errorMessage.contains('failedDecrypt')) {
      errorMessage =
          'Error: Failed when loading config.\nPlease ensure json is valid and decryption key is correct.';
    }

    errorNotifier.value =
        (errorMessage.contains('Error: ')) ? errorMessage : '';

    pageLoadingNotifier.value = false;
  }
}

mixin WallpaperLoaderMethods on DashboardMethods, DashboardParamMethods {
  void applyWallpaper({
    required String wallpaperUrl,
    double wallpaperOpacity = 0.5,
  }) {
    // Save to local

    if (wallpaperUrl.isNotEmpty) {
      storage.updateWallpaperUrl(url: wallpaperUrl);
    }

    if (wallpaperOpacity > 0) {
      storage.updateWallpaperOpacity(opacity: wallpaperOpacity.toString());
    }

    // Load Wallpaper

    wallpaperNotifier.value = (
      uri: (wallpaperUrl.isNotEmpty)
          ? wallpaperUrl
          : wallpaperNotifier.value.uri,
      opacity: wallpaperOpacity,
    );
  }
}

mixin WorkTimeLoaderMethods on DashboardMethods, DashboardParamMethods {
  void applyWorkProgressTracker({
    required String workStart,
    required String workFinish,
  }) {
    // Early return

    if (workStart.isEmpty || workFinish.isEmpty) return;

    // Save to local

    storage.updateWorkStart(workStart: workStart);
    storage.updateWorkFinish(workFinish: workFinish);

    // Load progress tracker

    workTimeNotifier.value = (start: workStart, finish: workFinish);
  }
}
