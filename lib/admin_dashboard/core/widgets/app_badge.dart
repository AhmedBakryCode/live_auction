import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class AppBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  // Alias constructor for 'label' usage
  factory AppBadge.labeled({
    required String label,
    required Color color,
    IconData? icon,
  }) {
    return AppBadge(text: label, color: color, icon: icon);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body2.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
