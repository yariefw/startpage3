part of 'helpers.dart';

extension StringExtension on String {
  double toDouble({double? orElse}) => double.tryParse(this) ?? orElse ?? 0;

  int toInt({int? orElse}) => int.tryParse(this) ?? orElse ?? 0;

  String enforceMaxLength({required int limit}) {
    if (length > limit) return substring(0, limit);
    return this;
  }

  String stripTrailingPointZero() {
    return replaceAll(RegExp(r'\.0$'), '');
  }
}
