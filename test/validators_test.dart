import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_app/core/validators.dart';

void main() {
  group('validateAluEmail', () {
    test('rejects an empty email', () {
      expect(validateAluEmail(''), isNotNull);
    });

    test('rejects a non-ALU domain', () {
      expect(validateAluEmail('someone@gmail.com'), isNotNull);
    });

    test('accepts a student ALU address', () {
      expect(validateAluEmail('amina@alustudent.com'), isNull);
    });

    test('accepts a staff ALU address ignoring case and spaces', () {
      expect(validateAluEmail('  Staff@AluEducation.com '), isNull);
    });
  });

  group('validatePassword', () {
    test('rejects passwords shorter than 6 characters', () {
      expect(validatePassword('12345'), isNotNull);
    });

    test('accepts passwords of 6 or more characters', () {
      expect(validatePassword('123456'), isNull);
    });
  });
}