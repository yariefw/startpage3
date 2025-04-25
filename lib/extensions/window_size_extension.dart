import 'package:flutter/material.dart';

// https://m3.material.io/foundations/layout/applying-layout/window-size-classes#9e94b1fb-e842-423f-9713-099b40f13922
enum WindowSize {
  compact,
  medium,
  expanded,
  large,
  extraLarge,
}

extension WindowSizingExtension on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;

  WindowSize get windowSize => (screenWidth >= 1600)
      ? WindowSize.extraLarge
      : (screenWidth < 1600 && screenWidth >= 1200)
          ? WindowSize.large
          : (screenWidth < 1200 && screenWidth >= 840)
              ? WindowSize.expanded
              : (screenWidth < 840 && screenWidth >= 600)
                  ? WindowSize.medium
                  : WindowSize.compact;
}
