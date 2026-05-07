part of '../dashboard.dart';

mixin DashboardParamMethods {
  String get pBookmarksKey => getUriParameter('bookmarks_key') ?? '';
  String get pBookmarksUrl => getUriParameter('bookmarks_url') ?? '';
  String get pBookmarksDirect => getUriParameter('bookmarks_json') ?? '';
  String get pWallpaperUrl => getUriParameter('wallpaper_url') ?? '';
  String get pWallpaperOpacity => getUriParameter('wallpaper_opacity') ?? '';
  String get pWorkStart => getUriParameter('work_start') ?? '';
  String get pWorkFinish => getUriParameter('work_finish') ?? '';

  String? getUriParameter(String key) {
    Map<String, String> params = Uri.base.queryParameters;
    if (params.containsKey(key)) return params[key];
    return null;
  }
}
