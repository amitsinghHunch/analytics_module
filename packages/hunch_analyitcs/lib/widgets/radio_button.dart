import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RadioButton extends StatefulWidget {
  const RadioButton({
    super.key,
    this.onPressed,
    this.label,
    this.labelStyle,
    this.borderRadius = 10.0,
    this.boxShadow = const [BoxShadow(offset: Offset(5, 5))],
    this.isDisabled,
    this.labelColor,
    this.child,
    this.isSelected,
    this.height = 42.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    required this.context,
  });
  final VoidCallback? onPressed;
  final String? label;
  final TextStyle? labelStyle;
  final Color? labelColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final List<BoxShadow> boxShadow;
  final double height;
  final ValueNotifier<bool>? isSelected;
  final ValueNotifier<bool>? isDisabled;
  final Widget? child;
  final BuildContext context;

  @override
  State<RadioButton> createState() => _RadioButtonState();
}

class _RadioButtonState extends State<RadioButton> {
  final Duration _duration = const Duration(milliseconds: 70);
  late bool _isDown = false;
  late List<BoxShadow> _boxShadow;
  late Color _bgColor = Theme.of(context).colorScheme.onSecondary;
  late Color _labelColor = const Color(0xFF383838);
  late Color _highlightColor = Theme.of(context).colorScheme.onSecondary;
  late MaterialColor _bgSwatch;

  @override
  void initState() {
    super.initState();
    setInit();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  setInit() {
    _bgColor = Theme.of(widget.context).colorScheme.onPrimaryContainer;
    _boxShadow = widget.boxShadow;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setBottonType(widget.context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isSelected ?? ValueNotifier(false),
      builder: (context, isSelected, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: widget.isDisabled ?? ValueNotifier(false),
          builder: (context, disabled, child) {
            return GestureDetector(
              onTap: isSelected || disabled ? null : _onTap,
              onTapDown: isSelected || disabled ? null : _onTapDown,
              onTapUp: isSelected || disabled ? null : _onTapUp,
              onTapCancel: _onTapCancel,
              child: Opacity(
                opacity: disabled ? 0.5 : 1,
                child: AnimatedContainer(
                  duration: _duration,
                  height: widget.height,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    color: _bgColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget.borderRadius),
                    ),
                    boxShadow: _boxShadow,
                  ),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      if (_isDown) ...[
                        Positioned.fill(
                          child: Shimmer.fromColors(
                            baseColor: _bgColor,
                            highlightColor: _highlightColor,
                            period: const Duration(milliseconds: 750),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _bgColor,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(widget.borderRadius),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      Container(
                        height: widget.height,
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: widget.padding,
                        child: widget.child ??
                            Text(
                              widget.label ?? "Button Text",
                              style: widget.labelStyle ??
                                  TextStyle(
                                    color: _labelColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onTap() {
    _onTapDown;
  }

  void _onTapDown(_) {
    setState(() {
      _boxShadow = const [BoxShadow(offset: Offset(2, 2))];
      _isDown = true;
      _bgColor = _bgSwatch.shade600;
    });
  }

  void _onTapUp(_) {
    widget.onPressed!();
    Future.delayed(
      _duration,
      () {
        _onTapCancel();
      },
    );
  }

  void _onTapCancel() {
    setState(() {
      _boxShadow = widget.boxShadow;
      _isDown = false;
      _bgColor = widget.isSelected!.value
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surface;
    });
  }

  setBottonType(BuildContext context) {
    if (widget.isSelected!.value) {
      _bgColor = Theme.of(context).colorScheme.primary;
      _labelColor = const Color(0xFF383838);
      _bgSwatch = getMaterialColor(_bgColor);
    } else {
      _bgColor = Theme.of(context).colorScheme.onPrimaryContainer;
      _labelColor = Theme.of(context).colorScheme.onSurface;
      _bgSwatch = getMaterialColor(_bgColor);
    }
    _highlightColor = Theme.of(context).colorScheme.surface.withOpacity(0.4);
    setState(() {});
  }
}

MaterialColor getMaterialColor(Color color) {
  return MaterialColor(color.value, {
    50: tintColor(color, 0.9),
    100: tintColor(color, 0.8),
    200: tintColor(color, 0.6),
    300: tintColor(color, 0.4),
    400: tintColor(color, 0.2),
    500: color,
    600: shadeColor(color, 0.1),
    700: shadeColor(color, 0.2),
    800: shadeColor(color, 0.3),
    900: shadeColor(color, 0.4),
  });
}

int tintValue(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

Color tintColor(Color color, double factor) => Color.fromRGBO(
    tintValue(color.red, factor),
    tintValue(color.green, factor),
    tintValue(color.blue, factor),
    1);
int shadeValue(int value, double factor) =>
    max(0, min(value - (value * factor).round(), 255));

Color shadeColor(Color color, double factor) => Color.fromRGBO(
    shadeValue(color.red, factor),
    shadeValue(color.green, factor),
    shadeValue(color.blue, factor),
    1);
