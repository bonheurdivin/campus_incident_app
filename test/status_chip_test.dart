import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_incident_app/models/enums.dart';
import 'package:campus_incident_app/widgets/status_chip.dart';

void main() {
  testWidgets('StatusChip shows the right label for every status',
      (tester) async {
    for (final status in IncidentStatus.values) {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatusChip(status: status))),
      );
      expect(find.text(status.label), findsOneWidget);
    }
  });
}