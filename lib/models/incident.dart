import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class Incident {
  final String id, title, description, location, reporterId, reporterName;
  final IncidentCategory category;
  final IncidentStatus status;
  final String? imageUrl;
  final DateTime createdAt, updatedAt;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.reporterId,
    required this.reporterName,
    required this.category,
    required this.status,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Incident.fromMap(String id, Map<String, dynamic> m) => Incident(
        id: id,
        title: m['title'] ?? '',
        description: m['description'] ?? '',
        location: m['location'] ?? '',
        reporterId: m['reporterId'] ?? '',
        reporterName: m['reporterName'] ?? '',
        category: IncidentCategory.values.byName(m['category'] ?? 'facilities'),
        status: IncidentStatus.values.byName(m['status'] ?? 'submitted'),
        imageUrl: m['imageUrl'],
        createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (m['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'location': location,
        'reporterId': reporterId,
        'reporterName': reporterName,
        'category': category.name,
        'status': status.name,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}