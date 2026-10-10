/// Generates short, locally-unique ids (playlists, etc.) without pulling
/// in an extra package — timestamp + an in-memory counter is enough since
/// everything here is stored on-device only.
class IdGenerator {
  IdGenerator._();

  static int _counter = 0;

  static String next(String prefix) {
    _counter++;
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_$_counter';
  }
}
