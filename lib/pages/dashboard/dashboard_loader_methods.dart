part of 'dashboard.dart';

mixin DashboardLoaderMethods on DashboardMethods {
  ValueNotifier<List<MenuItem>> fullBookmarksNotifier = ValueNotifier([]);

  ValueNotifier<({String uri, double? opacity})> wallpaperNotifier =
      ValueNotifier((uri: '', opacity: null));

  ValueNotifier<({String start, String finish})> workTimeNotifier =
      ValueNotifier((start: '', finish: ''));

  Future<String> loadStringFromAsset(String key) => rootBundle.loadString(key);

  Future<String> getConfigFromOnline(String url) async {
    try {
      final String response = await http.read(Uri.parse(url));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getConfigFromLocal() async {
    try {
      String config = 'config';

      bool isHasConfig = html.window.localStorage.containsKey(config);

      if (!isHasConfig) {
        String template = await loadStringFromAsset(
          'assets/json/config_sample.json',
        );

        // Cache to local storage
        html.window.localStorage[config] = template;
      }

      return html.window.localStorage[config] ?? '';
    } catch (e) {
      rethrow;
    }
  }

  String? getUriParameter(String key) {
    Map<String, String> params = Uri.base.queryParameters;
    if (params.containsKey(key)) return params[key];
    return null;
  }

  List<MenuItem> parseBookmarks(Map<String, dynamic> data) {
    List<MenuItem> jsonMenu = [];

    for (Map<String, dynamic> item in data['bookmarks'] ?? []) {
      MenuItem menuItem = MenuItem.fromJson(item);
      jsonMenu.add(menuItem);
    }

    return jsonMenu;
  }

  Future<void> loadConfig() async {
    try {
      String config = '';

      // ----- Check if external config is provided -----

      String configUrl = getUriParameter('config') ?? '';

      if (configUrl.isNotEmpty) {
        config = await getConfigFromOnline(configUrl);
      } else {
        config = await getConfigFromLocal();
      }

      // ----- If config is encrypted, decode it using key from param -----

      String key = getUriParameter('key') ?? '';
      if (key.isNotEmpty) config = await AesGcm.decrypt(config, key: key);

      // ----- Parse config string into map -----

      Map<String, dynamic> data = jsonDecode(config);

      // ----- Fill runtime vars based on config -----

      fullBookmarksNotifier.value = parseBookmarks(data);
      wallpaperNotifier.value = (
        uri: data['wallpaper'] ?? '',
        opacity: double.tryParse(data['wallpaper_opacity'] ?? ''),
      );

      workTimeNotifier.value = (
        start: data['work_start'] ?? '',
        finish: data['work_finish'] ?? '',
      );

      // ----- Allow override from uri params -----

      wallpaperNotifier.value = (
        uri: getUriParameter('wallpaper') ?? wallpaperNotifier.value.uri,
        opacity: double.tryParse(
              (getUriParameter('wallpaper_opacity') ?? ''),
            ) ??
            wallpaperNotifier.value.opacity,
      );

      // ----- Set displayed bookmarks -----

      displayedBookmarksNotifier.value = fullBookmarksNotifier.value;
    } catch (e) {
      rethrow;
    }
  }
}
