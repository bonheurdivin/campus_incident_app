import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/page_header.dart';
import '../details/incident_details_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _searchCtrl = TextEditingController();
  bool _mineOnly = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = context.read<IncidentProvider>().query;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    final auth = context.watch<AuthProvider>();
    final uid = auth.firebaseUser!.uid;

    var list = p.filtered;
    if (_mineOnly) list = list.where((i) => i.reporterId == uid).toList();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: PageHeader(
                    title: auth.isStaff ? 'All Reports' : 'Reports',
                    subtitle:
                        '${list.length} report${list.length == 1 ? '' : 's'} found',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: p.setQuery,
                    decoration: InputDecoration(
                      hintText: 'Search title, location or description',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: p.query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                p.setQuery('');
                              },
                            ),
                    ),
                  ),
                ),
                if (!auth.isStaff)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: false, label: Text('All reports')),
                        ButtonSegment(value: true, label: Text('My reports')),
                      ],
                      selected: {_mineOnly},
                      onSelectionChanged: (s) =>
                          setState(() => _mineOnly = s.first),
                    ),
                  ),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _chip('All status', p.statusFilter == null,
                          () => p.setStatusFilter(null)),
                      for (final s in IncidentStatus.values)
                        _chip(s.label, p.statusFilter == s,
                            () => p.setStatusFilter(s)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _chip('All categories', p.categoryFilter == null,
                          () => p.setCategoryFilter(null)),
                      for (final c in IncidentCategory.values)
                        _chip(c.label, p.categoryFilter == c,
                            () => p.setCategoryFilter(c)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(child: _body(p, list)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
        ),
      );

  Widget _body(IncidentProvider p, List list) {
    if (p.loading) return const Center(child: CircularProgressIndicator());
    if (p.error != null) return Center(child: Text(p.error!));
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No reports match your filters'),
            TextButton(
              onPressed: () {
                _searchCtrl.clear();
                p.clearFilters();
              },
              child: const Text('Clear filters'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, i) => IncidentCard(
        incident: list[i],
        onTap: () => IncidentDetailsScreen.open(context, list[i].id),
      ),
    );
  }
}