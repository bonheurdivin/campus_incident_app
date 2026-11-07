import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/page_header.dart';
import '../../widgets/summary_tile.dart';
import '../details/incident_details_screen.dart';
import '../report/report_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final incidents = context.watch<IncidentProvider>();
    final theme = Theme.of(context);

    final mine = incidents.mine(auth.firebaseUser?.uid ?? '');
    final name = auth.appUser?.name ?? '';
    final firstName = name.split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                PageHeader(
                  title: 'Hello, $firstName',
                  subtitle: 'Help make our campus safer.',
                  trailing: CircleAvatar(
                    radius: 22,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      name.isEmpty ? '?' : name[0].toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C4CF1), Color(0xFF8E6BFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('See an issue on campus?',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text(
                          'Report it and help improve our learning environment.',
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6C4CF1),
                        ),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Report an Issue'),
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ReportScreen())),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Report Summary',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SummaryTile(
                        label: 'My Reports',
                        value: mine.length,
                        icon: Icons.description_outlined,
                        color: theme.colorScheme.primary),
                    SummaryTile(
                        label: 'Submitted',
                        value: incidents.countByStatus(
                            mine, IncidentStatus.submitted),
                        icon: Icons.outbox_outlined,
                        color: IncidentStatus.submitted.color),
                    SummaryTile(
                        label: 'In Progress',
                        value: incidents.countByStatus(
                            mine, IncidentStatus.inProgress),
                        icon: Icons.schedule,
                        color: IncidentStatus.inProgress.color),
                    SummaryTile(
                        label: 'Resolved',
                        value: incidents.countByStatus(
                            mine, IncidentStatus.resolved),
                        icon: Icons.check_circle_outline,
                        color: IncidentStatus.resolved.color),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Recent Reports',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (incidents.loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (incidents.error != null)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(incidents.error!)),
                  )
                else if (mine.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                        child: Text('No reports yet. Tap "Report an Issue".')),
                  )
                else
                  ...mine.take(5).map((i) => IncidentCard(
                        incident: i,
                        onTap: () =>
                            IncidentDetailsScreen.open(context, i.id),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
