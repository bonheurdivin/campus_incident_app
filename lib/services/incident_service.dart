import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/enums.dart';
import '../models/incident.dart';
import '../models/status_entry.dart';

class IncidentService {
  final _col = FirebaseFirestore.instance.collection('incidents');

  /// READ: live list of all incidents, newest first.
  Stream<List<Incident>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Incident.fromMap(d.id, d.data())).toList());

    /// READ: live status history for one incident (powers the timeline).
  Stream<List<StatusEntry>> watchHistory(String id) => _col
      .doc(id)
      .collection('statusHistory')
      .orderBy('timestamp')
      .snapshots()
      .map((s) => s.docs.map((d) => StatusEntry.fromMap(d.data())).toList());

  /// CREATE: the incident plus its first status-history entry.
  Future<void> create(Incident incident) async {
    final ref = _col.doc();
    final batch = FirebaseFirestore.instance.batch();
    batch.set(ref, incident.toMap());
    batch.set(ref.collection('statusHistory').doc(), {
      'status': IncidentStatus.submitted.name,
      'changedBy': incident.reporterName,
      'note': 'Report submitted',
      'timestamp': Timestamp.now(),
    });
    await batch.commit();
  }

  /// UPDATE: staff changes the status and leaves a history entry.
  Future<void> updateStatus(
    String id,
    IncidentStatus status,
    String staffName, {
    String? note,
  }) async {
    final ref = _col.doc(id);
    final batch = FirebaseFirestore.instance.batch();
    batch.update(ref, {
      'status': status.name,
      'updatedAt': Timestamp.now(),
    });
    batch.set(ref.collection('statusHistory').doc(), {
      'status': status.name,
      'changedBy': staffName,
      'note': note ?? '',
      'timestamp': Timestamp.now(),
    });
    await batch.commit();
  }

  /// UPDATE: reporter edits their own report's details.
  Future<void> updateDetails(
    String id, {
    required String title,
    required String description,
    required String location,
    required IncidentCategory category,
  }) =>
      _col.doc(id).update({
        'title': title,
        'description': description,
        'location': location,
        'category': category.name,
        'updatedAt': Timestamp.now(),
      });

  /// DELETE: removes the history entries first, then the incident.
  Future<void> delete(String id) async {
    final ref = _col.doc(id);
    final history = await ref.collection('statusHistory').get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in history.docs) {
      batch.delete(d.reference);
    }
    batch.delete(ref);
    await batch.commit();
  }
}