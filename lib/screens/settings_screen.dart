import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/library_controller.dart';
import '../state/settings_controller.dart';
import '../theme/app_theme.dart';
import '../theme/backgrounds.dart';
import '../theme/shapes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final text = Theme.of(context).textTheme;
    final isAero = context.isAero;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('SETTINGS')),
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          SafeArea(
            child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _SectionTitle('THEME'),
            const SizedBox(height: 4),
            Text('Switch between the looks.', style: text.bodySmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ThemeCard(
                    title: 'PERSONA 3',
                    subtitle: 'Midnight blue, sharp and moody',
                    selected: settings.theme == AppThemeName.persona3,
                    preview: const _P3Preview(),
                    onTap: () =>
                        settings.setTheme(AppThemeName.persona3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ThemeCard(
                    title: 'FRUTIGER AERO',
                    subtitle: 'Sky bright, glassy and glossy',
                    selected: settings.theme == AppThemeName.aero,
                    preview: const _AeroPreview(),
                    onTap: () => settings.setTheme(AppThemeName.aero),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Full-width card so the third choice reads as a feature.
            _ThemeCard(
              title: 'PHANTOM — GAME MENU',
              subtitle: 'Slanted, graphic and loud',
              selected: settings.theme == AppThemeName.phantom,
              preview: const _PhantomPreview(),
              onTap: () => settings.setTheme(AppThemeName.phantom),
            ),
            const SizedBox(height: 24),
            _SectionTitle('PLAYBACK'),
            const SizedBox(height: 8),
            ThemedPanel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SwitchListTile(
                title: const Text('Reduce motion'),
                subtitle: const Text('Stops the disc from spinning.'),
                value: settings.reduceMotion,
                onChanged: settings.setReduceMotion,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle('LIBRARY'),
            const SizedBox(height: 8),
            ThemedPanel(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Rescan music'),
                subtitle: const Text('Look for new files on this device.'),
                onTap: () =>
                    context.read<LibraryController>().load(force: true),
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle('ABOUT'),
            const SizedBox(height: 8),
            ThemedPanel(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AirplaneMode', style: text.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'A folder-first MP3 player. '
                    '${isAero
                        ? 'Enjoy the sky.'
                        : context.isPhantom
                            ? 'Choose your music.'
                            : 'Face the night.'}',
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
          ],
        ),
    );
  }
}

/// Section header: accent marker + uppercase heading.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final isAero = context.isAero;
    final isPhantom = context.isPhantom;
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        if (isAero)
          Container(
            width: 16,
            height: 8,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF68C7EB), Color(0xFF167CB5)]),
              borderRadius: BorderRadius.circular(4),
            ),
          )
        else if (isPhantom)
          Container(
            width: 14,
            height: 16,
            margin: const EdgeInsets.only(right: 9),
            decoration: const ShapeDecoration(
              color: PhantomPalette.yellow,
              shape: SlantBorder(slant: 5, side: BorderSide.none),
            ),
          )
        else
          Container(
            width: 5,
            height: 18,
            margin: const EdgeInsets.only(right: 10),
            color: P3Palette.yellow,
          ),
        Text(label, style: text.titleLarge),
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.preview,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final Widget preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isPhantom = context.isPhantom;
    final accent = context.isAero
        ? AeroPalette.primary
        : isPhantom
            ? PhantomPalette.yellow
            : P3Palette.yellow;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(context.isAero ? 18 : isPhantom ? 6 : 6),
        child: ThemedPanel(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(
                    context.isAero ? 12 : isPhantom ? 2 : 4),
                child: SizedBox(height: 96, width: double.infinity, child: preview),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(title,
                        style: text.titleMedium?.copyWith(
                          color: selected
                              ? accent
                              : text.titleMedium?.color,
                        )),
                  ),
                  if (selected)
                    Icon(Icons.check_circle, color: accent, size: 20),
                ],
              ),
              Text(subtitle, style: text.bodySmall, maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _P3Preview extends StatelessWidget {
  const _P3Preview();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [P3Palette.bg, P3Palette.steel],
        ),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            right: -20,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFF1A1A1E), Color(0xFF0B0B0D)],
                ),
              ),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF141D3F),
                    border: Border.fromBorderSide(
                        BorderSide(color: P3Palette.yellow, width: 1.5)),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 6,
                  color: P3Palette.yellow,
                ),
                const SizedBox(height: 6),
                Container(
                  width: 70,
                  height: 8,
                  color: P3Palette.textPrimary,
                ),
                const SizedBox(height: 4),
                Container(
                  width: 50,
                  height: 6,
                  color: P3Palette.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AeroPreview extends StatelessWidget {
  const _AeroPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AeroPalette.skyTop, AeroPalette.skyBottom],
        ),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            right: -14,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFF1A1A1E), Color(0xFF0B0B0D)],
                ),
              ),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF8FD0FF),
                    border: Border.fromBorderSide(
                        BorderSide(color: Colors.white, width: 1.5)),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 70,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AeroPalette.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 84,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AeroPalette.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Phantom sample: dark plate, blue diagonal band, yellow cursor rows
/// and a cropped menu number.
class _PhantomPreview extends StatelessWidget {
  const _PhantomPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PhantomPalette.bg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Electric-blue diagonal band.
          Positioned(
            right: 18,
            top: -40,
            child: Transform.rotate(
              angle: -0.45,
              child: Container(
                width: 44,
                height: 180,
                color: PhantomPalette.blue.withValues(alpha: 0.85),
              ),
            ),
          ),
          // Cropped menu number.
          Positioned(
            right: 8,
            bottom: -18,
            child: Text(
              '04',
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontWeight: FontWeight.w700,
                fontSize: 82,
                height: 1,
                letterSpacing: 2,
                color: PhantomPalette.yellow,
              ),
            ),
          ),
          // Menu rows: one selected, two idle.
          Positioned(
            left: 10,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 11,
                      height: 15,
                      decoration: const ShapeDecoration(
                        color: PhantomPalette.yellow,
                        shape: SlantBorder(slant: 5, side: BorderSide.none),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(width: 46, height: 7, color: PhantomPalette.text),
                  ],
                ),
                const SizedBox(height: 7),
                Container(width: 62, height: 6, color: PhantomPalette.muted),
                const SizedBox(height: 6),
                Container(width: 38, height: 6, color: PhantomPalette.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
