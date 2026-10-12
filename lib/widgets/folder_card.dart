import 'package:flutter/material.dart';

import '../models/music_folder.dart';
import '../theme/app_theme.dart';
import '../theme/motion.dart';
import 'cd_case.dart';

class FolderCard extends StatelessWidget {
  const FolderCard({
    super.key,
    required this.folder,
    this.index,
    this.active = false,
    this.onTap,
  });

  final MusicFolder folder;
  final int? index;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isAero = context.isAero;
    final isPhantom = context.isPhantom;
    final count = folder.songs.length;

    final case_ = CdCase(folder: folder, index: index);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isAero ? 12 : 4),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: isPhantom
                        ? _PhantomCaseSlot(active: active, child: case_)
                        : case_,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (isPhantom)
                _PhantomLabel(
                  folder: folder,
                  index: index,
                  active: active,
                  count: count,
                )
              else ...[
                // Numbered label row for the curated-collection feel.
                Row(
                  children: [
                    if (index != null) ...[
                      Text(
                        index.toString().padLeft(2, '0'),
                        style: text.labelMedium?.copyWith(
                          color: isAero
                              ? AeroPalette.primary
                              : P3Palette.yellow,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 10,
                        height: 2,
                        color:
                            isAero ? AeroPalette.sky : P3Palette.yellow,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        folder.name,
                        style: text.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  '$count ${count == 1 ? 'TRACK' : 'TRACKS'}',
                  style: text.labelSmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Phantom: the case sits in a yellow angular selection frame when its
/// folder holds the current track, and snaps forward on change.
class _PhantomCaseSlot extends StatelessWidget {
  const _PhantomCaseSlot({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduce = reduceMotionOf(context);
    return AnimatedScale(
      scale: active ? 1.0 : 0.97,
      duration: reduce
          ? Duration.zero
          : const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          // Angular selection frame + cursor wedge.
          if (active)
            const IgnorePointer(
              child: CustomPaint(
                painter: _CornerBracketPainter(),
              ),
            ),
        ],
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  const _CornerBracketPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PhantomPalette.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square;
    const len = 18.0;
    // Top-left bracket.
    canvas.drawLine(Offset.zero, const Offset(len, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, len), paint);
    // Bottom-right bracket.
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - len, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - len), paint);
    // Cursor wedge, mid-left.
    final wedge = Paint()..color = PhantomPalette.yellow;
    canvas.drawPath(
      Path()
        ..moveTo(6, size.height / 2 - 9)
        ..lineTo(18, size.height / 2)
        ..lineTo(6, size.height / 2 + 9)
        ..close(),
      wedge,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Phantom label block: oversized index, technical counts, clear name.
class _PhantomLabel extends StatelessWidget {
  const _PhantomLabel({
    required this.folder,
    required this.index,
    required this.active,
    required this.count,
  });

  final MusicFolder folder;
  final int? index;
  final bool active;
  final int count;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (index != null)
              Text(
                index.toString().padLeft(2, '0'),
                style: text.headlineMedium?.copyWith(
                  fontSize: 20,
                  color: active ? PhantomPalette.yellow : PhantomPalette.muted,
                  letterSpacing: 1,
                ),
              ),
            const SizedBox(width: 6),
            // Slash separator.
            Transform.rotate(
              angle: 0.35,
              child: Container(
                width: 3,
                height: 14,
                color: active ? PhantomPalette.blue : PhantomPalette.hairline,
              ),
            ),
            const Spacer(),
            if (active)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chevron_right,
                      size: 15, color: PhantomPalette.yellow),
                  const SizedBox(width: 1),
                  Text(
                    'ACTIVE',
                    style: text.labelSmall?.copyWith(
                      color: PhantomPalette.yellow,
                    ),
                  ),
                ],
              )
            else
              Text(
                '$count ${count == 1 ? 'TRK' : 'TRKS'}',
                style: text.labelSmall,
              ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          folder.name,
          style: text.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Thin rule with a yellow tip on the active card.
        Row(
          children: [
            Container(
              width: active ? 34 : 18,
              height: 3,
              color: active ? PhantomPalette.yellow : PhantomPalette.blue,
            ),
            const SizedBox(width: 4),
            Expanded(child: Container(height: 1, color: PhantomPalette.hairline)),
          ],
        ),
      ],
    );
  }
}
