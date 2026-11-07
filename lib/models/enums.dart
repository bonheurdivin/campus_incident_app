import 'package:flutter/material.dart';

enum UserRole { student, staff }

enum IncidentStatus { submitted, inProgress, resolved }

enum IncidentCategory { facilities, water, electricity, safety, sanitation }

extension StatusInfo on IncidentStatus {
  String get label => switch (this) {
        IncidentStatus.submitted => 'Submitted',
        IncidentStatus.inProgress => 'In Progress',
        IncidentStatus.resolved => 'Resolved',
      };

  Color get color => switch (this) {
        IncidentStatus.submitted => Colors.orange,
        IncidentStatus.inProgress => Colors.indigo,
        IncidentStatus.resolved => Colors.green,
      };
}

extension CategoryInfo on IncidentCategory {
  String get label => switch (this) {
        IncidentCategory.facilities => 'Facilities',
        IncidentCategory.water => 'Water',
        IncidentCategory.electricity => 'Electricity',
        IncidentCategory.safety => 'Safety',
        IncidentCategory.sanitation => 'Sanitation',
      };

  IconData get icon => switch (this) {
        IncidentCategory.facilities => Icons.apartment_rounded,
        IncidentCategory.water => Icons.water_drop_outlined,
        IncidentCategory.electricity => Icons.bolt_outlined,
        IncidentCategory.safety => Icons.shield_outlined,
        IncidentCategory.sanitation => Icons.delete_outline,
      };
}