part of 'helpers.dart';

class Logging {
  static void log(
    dynamic value, {
    StackTrace? stackTrace,
    String prefix = '',
    bool showStackTrace = false,
    bool showPrefix = true,
  }) {
    String log = value.toString();

    if (prefix.isNotEmpty && showPrefix) log = '[$prefix] $log';
    if (kDebugMode) print(log);

    if (stackTrace != null && showStackTrace) {
      if (kDebugMode) print('[STACKTRACE]');
      if (kDebugMode) print(stackTrace);
      if (kDebugMode) print('[STACKTRACE]');
    }
  }
}
