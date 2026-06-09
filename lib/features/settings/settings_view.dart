import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/colors.dart';
import '../../data/api_sources.dart';
import '../../data/models.dart';
import '../../widgets/api_error_sheet.dart';
import '../../widgets/badge_chip.dart';
import '../home/home_controller.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();

    return Obx(() {
      final dark = home.isDark.value;
      final c = VfColors(dark: dark);

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
        children: [
          Text(
            'Settings',
            style: TextStyle(
              color: c.text,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.025,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Pick your rate provider and control sync.',
            style: TextStyle(color: c.text2, fontSize: 13.5, height: 1.4),
          ),
          const SizedBox(height: 22),
          _SectionTitle(icon: Icons.storage_rounded, title: 'Exchange rate source', c: c),
          const SizedBox(height: 11),
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            padding: const EdgeInsets.all(6),
            child: Obx(
              () => Column(
                children: kApiSources.asMap().entries.map((e) {
                  final isLast = e.key == kApiSources.length - 1;
                  return _SourceRow(
                    source: e.value,
                    active: e.value.id == controller.activeSourceId.value,
                    isLast: isLast,
                    c: c,
                    onSelect: () {
                      if (e.value.status == ApiSourceStatus.error) {
                        showApiErrorSheet(
                          context,
                          source: e.value,
                          onSwitch: () => controller.setSource('frankfurter'),
                        );
                      } else {
                        controller.setSource(e.value.id);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 22),
          _SectionTitle(
              icon: Icons.refresh_rounded, title: 'Sync & refresh', c: c),
          const SizedBox(height: 11),
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-refresh interval',
                      style: TextStyle(
                        color: c.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'How often live rates re-fetch.',
                      style: TextStyle(color: c.text3, fontSize: 12.5),
                    ),
                    const SizedBox(height: 11),
                    Obx(() => _SyncSelector(
                          value: controller.syncInterval.value,
                          onChanged: controller.setSyncInterval,
                          c: c,
                        )),
                  ],
                ),
              ),
              Divider(color: c.border, height: 1, indent: 14, endIndent: 14),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Use cached rates offline',
                          style: TextStyle(
                            color: c.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Show last fetch instead of an error.',
                          style: TextStyle(color: c.text3, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Obx(() => _Toggle(
                        value: controller.useOfflineCache.value,
                        onChanged: controller.setUseOfflineCache,
                      )),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 22),
          _SectionTitle(
              icon: Icons.info_outline_rounded, title: 'Active feed', c: c),
          const SizedBox(height: 11),
          Obx(() {
            final src = controller.activeSource;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.border),
              ),
              child: Row(children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: c.accentSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.language_rounded, color: kAccent, size: 21),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        src.name,
                        style: TextStyle(
                          color: c.text,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        src.frequency,
                        style: TextStyle(color: c.text2, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                BadgeChip(
                  label: 'Streaming',
                  tone: BadgeTone.up,
                  leading: PulseDot(color: c.up),
                ),
              ]),
            );
          }),
          const SizedBox(height: 22),
          _SectionTitle(
              icon: Icons.palette_outlined, title: 'Appearance', c: c),
          const SizedBox(height: 11),
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dark mode',
                          style: TextStyle(
                            color: c.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Toggle between light and dark theme.',
                          style: TextStyle(color: c.text3, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Obx(() => _Toggle(
                        value: home.isDark.value,
                        onChanged: (_) => home.toggleTheme(),
                      )),
                ]),
              ),
            ]),
          ),
        ],
      );
    });
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.c,
  });
  final IconData icon;
  final String title;
  final VfColors c;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: kAccent, size: 16),
      const SizedBox(width: 8),
      Text(
        title,
        style: TextStyle(
          color: c.text,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01,
        ),
      ),
    ]);
  }
}

class _SourceRow extends StatefulWidget {
  const _SourceRow({
    required this.source,
    required this.active,
    required this.isLast,
    required this.c,
    required this.onSelect,
  });
  final ApiSource source;
  final bool active;
  final bool isLast;
  final VfColors c;
  final VoidCallback onSelect;

  @override
  State<_SourceRow> createState() => _SourceRowState();
}

class _SourceRowState extends State<_SourceRow> {
  bool _testing = false;
  bool _tested = false;

  static const _statusLabels = {
    ApiSourceStatus.active: ('Connected', BadgeTone.up),
    ApiSourceStatus.ok: ('Available', BadgeTone.neutral),
    ApiSourceStatus.degraded: ('Degraded', BadgeTone.warn),
    ApiSourceStatus.error: ('Unreachable', BadgeTone.down),
  };

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final (statusLabel, statusTone) =
        _statusLabels[widget.source.status] ?? ('Unknown', BadgeTone.neutral);
    final disabled = widget.source.status == ApiSourceStatus.error;

    return GestureDetector(
      onTap: widget.onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: widget.active ? c.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Opacity(
          opacity: disabled ? 0.6 : 1.0,
          child: Row(children: [
            // Radio
            Container(
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.active ? kAccent : c.border2,
                  width: 2,
                ),
              ),
              child: widget.active
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: kAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Name + status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(
                      widget.source.name,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.source.badge != null) ...[
                      const SizedBox(width: 8),
                      BadgeChip(
                        label: widget.source.badge!,
                        tone: BadgeTone.accent,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 3),
                  Row(children: [
                    BadgeChip(
                      label: statusLabel,
                      tone: statusTone,
                      fontSize: 10.5,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                    ),
                    if (widget.source.latencyMs != null) ...[
                      const SizedBox(width: 7),
                      Text(
                        '${widget.source.latencyMs}ms',
                        style: TextStyle(
                          color: c.text3,
                          fontSize: 10.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
            // Test button
            GestureDetector(
              onTap: _testing
                  ? null
                  : () async {
                      setState(() {
                        _testing = true;
                        _tested = false;
                      });
                      await Future.delayed(const Duration(milliseconds: 1000));
                      if (mounted) {
                        setState(() {
                          _testing = false;
                          if (widget.source.status != ApiSourceStatus.error) {
                            _tested = true;
                          } else {
                            widget.onSelect(); // Triggers error sheet
                          }
                        });
                      }
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_testing)
                      SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      )
                    else if (_tested)
                      Icon(Icons.check_rounded, color: c.up, size: 13)
                    else
                      Icon(Icons.bolt_rounded, color: c.text2, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      _testing ? '…' : _tested ? 'OK' : 'Test',
                      style: TextStyle(
                        color: _tested ? c.up : c.text2,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SyncSelector extends StatelessWidget {
  const _SyncSelector({
    required this.value,
    required this.onChanged,
    required this.c,
  });
  final String value;
  final ValueChanged<String> onChanged;
  final VfColors c;

  static const _options = [
    ('5s', '5s'),
    ('30s', '30s'),
    ('1m', '1 min'),
    ('manual', 'Manual'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: _options.map((opt) {
          final active = value == opt.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 32,
                decoration: BoxDecoration(
                  color: active ? c.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    opt.$2,
                    style: TextStyle(
                      color: active ? c.text : c.text2,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final offColor = dark ? kDarkSurface3 : kLightSurface3;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? kAccent : offColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
