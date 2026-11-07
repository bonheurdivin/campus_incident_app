import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_app/models/app_user.dart';
import 'package:campus_incident_app/models/enums.dart';
import 'package:campus_incident_app/models/incident.dart';

void main() {
  group('Incident', () {
    test('toMap then fromMap keeps all the data', () {
      final now = DateTime(2026, 11, 7, 10, 30);
      final original = Incident(
        id: 'abc',
        title: 'Water shortage',
        description: 'No water in the residence since morning',
        location: 'Block A',
        reporterId: 'u1',
        reporterName: 'Amina',
        category: IncidentCategory.water,
        status: IncidentStatus.inProgress,
        imageUrl: 'https://example.com/photo.jpg',
        createdAt: now,
        updatedAt: now,
      );

      final copy = Incident.fromMap('abc', original.toMap());

      expect(copy.id, 'abc');
      expect(copy.title, original.title);
      expect(copy.description, original.description);
      expect(copy.location, original.location);
      expect(copy.reporterId, original.reporterId);
      expect(copy.reporterName, original.reporterName);
      expect(copy.category, IncidentCategory.water);
      expect(copy.status, IncidentStatus.inProgress);
      expect(copy.imageUrl, original.imageUrl);
      expect(copy.createdAt.isAtSameMomentAs(now), isTrue);
    });

    test('fromMap uses safe defaults for missing fields', () {
      final incident = Incident.fromMap('x', {});

      expect(incident.status, IncidentStatus.submitted);
      expect(incident.category, IncidentCategory.facilities);
      expect(incident.imageUrl, isNull);
      expect(incident.title, '');
    });
  });

  group('AppUser', () {
    test('role staff is recognised, and the default role is student', () {
      final staff = AppUser.fromMap('u1', {
        'name': 'Sam',
        'email': 'sam@alueducation.com',
        'role': 'staff',
      });
      final student = AppUser.fromMap('u2', {
        'name': 'Amina',
        'email': 'amina@alustudent.com',
      });

      expect(staff.isStaff, isTrue);
      expect(student.isStaff, isFalse);
      expect(student.role, UserRole.student);
    });
  });
}