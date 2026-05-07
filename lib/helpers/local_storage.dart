part of 'helpers.dart';

class LocalStorage {
  String cBookmarks = 'config_startpage';
  String cBookmarksKey = 'config_startpage_key';
  String cWorkStart = 'config_startpage_time_work_start';
  String cWorkFinish = 'config_startpage_time_work_finish';
  String cWallpaper = 'config_startpage_wallpaper';
  String cWallpaperOpacity = 'config_startpage_wallpaper_opacity';

  bool get isSavedBookmarksAvailable =>
      (html.window.localStorage[cBookmarks] ?? '').isNotEmpty;

  String getBookmarksKey() => html.window.localStorage[cBookmarksKey] ?? '';

  void updateBookmarksKey({required String key}) =>
      html.window.localStorage[cBookmarksKey] = key;

  String getBookmarksUndecrypted() =>
      html.window.localStorage[cBookmarks] ?? '';

  Future<String> getBookmarksDecrypted({String key = ''}) async {
    if (key.isEmpty) key = getBookmarksKey();
    String encrypted = getBookmarksUndecrypted();
    String decrypted = await decryptBookmarks(encrypted: encrypted, key: key);
    return decrypted;
  }

  void updateBookmarks({required String bookmarks}) {
    try {
      Logging.log(
        'Update local config - start',
        prefix: 'LocalStorage.updateBookmarks',
      );

      String bookmarksNew = bookmarks;
      String bookmarksSaved = html.window.localStorage[cBookmarks] ?? '';

      if (bookmarksNew != bookmarksSaved) {
        // Cache to local storage
        html.window.localStorage[cBookmarks] = bookmarksNew;
      }

      Logging.log(
        'Update local config - success',
        prefix: 'LocalStorage.updateBookmarks',
      );
    } catch (e, stackTrace) {
      Logging.log(
        e,
        stackTrace: stackTrace,
        prefix: 'LocalStorage.updateBookmarks',
      );

      rethrow;
    }
  }

  String getWallpaperUrl() => html.window.localStorage[cWallpaper] ?? '';

  void updateWallpaperUrl({required String url}) =>
      html.window.localStorage[cWallpaper] = url;

  String getWallpaperOpacity() =>
      html.window.localStorage[cWallpaperOpacity] ?? '';

  void updateWallpaperOpacity({required String opacity}) =>
      html.window.localStorage[cWallpaperOpacity] = opacity;

  String getWorkStart() => html.window.localStorage[cWorkStart] ?? '';

  void updateWorkStart({required String workStart}) =>
      html.window.localStorage[cWorkStart] = workStart;

  String getWorkFinish() => html.window.localStorage[cWorkFinish] ?? '';

  void updateWorkFinish({required String workFinish}) =>
      html.window.localStorage[cWorkFinish] = workFinish;

  Future<String> decryptBookmarks({
    required String encrypted,
    String key = '',
  }) async {
    String decrypted = encrypted;

    try {
      if (key.isNotEmpty) decrypted = await AesGcm.decrypt(encrypted, key: key);
    } catch (e, stackTrace) {
      Logging.log(
        e,
        stackTrace: stackTrace,
        prefix: 'LocalStorage.decryptBookmarks',
      );
    }

    return decrypted;
  }
}
