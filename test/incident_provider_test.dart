import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_app/models/enums.dart';
import 'package:campus_incident_app/models/incident.dart';
import 'package:campus_incident_app/providers/incident_provider.dart';
import 'package:campus_incident_app/services/incident_service.dart';

// A stand-in service so the provider can be tested without Firebase.
class FakeIncidentService extends Fake implements IncidentService {}

Incident make(
  String id,
  String title,
  IncidentCategory category,
  IncidentStatus status, {
  String reporter = 'u1',
  String location = 'Block A',
}) {
  final now = DateTime(2026, 11, 7);
  return Incident(
    id: id,
    title: title,
    description: 'Description for $title',
    location: location,
    reporterId: reporter,
    reporterName: 'Someone',
    category: category,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late IncidentProvider provider;

  setUp(() {
    provider = IncidentProvider(FakeIncidentService());
    provider.all = [
      make('1', 'Water shortage', IncidentCategory.water,
          IncidentStatus.submitted),
      make('2', 'Broken projector', IncidentCategory.facilities,
          IncidentStatus.inProgress,
          reporter: 'u2', location: 'Block B'),
      make('3', 'Overflowing bin', IncidentCategory.sanitation,
          IncidentStatus.resolved,
          location: 'Cafeteria'),
      make('4', 'Power outage', IncidentCategory.electricity,
          IncidentStatus.submitted,
          reporter: 'u2'),
    ];
    addTearDown(provider.dispose);
  });

  test('with no filters every incident is returned', () {
    expect(provider.filtered.length, 4);
  });

  test('status filter keeps only that status', () {
    provider.setStatusFilter(IncidentStatus.submitted);
    expect(provider.filtered.map((i) => i.id), ['1', '4']);
  });

  test('category filter keeps only that category', () {
    provider.setCategoryFilter(IncidentCategory.sanitation);
    expect(provider.filtered.map((i) => i.id), ['3']);
  });

  test('search matches the title ignoring case', () {
    provider.setQuery('PROJECTOR');
    expect(provider.filtered.map((i) => i.id), ['2']);
  });

  test('search also matches the location', () {
    provider.setQuery('cafeteria');
    expect(provider.filtered.map((i) => i.id), ['3']);
  });

  test('status and category filters combine', () {
    provider.setStatusFilter(IncidentStatus.submitted);
    provider.setCategoryFilter(IncidentCategory.electricity);
    expect(provider.filtered.map((i) => i.id), ['4']);
  });

  test('mine returns only the reporter\'s own incidents', () {
    expect(provider.mine('u1').map((i) => i.id), ['1', '3']);
  });

  test('countByStatus counts correctly', () {
    expect(
        provider.countByStatus(provider.all, IncidentStatus.submitted), 2);
    expect(
        provider.countByStatus(provider.all, IncidentStatus.resolved), 1);
  });

  test('clearFilters resets search and filters', () {
    provider.setQuery('water');
    provider.setStatusFilter(IncidentStatus.submitted);
    provider.setCategoryFilter(IncidentCategory.water);

    provider.clearFilters();

    expect(provider.query, '');
    expect(provider.statusFilter, isNull);
    expect(provider.categoryFilter, isNull);
    expect(provider.filtered.length, 4);
  });
}