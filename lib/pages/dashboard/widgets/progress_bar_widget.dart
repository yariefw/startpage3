part of '../dashboard.dart';

class ProgressBarWidget extends StatelessWidget {
  const ProgressBarWidget({
    super.key,
    this.title,
    this.currentProgress,
    this.barHeight,
    this.barWidth,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String? title;
  final double? currentProgress;
  final double? barHeight;
  final double? barWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (title?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              title ?? '',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade300,
              ),
            ),
          ),
        if (currentProgress != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: barHeight ?? 30,
              child: Stack(
                children: [
                  Container(
                    width: barWidth ?? 195,
                    color: backgroundColor ?? Colors.white,
                  ),
                  Container(
                    width: (currentProgress ?? 1) * (barWidth ?? 195),
                    color: foregroundColor ?? Colors.blue,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
