part of 'helpers.dart';

class RunAfterPause {
  final Duration delay;
  VoidCallback? action;
  Timer? _timer;

  RunAfterPause({required this.delay});

  run(VoidCallback action) {
    if (_timer != null) _timer!.cancel();
    _timer = Timer(delay, action);
  }
}
