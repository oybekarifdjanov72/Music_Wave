import 'dart:math';

/// Shuffles a list deterministically for "today" — same order all day for
/// every user session, different tomorrow. Powers the Home screen's
/// "Best For Today" section without needing a dedicated backend endpoint.
List<T> shuffleForToday<T>(List<T> items) {
  if (items.length < 2) return List<T>.from(items);
  final now = DateTime.now();
  final seed = now.year * 10000 + now.month * 100 + now.day;
  final random = Random(seed);
  final copy = List<T>.from(items);
  copy.shuffle(random);
  return copy;
}
