import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/enums.dart';
import '../models/incident.dart';
import '../models/status_entry.dart';
import '../services/incident_service.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentService _service;
  StreamSubscription<List<Incident>>? _sub;
  String? _boundUid;

  Incident? byId(String id) => all.where((i) => i.id == id).firstOrNull;

  Stream<List<StatusEntry>> history(String id) => _service.watchHistory(id);

  void clearFilters() {
    query = '';
    statusFilter = null;
    categoryFilter = null;
    notifyListeners();
  }

  List<Incident> all = [];
  bool loading = false;
  bool busy = false;
  String? error;

  // Search and filter state (used by the Reports screen later)
  String query = '';
  IncidentStatus? statusFilter;
  IncidentCategory? categoryFilter;

  IncidentProvider(this._service);

  /// Called whenever auth changes. Starts or stops the live stream.
  void bindUser(String? uid, bool verified) {
    final effective = verified ? uid : null;
    if (effective == _boundUid) return;
    _boundUid = effective;
    _sub?.cancel();
    all = [];
    error = null;
    if (effective == null) {
      loading = false;
      return;
    }
    loading = true;
    _sub = _service.watchAll().listen(
      (list) {
        all = list;
        loading = false;
        error = null;
        notifyListeners();
      },
      onError: (e) {
        error = 'Could not load reports';
        loading = false;
        notifyListeners();
      },
    );
  }

  List<Incident> mine(String uid) =>
      all.where((i) => i.reporterId == uid).toList();

  List<Incident> get filtered {
    final q = query.trim().toLowerCase();
    return all.where((i) {
      if (statusFilter != null && i.status != statusFilter) return false;
      if (categoryFilter != null && i.category != categoryFilter) return false;
      if (q.isNotEmpty &&
          !i.title.toLowerCase().contains(q) &&
          !i.location.toLowerCase().contains(q) &&
          !i.description.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  int countByStatus(List<Incident> list, IncidentStatus s) =>
      list.where((i) => i.status == s).length;

  void setQuery(String v) {
    query = v;
    notifyListeners();
  }

  void setStatusFilter(IncidentStatus? s) {
    statusFilter = s;
    notifyListeners();
  }

  void setCategoryFilter(IncidentCategory? c) {
    categoryFilter = c;
    notifyListeners();
  }

  // ---- Actions ----

  Future<bool> submit({
    required AppUser user,
    required String title,
    required String description,
    required String location,
    required IncidentCategory category,
    String? imageUrl,
  }) =>
      _run(() => _service.create(Incident(
            id: '',
            title: title.trim(),
            description: description.trim(),
            location: location.trim(),
            reporterId: user.uid,
            reporterName: user.name,
            category: category,
            status: IncidentStatus.submitted,
            imageUrl: imageUrl,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )));

  Future<bool> changeStatus(
    Incident incident,
    IncidentStatus status,
    AppUser staff, {
    String? note,
  }) =>
      _run(() => _service.updateStatus(incident.id, status, staff.name,
          note: note));

  Future<bool> edit(
    String id, {
    required String title,
    required String description,
    required String location,
    required IncidentCategory category,
  }) =>
      _run(() => _service.updateDetails(id,
          title: title.trim(),
          description: description.trim(),
          location: location.trim(),
          category: category));

  Future<bool> remove(String id) => _run(() => _service.delete(id));

  Future<bool> _run(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}