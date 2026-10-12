import 'package:flutter/material.dart';

/// Angular cut-corner border (Persona-inspired silhouette).
///
/// Cuts all four corners by default, or only the top-left and
/// bottom-right corners when [diagonal] is true, for an asymmetric
/// HUD-like shape.
@immutable
class CutCornerBorder extends OutlinedBorder {
  const CutCornerBorder({
    super.side = const BorderSide(),
    this.radius = 8,
    this.diagonal = false,
  });

  /// Size of each corner cut.
  final double radius;

  /// When true only the top-left and bottom-right corners are cut.
  final bool diagonal;

  @override
  CutCornerBorder copyWith({BorderSide? side, double? radius, bool? diagonal}) =>
      CutCornerBorder(
        side: side ?? this.side,
        radius: radius ?? this.radius,
        diagonal: diagonal ?? this.diagonal,
      );

  @override
  ShapeBorder scale(double t) => CutCornerBorder(
        side: side.scale(t),
        radius: radius * t,
        diagonal: diagonal,
      );

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final tl = radius;
    final tr = diagonal ? 0.0 : radius;
    final br = radius;
    final bl = diagonal ? 0.0 : radius;
    return Path()
      ..moveTo(rect.left + tl, rect.top)
      ..lineTo(rect.right - tr, rect.top)
      ..lineTo(rect.right, rect.top + tr)
      ..lineTo(rect.right, rect.bottom - br)
      ..lineTo(rect.right - br, rect.bottom)
      ..lineTo(rect.left + bl, rect.bottom)
      ..lineTo(rect.left, rect.bottom - bl)
      ..lineTo(rect.left, rect.top + tl)
      ..close();
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final w = side.width;
    return getOuterPath(
      Rect.fromLTRB(rect.left + w, rect.top + w, rect.right - w, rect.bottom - w),
      textDirection: textDirection,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    canvas.drawPath(getOuterPath(rect), side.toPaint());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CutCornerBorder &&
          other.side == side &&
          other.radius == radius &&
          other.diagonal == diagonal;

  @override
  int get hashCode => Object.hash(side, radius, diagonal);
}

/// Slanted parallelogram border (Phantom game-menu silhouette).
///
/// The top edge sits [slant] pixels right of the bottom edge, giving
/// panels and buttons a forward lean like an italic menu plate.
@immutable
class SlantBorder extends OutlinedBorder {
  const SlantBorder({
    super.side = const BorderSide(),
    this.slant = 12,
  });

  /// Horizontal lean of the side edges.
  final double slant;

  double _s(Rect rect) => slant.clamp(0.0, rect.width / 2);

  @override
  SlantBorder copyWith({BorderSide? side, double? slant}) => SlantBorder(
        side: side ?? this.side,
        slant: slant ?? this.slant,
      );

  @override
  ShapeBorder scale(double t) =>
      SlantBorder(side: side.scale(t), slant: slant * t);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final s = _s(rect);
    return Path()
      ..moveTo(rect.left + s, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right - s, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final w = side.width;
    return getOuterPath(
      Rect.fromLTRB(rect.left + w, rect.top + w, rect.right - w, rect.bottom - w),
      textDirection: textDirection,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    canvas.drawPath(getOuterPath(rect), side.toPaint());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlantBorder && other.side == side && other.slant == slant;

  @override
  int get hashCode => Object.hash(side, slant);
}
