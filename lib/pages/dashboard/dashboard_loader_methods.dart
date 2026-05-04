part of 'dashboard.dart';

mixin DashboardLoaderMethods on DashboardMethods {
  LocalStorage storage = LocalStorage();

  ValueNotifier<bool> pageLoadingNotifier = ValueNotifier(true);

  ValueNotifier<String?> errorNotifier = ValueNotifier(null);

  ValueNotifier<List<MenuItem>> fullBookmarksNotifier = ValueNotifier([]);

  ValueNotifier<({String uri, double? opacity})> wallpaperNotifier =
      ValueNotifier((uri: '', opacity: null));

  ValueNotifier<({String start, String finish})> workTimeNotifier =
      ValueNotifier((start: '', finish: ''));

  bool get isLocalConfigAvailable => storage.isLocalConfigAvailable;

  String get paramConfigKey => getUriParameter('key') ?? '';
  String get paramConfigUrl => getUriParameter('config') ?? '';
  String get paramConfigDirect => getUriParameter('config_startpage') ?? '';

  Future<void> processConfigDirect({
    required String config,
    required String key,
    bool saveKey = false,
  }) async {
    try {
      Logging.log(
        'Using config from direct uri param',
        prefix: 'DashboardLoaderMethods.processConfigDirect',
      );

      String decConfig = await decryptConfig(encConfig: config, key: key);

      Map<String, dynamic> decodedConfig = await decodeConfig(
        config: decConfig,
      );

      storage.updateConfig(encConfig: config);
      if (saveKey) storage.updateKey(key: key);

      loadPage(decodedConfig: decodedConfig);
    } catch (e, stackTrace) {
      Logging.log(
        e,
        stackTrace: stackTrace,
        prefix: 'DashboardLoaderMethods.processConfigDirect',
      );

      processConfigLocal(key: key);
    }
  }

  Future<void> processConfigUrl({
    required String configUrl,
    required String key,
    bool saveKey = false,
  }) async {
    try {
      Logging.log(
        'Using config from url of uri param',
        prefix: 'DashboardLoaderMethods.processConfigUrl',
      );

      String config = await http.read(Uri.parse(configUrl));

      String decConfig = await decryptConfig(encConfig: config, key: key);

      Map<String, dynamic> decodedConfig = await decodeConfig(
        config: decConfig,
      );

      storage.updateConfig(encConfig: config);
      if (saveKey) storage.updateKey(key: key);

      loadPage(decodedConfig: decodedConfig);
    } catch (e, stackTrace) {
      Logging.log(
        e,
        stackTrace: stackTrace,
        prefix: 'DashboardLoaderMethods.processConfigUrl',
      );

      processConfigLocal(key: key);
    }
  }

  Future<void> processConfigLocal({
    String config = '',
    String key = '',
    bool saveKey = false,
  }) async {
    try {
      Logging.log(
        'Using config from local storage',
        prefix: 'DashboardLoaderMethods.processConfigLocal',
      );

      String decConfig;

      if (config.isEmpty) {
        decConfig = await storage.getConfig(key: key);
      } else {
        decConfig = await decryptConfig(encConfig: config, key: key);
      }

      Map<String, dynamic> decodedConfig = await decodeConfig(
        config: decConfig,
      );

      if (config.isNotEmpty) {
        storage.updateConfig(encConfig: config);
        if (saveKey) storage.updateKey(key: key);
      }

      loadPage(decodedConfig: decodedConfig);
    } catch (e, stackTrace) {
      Logging.log(
        e,
        stackTrace: stackTrace,
        prefix: 'DashboardLoaderMethods.processConfigLocal',
      );

      loadPageError(errorMessage: e.toString());
    }
  }

  void loadPage({
    Map<String, dynamic> decodedConfig = const {},
  }) {
    try {
      errorNotifier.value = null;
      pageLoadingNotifier.value = true;

      // ----- Fill runtime vars based on config -----

      fullBookmarksNotifier.value = parseBookmarks(decodedConfig);

      wallpaperNotifier.value = (
        uri: decodedConfig['wallpaper'] ?? '',
        opacity: double.tryParse(decodedConfig['wallpaper_opacity'] ?? ''),
      );

      workTimeNotifier.value = (
        start: decodedConfig['work_start'] ?? '',
        finish: decodedConfig['work_finish'] ?? '',
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

      pageLoadingNotifier.value = false;
    } catch (e, stackTrace) {
      Logging.log(
        e,
        stackTrace: stackTrace,
        prefix: 'DashboardLoaderMethods.loadPage',
      );

      loadPageError(errorMessage: e.toString());
    }
  }

  void loadPageError({
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

  Future<String> decryptConfig({
    required String encConfig,
    String key = '',
  }) async =>
      storage.decryptConfig(encConfig: encConfig, key: key);

  Future<Map<String, dynamic>> decodeConfig({
    required String config,
  }) async {
    try {
      // ----- Parse config string into map -----

      Map<String, dynamic> decodedConfig = jsonDecode(config);

      return decodedConfig;
    } catch (e, stackTrace) {
      Logging.log(
        e,
        stackTrace: stackTrace,
        prefix: 'DashboardLoaderMethods.decodeConfig',
      );

      throw 'failedDecrypt';
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

  String? getUriParameter(String key) {
    Map<String, String> params = Uri.base.queryParameters;
    if (params.containsKey(key)) return params[key];
    return null;
  }
}
