part of '../dashboard.dart';

class ShortcutIconWidget extends StatelessWidget {
  const ShortcutIconWidget({
    super.key,
    required this.url,
    this.label,
    this.icon,
  });

  final String url;
  final String? label;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (icon != null) icon ?? SizedBox.shrink(),
        if (label?.isNotEmpty ?? false)
          Text(
            label ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}
