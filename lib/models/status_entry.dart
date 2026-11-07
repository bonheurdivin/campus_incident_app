import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class StatusEntry {
  final IncidentStatus status;
  final String changedBy, note;
  final DateTime timestamp;

  const StatusEntry({
    required this.status,
    required this.changedBy,
    required this.note,
    required this.timestamp,
  });

  factory StatusEntry.fromMap(Map<String, dynamic> m) => StatusEntry(
        status: IncidentStatus.values.byName(m['status'] ?? 'submitted'),
        changedBy: m['changedBy'] ?? '',
        note: m['note'] ?? '',
        timestamp: (m['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}