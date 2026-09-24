import 'package:flutter/material.dart';

/// App-owned replacement for dsp_base's `AppModifier`/`Modifier` chain — the
/// same "compose a chain of widget wrappers, apply once" pattern, ported
/// directly rather than routed through `asc_common` (which has no equivalent
/// and this session has no push access to add one). Only the ~11 methods
/// this app actually calls are ported, not dsp_base's full vocabulary.
@immutable
class AppModifier {
  const AppModifier() : _ops = const [];
  const AppModifier._(this._ops);
  final List<Widget Function(Widget)> _ops;

  AppModifier then(Widget Function(Widget) op) =>
      AppModifier._([..._ops, op]);
  AppModifier operator +(AppModifier other) =>
      AppModifier._([..._ops, ...other._ops]);

  Widget apply(Widget child) =>
      _ops.reversed.fold<Widget>(child, (w, op) => op(w));

  bool get isEmpty => _ops.isEmpty;
}

// ignore: constant_identifier_names
const AppModifier Modifier = AppModifier();

extension ModifierApply on Widget {
  Widget apply(AppModifier modifier) => modifier.apply(this);
}

extension AppModifierOps on AppModifier {
  AppModifier conditional(
    bool condition, {
    required AppModifier Function(AppModifier) onTrue,
    AppModifier Function(AppModifier)? onFalse,
  }) {
    if (condition) return this + onTrue(Modifier);
    if (onFalse != null) return this + onFalse(Modifier);
    return this;
  }

  AppModifier paddingAll(double all) => padding(all: all);

  AppModifier paddingVertical(double vertical) => padding(vertical: vertical);

  AppModifier paddingHorizontal(double horizontal) =>
      padding(horizontal: horizontal);

  AppModifier paddingLR({double left = 0, double right = 0}) {
    final insets = EdgeInsets.fromLTRB(left, 0, right, 0);
    return then((c) => Padding(padding: insets, child: c));
  }

  AppModifier padding({
    double? all,
    double? horizontal,
    double? vertical,
    double start = 0,
    double top = 0,
    double end = 0,
    double bottom = 0,
  }) {
    final insets = all != null
        ? EdgeInsetsDirectional.all(all)
        : (horizontal != null || vertical != null)
        ? EdgeInsetsDirectional.symmetric(
            horizontal: horizontal ?? 0,
            vertical: vertical ?? 0,
          )
        : EdgeInsetsDirectional.only(
            start: start,
            top: top,
            end: end,
            bottom: bottom,
          );
    return then((c) => Padding(padding: insets, child: c));
  }

  /// Ink ripple over [c], without a `Material` ancestor requirement.
  AppModifier appClickable({
    VoidCallback? onTap,
    double radius = 8,
    BorderRadius? borderRadius,
    Color? splashColor,
    Color? highlightColor,
    bool enableFeedback = true,
  }) {
    return then(
      (c) => Stack(
        children: [
          c,
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                splashColor: splashColor,
                highlightColor: highlightColor,
                borderRadius: borderRadius ?? BorderRadius.circular(radius),
                enableFeedback: enableFeedback,
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppModifier background({
    required Color color,
    double radius = 0,
    BorderRadiusGeometry? borderRadius,
  }) {
    return then(
      (c) => DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius ?? BorderRadius.circular(radius),
        ),
        child: c,
      ),
    );
  }

  AppModifier border({
    required Color color,
    double width = 1,
    double radius = 0,
    BorderRadiusGeometry? borderRadius,
  }) {
    return then(
      (c) => DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(width: width, color: color),
          borderRadius: borderRadius ?? BorderRadius.circular(radius),
        ),
        child: c,
      ),
    );
  }

  AppModifier width(double width) =>
      then((c) => SizedBox(width: width, child: c));

  AppModifier height(double height) =>
      then((c) => SizedBox(height: height, child: c));

  AppModifier weight([int flex = 1]) =>
      then((c) => Expanded(flex: flex, child: c));

  AppModifier boxDecoration({
    Color? color,
    BorderRadius? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
  }) {
    return then(
      (c) => DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
          border: border,
          boxShadow: boxShadow,
          gradient: gradient,
        ),
        child: c,
      ),
    );
  }
}
