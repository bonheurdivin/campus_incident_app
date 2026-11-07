import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.mark_email_unread_outlined,
                      size: 72, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('Verify your email',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a verification link to\n${auth.firebaseUser?.email ?? ''}\n'
                    'Open it, then come back and tap the button below.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: auth.busy
                        ? null
                        : () async {
                            await auth.checkVerified();
                            if (!auth.isVerified && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Not verified yet. Check your inbox (and spam).')),
                              );
                            }
                          },
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text("I've verified my email"),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: auth.busy
                        ? null
                        : () async {
                            final ok = await auth.resendVerification();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(ok
                                  ? 'Verification email sent'
                                  : (auth.error ?? 'Could not send email')),
                            ));
                          },
                    child: const Text('Resend email'),
                  ),
                  TextButton(
                    onPressed: auth.logout,
                    child: const Text('Use a different account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}