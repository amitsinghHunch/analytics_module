import 'package:flutter/material.dart';
import 'package:hunch_analyitcs/widgets/radio_button.dart';
import 'package:shimmer/shimmer.dart';

enum ButtonType {
  primary,
  secondary,
  success,
  shareButton,
  messageButton,
  loginButton,
  whiteButton
}

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    this.onPressed,
    this.isLoading,
    this.label,
    this.labelStyle,
    this.isBlock = true,
    this.borderRadius = 10.0,
    this.boxShadow = const [BoxShadow(offset: Offset(5, 5))],
    this.isDisabled,
    this.loaderColor,
    this.buttonIndex = -1,
    this.loadButtonIndex,
    this.labelColor,
    this.buttonType = ButtonType.primary,
    this.child,
    this.borderColor = const Color(0xFF000000),
    this.tapDownBoxShadow = const [BoxShadow(offset: Offset(2, 2))],
    this.horizontalPadding = 16,
    this.disabledBgColor,
    this.bgColor,
    this.backgroundColor,
  });
  final VoidCallback? onPressed;
  final String? label;
  final Color? disabledBgColor;
  final TextStyle? labelStyle;
  final Color? labelColor;
  final bool isBlock;
  final double borderRadius;
  final Color borderColor;
  final ValueNotifier<bool>? isLoading;
  final List<BoxShadow> boxShadow;
  final List<BoxShadow> tapDownBoxShadow;
  final Color? loaderColor;
  final ValueNotifier<bool>? isDisabled;
  final int? buttonIndex;
  final ValueNotifier<int>? loadButtonIndex;
  final ButtonType buttonType;
  final Widget? child;
  final double horizontalPadding;
  final Color? bgColor;
  final Color? backgroundColor;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  final Duration _duration = const Duration(milliseconds: 70);
  late bool _isDown = false;
  late List<BoxShadow> _boxShadow;
  late Color _bgColor = Theme.of(context).colorScheme.primary;
  late Color _labelColor =
      widget.labelColor ?? Theme.of(context).colorScheme.onPrimary;
  late Color _highlightColor = Theme.of(context).colorScheme.onSecondary;
  late MaterialColor _bgSwatch;

  static const Color colorSecondary = Color(0xFF008E7E);
  static const Color messageBlue = Color(0xFF85CEDD);
  static const Color onPrimary = Color(0xFF383838);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color colorPrimaryNewDark = Color(0xFFF0B112);

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
    if (widget.buttonType == ButtonType.secondary) {
      _bgColor = Theme.of(context).colorScheme.onSecondary;
      _labelColor = Theme.of(context).colorScheme.onPrimary;
    } else if (widget.buttonType == ButtonType.success) {
      _bgColor = colorSecondary;
      _labelColor = Colors.white;
    } else if (widget.buttonType == ButtonType.shareButton) {
      _bgColor = onPrimary;
    } else if (widget.buttonType == ButtonType.messageButton) {
      _bgColor = messageBlue;
      _labelColor = onPrimary;
    } else if (widget.buttonType == ButtonType.loginButton) {
      _bgColor = Theme.of(context).colorScheme.onPrimaryContainer;
      _labelColor = Theme.of(context).colorScheme.onPrimary;
    } else if (widget.buttonType == ButtonType.whiteButton) {
      _bgColor = onSecondary;
      _labelColor = onPrimary;
    } else {
      _bgColor = colorPrimaryNewDark;
      _labelColor = onPrimary;
    }
    _boxShadow = widget.boxShadow;
    if (widget.bgColor != null) {
      _bgColor = widget.bgColor!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setBottonType(widget.buttonType, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // setInit();
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isLoading ?? ValueNotifier(false),
      builder: (context, loading, child) {
        return ValueListenableBuilder<bool>(
            valueListenable: widget.isDisabled ?? ValueNotifier(false),
            builder: (context, disabled, child) {
              return ValueListenableBuilder<int>(
                valueListenable: widget.loadButtonIndex ?? ValueNotifier(-1),
                builder: (context, btnLoaderIndex, child) {
                  return GestureDetector(
                    onTap: ((loading || disabled) &&
                            (widget.buttonIndex == btnLoaderIndex))
                        ? null
                        : _onTap,
                    onTapDown: ((loading || disabled) &&
                            (widget.buttonIndex == btnLoaderIndex))
                        ? null
                        : _onTapDown,
                    onTapUp: ((loading || disabled) &&
                            (widget.buttonIndex == btnLoaderIndex))
                        ? null
                        : _onTapUp,
                    onTapCancel: _onTapCancel,
                    child: Opacity(
                      opacity: ((loading || disabled) &&
                              (widget.buttonIndex == btnLoaderIndex))
                          ? 0.5
                          : 1,
                      child: AnimatedContainer(
                        duration: _duration,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: widget.borderColor,
                          ),
                          color: loading || disabled
                              ? widget.buttonIndex == btnLoaderIndex
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                  : widget.backgroundColor ?? _bgColor
                              : widget.backgroundColor ?? _bgColor,
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
                                  baseColor: loading || disabled
                                      ? Theme.of(context).colorScheme.surface
                                      : _bgColor,
                                  highlightColor: _highlightColor,
                                  period: const Duration(milliseconds: 750),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: loading || disabled
                                          ? Theme.of(context)
                                              .colorScheme
                                              .surface
                                          : _bgColor,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(widget.borderRadius),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            Container(
                              height: 50,
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  horizontal: widget.horizontalPadding),
                              child: (loading &&
                                      widget.buttonIndex == btnLoaderIndex)
                                  ? SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: FittedBox(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                              widget.loaderColor ??
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onSurface),
                                        ),
                                      ),
                                    )
                                  : widget.child ??
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
            });
      },
    );
  }

  void _onTap() {
    _onTapDown;
  }

  void _onTapDown(_) {
    setState(() {
      _boxShadow = widget.tapDownBoxShadow;
      _isDown = true;
      if (widget.buttonType == ButtonType.secondary) {
        _bgColor = _bgSwatch.shade600;
        _labelColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.9);
      } else if (widget.buttonType == ButtonType.success) {
        _bgColor = _bgSwatch.shade600;
        _labelColor = Theme.of(context).colorScheme.surface.withOpacity(0.9);
      } else if (widget.buttonType == ButtonType.shareButton) {
        _bgColor = _bgSwatch.shade600;
        _labelColor = Theme.of(context).colorScheme.surface.withOpacity(0.9);
      } else if (widget.buttonType == ButtonType.messageButton) {
        _bgColor = messageBlue;
        _labelColor = Theme.of(context).colorScheme.surface;
      } else if (widget.buttonType == ButtonType.loginButton) {
        _bgColor = Theme.of(context).colorScheme.onPrimaryContainer;
        _labelColor = Theme.of(context).colorScheme.onPrimary;
      } else {
        _bgColor = _bgSwatch.shade600;
        _labelColor = Theme.of(context).colorScheme.surface;
      }
      if (widget.bgColor != null) {
        _bgColor = widget.bgColor!;
      }
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
      if (widget.buttonType == ButtonType.secondary) {
        _bgColor = Theme.of(context).colorScheme.surface;
        _labelColor = Theme.of(context).colorScheme.onPrimary;
      } else if (widget.buttonType == ButtonType.success) {
        _bgColor = colorSecondary;
        _labelColor = Colors.white;
      } else if (widget.buttonType == ButtonType.shareButton) {
        _bgColor = Theme.of(context).colorScheme.onSurface;
      } else if (widget.buttonType == ButtonType.messageButton) {
        _bgColor = messageBlue;
        _labelColor = Theme.of(context).colorScheme.surface;
      } else if (widget.buttonType == ButtonType.loginButton) {
        _bgColor = Theme.of(context).colorScheme.onPrimaryContainer;
        _labelColor = Theme.of(context).colorScheme.onPrimary;
      } else {
        _bgColor = Theme.of(context).colorScheme.primary;
        _labelColor = Theme.of(context).colorScheme.onPrimary;
      }
      if (widget.bgColor != null) {
        _bgColor = widget.bgColor!;
      }
    });
  }

  setBottonType(ButtonType type, BuildContext context) {
    if (type == ButtonType.secondary) {
      _bgColor = Theme.of(context).colorScheme.surface;
      _highlightColor = Theme.of(context).colorScheme.surface;
      _labelColor = Theme.of(context).colorScheme.onPrimary;
    } else if (widget.buttonType == ButtonType.success) {
      _bgColor = colorSecondary;
      _labelColor = Colors.white;
      _highlightColor = Theme.of(context).colorScheme.surface;
    } else if (type == ButtonType.shareButton) {
      _bgColor = Theme.of(context).colorScheme.onSurface;
      _highlightColor = Theme.of(context).colorScheme.onSurface;
    } else if (type == ButtonType.messageButton) {
      _bgColor = messageBlue;
      _labelColor = Theme.of(context).colorScheme.surface;
    } else {
      _bgColor = Theme.of(context).colorScheme.primary;
      _labelColor = Theme.of(context).colorScheme.onPrimary;
      _highlightColor = Theme.of(context).colorScheme.surface.withOpacity(0.4);
    }
    _bgSwatch = getMaterialColor(_bgColor);
    if (widget.bgColor != null) {
      _bgColor = widget.bgColor!;
    }
  }
}
