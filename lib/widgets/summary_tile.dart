import 'package:flutter/material.dart';

class SummaryTile extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const SummaryTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(28),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text('$value',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}