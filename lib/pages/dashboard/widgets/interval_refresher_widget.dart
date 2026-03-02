part of '../dashboard.dart';

class IntervalRefresherWidget extends StatefulWidget {
  const IntervalRefresherWidget({
    super.key,
    required this.interval,
    required this.child,
  });

  final Duration interval;
  final Widget child;

  @override
  State<IntervalRefresherWidget> createState() =>
      _IntervalRefresherWidgetState();
}

class _IntervalRefresherWidgetState extends State<IntervalRefresherWidget> {
  ValueNotifier<int> notifier = ValueNotifier(0);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      widget.interval,
      (timer) => notifier.value++,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, value, child) {
        return KeyedSubtree(
          key: ValueKey(value),
          child: widget.child,
        );
      },
    );
  }
}
