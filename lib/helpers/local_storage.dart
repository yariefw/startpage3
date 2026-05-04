part of 'helpers.dart';

class LocalStorage {
  String keyConfigStartpage = 'config_startpage';
  String keyConfigStartpageKey = 'config_startpage_key';

  bool get isLocalConfigAvailable =>
      (html.window.localStorage[keyConfigStartpage] ?? '').isNotEmpty;

  String getKey() => html.window.localStorage[keyConfigStartpageKey] ?? '';

  void updateKey({
    required String key,
  }) =>
      html.window.localStorage[keyConfigStartpageKey] = key;

  String getConfigUndecrypted() =>
      html.window.localStorage[keyConfigStartpage] ?? '';

  Future<String> getConfig({
    String key = '',
  }) async {
    if (key.isEmpty) key = getKey();
    String encConfig = getConfigUndecrypted();

    String decConfig = await decryptConfig(encConfig: encConfig, key: key);
    return decConfig;
  }

  void updateConfig({
    required String encConfig,
  }) {
    try {
      Logging.log(
        'Update local config - start',
        prefix: 'LocalStorage.updateConfig',
      );

      String configExternal = encConfig;
      String configLocal = html.window.localStorage[keyConfigStartpage] ?? '';

      if (configExternal != configLocal) {
        // Cache to local storage
        html.window.localStorage[keyConfigStartpage] = configExternal;
      }

      Logging.log(
        'Update local config - success',
        prefix: 'LocalStorage.updateConfig',
      );
    } catch (e, stackTrace) {
      Logging.log(
        e,
        stackTrace: stackTrace,
        prefix: 'LocalStorage.updateConfig',
      );

      rethrow;
    }
  }

  Future<String> decryptConfig({
    required String encConfig,
    String key = '',
  }) async {
    String decConfig = encConfig;

    try {
      if (key.isNotEmpty) decConfig = await AesGcm.decrypt(encConfig, key: key);
    } catch (e, stackTrace) {
      Logging.log(
        e,
        stackTrace: stackTrace,
        prefix: 'LocalStorage.decryptConfig',
      );
    }

    return decConfig;
  }
}
