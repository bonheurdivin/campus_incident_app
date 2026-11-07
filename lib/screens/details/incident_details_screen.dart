import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/enums.dart';
import '../../models/incident.dart';
import '../../models/status_entry.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/status_chip.dart';
import '../report/report_screen.dart';

final _dateFmt = DateFormat('MMM d, y, h:mm a');

class IncidentDetailsScreen extends StatelessWidget {
  final String incidentId;
  const IncidentDetailsScreen({super.key, required this.incidentId});

  static void open(BuildContext context, String id) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => IncidentDetailsScreen(incidentId: id)));
  }

  Future<void> _delete(BuildContext context, Incident incident) async {
    final provider = context.read<IncidentProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (sure != true) return;

    final ok = await provider.remove(incident.id);
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Report deleted')));
    } else {
      messenger.showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Could not delete')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final incident = provider.byId(incidentId);

    if (incident == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This report is no longer available')),
      );
    }

    final isOwner = incident.reporterId == auth.firebaseUser?.uid;
    final canEdit = !auth.isStaff && isOwner && incident.status == IncidentStatus.submitted;
    final canDelete = canEdit || auth.isStaff;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        actions: [
          if (canEdit)
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ReportScreen(existing: incident))),
            ),
          if (canDelete)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, incident),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (incident.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      incident.imageUrl!,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
                          height: 80,
                          child: Center(child: Text('Photo unavailable'))),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Chip(
                      avatar: Icon(incident.category.icon, size: 18),
                      label: Text(incident.category.label),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(status: incident.status),
                  ],
                ),
                const SizedBox(height: 12),
                Text(incident.title,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _InfoRow(Icons.location_on_outlined, incident.location),
                _InfoRow(Icons.person_outline,
                    'Reported by ${incident.reporterName}'),
                _InfoRow(Icons.schedule,
                    'Submitted ${_dateFmt.format(incident.createdAt)}'),
                const SizedBox(height: 16),
                Text('Description',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(incident.description),
                const SizedBox(height: 24),
                if (auth.isStaff) ...[
                  _StaffPanel(incident: incident),
                  const SizedBox(height: 24),
                ],
                Text('Status Timeline',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _Timeline(incidentId: incident.id),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      );
}

class _Timeline extends StatefulWidget {
  final String incidentId;
  const _Timeline({required this.incidentId});

  @override
  State<_Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<_Timeline> {
  late final Stream<List<StatusEntry>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = context.read<IncidentProvider>().history(widget.incidentId);
  }

  @override
  Widget build(BuildContext context) {
    final line = Theme.of(context).colorScheme.outlineVariant;

    return StreamBuilder<List<StatusEntry>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) return const Text('Could not load history');
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final entries = snap.data!;
        if (entries.isEmpty) return const Text('No history yet');

        return Column(
          children: [
            for (var i = 0; i < entries.length; i++)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Column(
                        children: [
                          Icon(Icons.circle,
                              size: 14, color: entries[i].status.color),
                          if (i != entries.length - 1)
                            Expanded(child: Container(width: 2, color: line)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entries[i].status.label,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(
                                '${entries[i].changedBy}, ${_dateFmt.format(entries[i].timestamp)}',
                                style: Theme.of(context).textTheme.bodySmall),
                            if (entries[i].note.isNotEmpty) Text(entries[i].note),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Only shown to staff. Lets them change the status and add a note.
class _StaffPanel extends StatefulWidget {
  final Incident incident;
  const _StaffPanel({required this.incident});

  @override
  State<_StaffPanel> createState() => _StaffPanelState();
}

class _StaffPanelState extends State<_StaffPanel> {
  late IncidentStatus _status = widget.incident.status;
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    final provider = context.read<IncidentProvider>();
    final staff = context.read<AuthProvider>().appUser;
    final messenger = ScaffoldMessenger.of(context);
    if (staff == null) return;

    final ok = await provider.changeStatus(
        widget.incident, _status, staff,
        note: _noteCtrl.text.trim());
    if (ok) _noteCtrl.clear();
    messenger.showSnackBar(SnackBar(
        content: Text(ok
            ? 'Status updated to ${_status.label}'
            : (provider.error ?? 'Update failed'))));
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<IncidentProvider>().busy;
    final changed = _status != widget.incident.status;

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Staff actions',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SegmentedButton<IncidentStatus>(
              showSelectedIcon: false,
              segments: IncidentStatus.values
                  .map((s) => ButtonSegment(value: s, label: Text(s.label)))
                  .toList(),
              selected: {_status},
              onSelectionChanged: (s) => setState(() => _status = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Note for the student (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: (busy || !changed) ? null : _update,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
              child: busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Update status'),
            ),
          ],
        ),
      ),
    );
  }
}