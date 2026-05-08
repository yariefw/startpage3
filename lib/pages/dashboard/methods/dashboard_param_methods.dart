part of '../dashboard.dart';

mixin DashboardParamMethods on DashboardMethods {
  String get pBookmarksKey => getUriParameter('bookmarks_key') ?? '';
  String get pBookmarksUrl => getUriParameter('bookmarks_url') ?? '';
  String get pBookmarksDirect => getUriParameter('bookmarks_json') ?? '';
  String get pWallpaperUrl => getUriParameter('wallpaper_url') ?? '';
  String get pWallpaperOpacity => getUriParameter('wallpaper_opacity') ?? '';
  String get pWorkStart => getUriParameter('work_start') ?? '';
  String get pWorkFinish => getUriParameter('work_finish') ?? '';

  DashboardConfigurationData getConfiguration({String? envConfig}) {
    DashboardConfigurationData savedConfig = _getSavedConfiguration();

    savedConfig.bookmarks = (envConfig?.isNotEmpty ?? false)
        ? envConfig ?? ''
        : (pBookmarksDirect.isNotEmpty)
            ? pBookmarksDirect
            : (pBookmarksUrl.isNotEmpty)
                ? pBookmarksUrl
                : savedConfig.bookmarks;

    savedConfig.bookmarksKey =
        (pBookmarksKey.isNotEmpty) ? pBookmarksKey : savedConfig.bookmarksKey;

    savedConfig.wallpaperUrl =
        (pWallpaperUrl.isNotEmpty) ? pWallpaperUrl : savedConfig.wallpaperUrl;

    savedConfig.wallpaperOpacity = (pWallpaperOpacity.isNotEmpty)
        ? pWallpaperOpacity.toDouble(orElse: 0.5)
        : savedConfig.wallpaperOpacity;

    savedConfig.workStart =
        (pWorkStart.isNotEmpty) ? pWorkStart : savedConfig.workStart;

    savedConfig.workFinish =
        (pWorkFinish.isNotEmpty) ? pWorkFinish : savedConfig.workFinish;

    return savedConfig;
  }

  DashboardConfigurationData _getSavedConfiguration() {
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

  String? getUriParameter(String key) {
    Map<String, String> params = Uri.base.queryParameters;
    if (params.containsKey(key)) return params[key];
    return null;
  }
}
