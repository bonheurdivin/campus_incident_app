import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/summary_tile.dart';
import '../../widgets/page_header.dart';
import '../details/incident_details_screen.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final p = context.watch<IncidentProvider>();
    final theme = Theme.of(context);

    final all = p.all;
    final pending =
        all.where((i) => i.status == IncidentStatus.submitted).toList();
    final firstName = (auth.appUser?.name ?? '').split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PageHeader(
                  title: 'Hello, $firstName',
                  subtitle: 'Review reports and keep students updated.',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SummaryTile(
                        label: 'Total',
                        value: all.length,
                        icon: Icons.description_outlined,
                        color: theme.colorScheme.primary),
                    SummaryTile(
                        label: 'Submitted',
                        value: pending.length,
                        icon: Icons.outbox_outlined,
                        color: IncidentStatus.submitted.color),
                    SummaryTile(
                        label: 'In Progress',
                        value: p.countByStatus(all, IncidentStatus.inProgress),
                        icon: Icons.schedule,
                        color: IncidentStatus.inProgress.color),
                    SummaryTile(
                        label: 'Resolved',
                        value: p.countByStatus(all, IncidentStatus.resolved),
                        icon: Icons.check_circle_outline,
                        color: IncidentStatus.resolved.color),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Needs attention',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (p.loading)
                  const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()))
                else if (p.error != null)
                  Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(child: Text(p.error!)))
                else if (pending.isEmpty)
                  const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No new reports. All caught up!')))
                else
                  ...pending.take(10).map((i) => IncidentCard(
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