import 'dart:async';

/// Delays calling [run] until no new call has come in for [delay] — used
/// by the search bar so we don't fire a network request on every
/// keystroke ("smart" typing behaviour).
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() => _timer?.cancel();
}
