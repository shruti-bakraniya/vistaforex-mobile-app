import 'package:flutter/material.dart';
import '../app/colors.dart';

class NoInternetView extends StatefulWidget {
  const NoInternetView({
    super.key,
    required this.onRetry,
    required this.onUseCache,
    this.lastSyncTime,
  });
  final VoidCallback onRetry;
  final VoidCallback onUseCache;
  final DateTime? lastSyncTime;

  @override
  State<NoInternetView> createState() => _NoInternetViewState();
}

class _NoInternetViewState extends State<NoInternetView> {
  bool _trying = false;

  void _retry() async {
    setState(() => _trying = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() => _trying = false);
      widget.onRetry();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = VfColors(dark: dark);

    final lastSync = widget.lastSyncTime;
    final syncStr = lastSync != null
        ? '${lastSync.hour.toString().padLeft(2, '0')}:${lastSync.minute.toString().padLeft(2, '0')}'
            ', ${lastSync.day} ${_monthName(lastSync.month)} ${lastSync.year}'
        : '—';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: c.warnSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wifi_off_rounded, color: c.warn, size: 38),
          ),
          const SizedBox(height: 24),
          Text(
            'No internet connection',
            style: TextStyle(
              color: c.text,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.02,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'VistaForex can\'t reach the rate servers.\nCheck your connection, or use your last synced rates.',
            style: TextStyle(
              color: c.text2,
              fontSize: 14.5,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _trying ? null : _retry,
              icon: _trying
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: Text(_trying ? 'Reconnecting…' : 'Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: widget.onUseCache,
              icon: const Icon(Icons.storage_rounded, size: 18),
              label: const Text('Use cached rates'),
              style: OutlinedButton.styleFrom(
                foregroundColor: c.text,
                side: BorderSide(color: c.border2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Last sync · $syncStr',
            style: TextStyle(
              color: c.text3,
              fontSize: 11.5,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[m];
  }
}
