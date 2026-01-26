import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/msh_colors.dart';
import '../../core/constants/app_strings.dart';

/// "Powered by KOLAN Systems" Badge
/// Klickbar, verlinkt auf kolan-systems.de
class PoweredByBadge extends StatelessWidget {
  final bool compact;
  final Color? textColor;

  const PoweredByBadge({
    super.key,
    this.compact = false,
    this.textColor,
  });

  Future<void> _launchUrl() async {
    final uri = Uri.parse(AppStrings.companyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? MshColors.textSecondary;

    if (compact) {
      return _buildCompact(color);
    }
    return _buildFull(color);
  }

  Widget _buildCompact(Color color) {
    return InkWell(
      onTap: _launchUrl,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt, size: 14, color: MshColors.primary),
            const SizedBox(width: 4),
            Text(
              AppStrings.companyName,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFull(Color color) {
    return InkWell(
      onTap: _launchUrl,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: MshColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MshColors.surfaceVariant),
          boxShadow: [
            BoxShadow(
              color: MshColors.primary.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: MshColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bolt,
                size: 18,
                color: MshColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.poweredBy,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.companyName,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  AppStrings.companyOwner,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.open_in_new,
              size: 14,
              color: color.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
