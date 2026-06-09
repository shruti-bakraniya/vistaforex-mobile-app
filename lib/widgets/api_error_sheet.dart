import 'package:flutter/material.dart';
import '../app/colors.dart';
import '../data/models.dart';

class ApiErrorSheet extends StatefulWidget {
  const ApiErrorSheet({
    super.key,
    required this.source,
    required this.onSwitch,
    required this.onDismiss,
  });
  final ApiSource source;
  final VoidCallback onSwitch;
  final VoidCallback onDismiss;

  @override
  State<ApiErrorSheet> createState() => _ApiErrorSheetState();
}

class _ApiErrorSheetState extends State<ApiErrorSheet> {
  bool _retrying = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = VfColors(dark: dark);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.6 : 0.14),
            blurRadius: 70,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grabber
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.border2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: c.downSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.warning_rounded, color: c.down, size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            'Couldn\'t reach ${widget.source.name}',
            style: TextStyle(
              color: c.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.015,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'The response failed an integrity check. VistaForex paused this feed to protect your conversions.',
            style: TextStyle(
              color: c.text2,
              fontSize: 13.5,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: Row(children: [
              Icon(Icons.warning_amber_rounded, color: c.down, size: 13),
              const SizedBox(width: 8),
              Text(
                'ERR_FEED_CHECKSUM · 502',
                style: TextStyle(
                  color: c.down,
                  fontSize: 11.5,
                  fontFamily: 'monospace',
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: widget.onSwitch,
              icon: const Icon(Icons.bolt_rounded, size: 18),
              label: const Text('Switch to Frankfurter (ECB)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: _retrying
                      ? null
                      : () async {
                          setState(() => _retrying = true);
                          await Future.delayed(
                              const Duration(milliseconds: 1300));
                          if (mounted) setState(() => _retrying = false);
                        },
                  icon: _retrying
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(_retrying ? 'Retrying…' : 'Retry'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.text,
                    side: BorderSide(color: c.border2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 46,
                child: TextButton(
                  onPressed: widget.onDismiss,
                  style: TextButton.styleFrom(
                    foregroundColor: c.text2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Dismiss'),
                ),
              ),
            ),
          ]),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }
}

void showApiErrorSheet(
  BuildContext context, {
  required ApiSource source,
  required VoidCallback onSwitch,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (ctx) => ApiErrorSheet(
      source: source,
      onSwitch: () {
        Navigator.pop(ctx);
        onSwitch();
      },
      onDismiss: () => Navigator.pop(ctx),
    ),
  );
}
