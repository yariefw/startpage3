class DashboardConfigurationData {
  String bookmarks;
  String? bookmarksKey;
  bool? bookmarksKeySaveToLocal;
  String? wallpaperUrl;
  double? wallpaperOpacity;
  String? workStart;
  String? workFinish;

  DashboardConfigurationData({
    required this.bookmarks,
    this.bookmarksKey,
    this.bookmarksKeySaveToLocal,
    this.wallpaperUrl,
    this.wallpaperOpacity,
    this.workStart,
    this.workFinish,
  });
}
