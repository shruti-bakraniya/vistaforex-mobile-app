import 'package:flutter/material.dart';
import '../app/colors.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.lastSyncTime, this.onRetry});
  final DateTime? lastSyncTime;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = VfColors(dark: dark);

    final timeStr = lastSyncTime != null
        ? '${lastSyncTime!.hour.toString().padLeft(2, '0')}:${lastSyncTime!.minute.toString().padLeft(2, '0')}'
        : 'unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: c.warnSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: c.warn, size: 18),
          const SizedBox(width: 11),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: c.text2, fontSize: 12.5, height: 1.35),
                children: [
                  TextSpan(
                    text: "You're offline. ",
                    style: TextStyle(
                      color: c.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: 'Showing cached rates from $timeStr.'),
                ],
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRetry,
              child: Row(
                children: [
                  Icon(Icons.refresh_rounded, color: c.warn, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Retry',
                    style: TextStyle(
                      color: c.warn,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
