import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_theme.dart';

/// Small pill showing a task's SLA status. Uses color AND icon + text,
/// so the status is not conveyed by color alone.
class SlaBadge extends StatelessWidget {
  final SlaStatus status;
  const SlaBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forSla(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppColors.iconForSla(status), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}