import 'package:flutter_test/flutter_test.dart';
import 'package:neon_wave/src/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty input', () {
      expect(Validators.email(''), isNotNull);
    });

    test('rejects a malformed address', () {
      expect(Validators.email('not-an-email'), isNotNull);
    });

    test('accepts a well-formed address', () {
      expect(Validators.email('person@example.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects passwords shorter than 6 characters', () {
      expect(Validators.password('abc12'), isNotNull);
    });

    test('accepts a 6+ character password', () {
      expect(Validators.password('abc123'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('rejects a mismatch', () {
      expect(Validators.confirmPassword('abc123', 'xyz789'), isNotNull);
    });

    test('accepts a match', () {
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    });
  });
}
