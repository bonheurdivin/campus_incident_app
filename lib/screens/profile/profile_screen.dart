import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/page_header.dart';
import '../../widgets/summary_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign out')),
        ],
      ),
    );
    if (sure == true) await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final p = context.watch<IncidentProvider>();
    final theme = Theme.of(context);

    final user = auth.appUser;
    final name = user?.name ?? '';
    final list =
        auth.isStaff ? p.all : p.mine(auth.firebaseUser?.uid ?? '');

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const PageHeader(title: 'Profile'),

                // Identity card
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
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white,
                        child: Text(
                          name.isEmpty ? '?' : name[0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C4CF1)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(user?.email ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                auth.isStaff ? 'Campus staff' : 'Student',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats
                Row(
                  children: [
                    SummaryTile(
                        label: auth.isStaff ? 'All Reports' : 'My Reports',
                        value: list.length,
                        icon: Icons.description_outlined,
                        color: theme.colorScheme.primary),
                    SummaryTile(
                        label: 'In Progress',
                        value: p.countByStatus(list, IncidentStatus.inProgress),
                        icon: Icons.schedule,
                        color: IncidentStatus.inProgress.color),
                    SummaryTile(
                        label: 'Resolved',
                        value: p.countByStatus(list, IncidentStatus.resolved),
                        icon: Icons.check_circle_outline,
                        color: IncidentStatus.resolved.color),
                  ],
                ),
                const SizedBox(height: 20),

                // Account details
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.verified_outlined,
                            color: Colors.green),
                        title: const Text('Email status'),
                        subtitle:
                            Text(auth.isVerified ? 'Verified' : 'Not verified'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.badge_outlined),
                        title: const Text('Role'),
                        subtitle:
                            Text(auth.isStaff ? 'Campus staff' : 'Student'),
                      ),
                      if (user != null) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading:
                              const Icon(Icons.calendar_today_outlined),
                          title: const Text('Member since'),
                          subtitle:
                              Text(DateFormat.yMMMd().format(user.createdAt)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}