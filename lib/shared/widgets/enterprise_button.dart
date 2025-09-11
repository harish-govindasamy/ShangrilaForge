import 'package:flutter/material.dart';
import '../../core/theme/enterprise_theme.dart';

/// Enterprise-grade button component with consistent styling and animations
class EnterpriseButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final EnterpriseButtonType type;
  final EnterpriseButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final Color? customColor;
  final double? elevation;

  const EnterpriseButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = EnterpriseButtonType.primary,
    this.size = EnterpriseButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.customColor,
    this.elevation,
  }) : super(key: key);

  @override
  State<EnterpriseButton> createState() => _EnterpriseButtonState();
}

class _EnterpriseButtonState extends State<EnterpriseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onPressed != null ? _onTapDown : null,
            onTapUp: widget.onPressed != null ? _onTapUp : null,
            onTapCancel: widget.onPressed != null ? _onTapCancel : null,
            child: _buildButton(),
          ),
        );
      },
    );
  }

  Widget _buildButton() {
    final buttonData = _getButtonData();

    Widget buttonChild = widget.isLoading
        ? SizedBox(
            width: buttonData.height * 0.6,
            height: buttonData.height * 0.6,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                buttonData.foregroundColor,
              ),
            ),
          )
        : Row(
            mainAxisSize:
                widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: buttonData.iconSize,
                  color: buttonData.foregroundColor,
                ),
                SizedBox(width: AppTheme.spacingSm),
              ],
              Text(
                widget.text,
                style: buttonData.textStyle.copyWith(
                  color: buttonData.foregroundColor,
                ),
              ),
            ],
          );

    return Container(
      width: widget.isExpanded ? double.infinity : null,
      height: buttonData.height,
      decoration: BoxDecoration(
        gradient: buttonData.gradient,
        color: buttonData.gradient == null ? buttonData.backgroundColor : null,
        borderRadius: BorderRadius.circular(buttonData.borderRadius),
        border: buttonData.borderColor != null
            ? Border.all(color: buttonData.borderColor!, width: 1)
            : null,
        boxShadow: widget.elevation != null || buttonData.elevation > 0
            ? [
                BoxShadow(
                  color: buttonData.backgroundColor.withValues(alpha: 0.3),
                  offset: Offset(0, widget.elevation ?? buttonData.elevation),
                  blurRadius: (widget.elevation ?? buttonData.elevation) * 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(buttonData.borderRadius),
          splashColor: buttonData.foregroundColor.withValues(alpha: 0.1),
          highlightColor: buttonData.foregroundColor.withValues(alpha: 0.05),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: buttonData.horizontalPadding,
              vertical: buttonData.verticalPadding,
            ),
            child: Center(child: buttonChild),
          ),
        ),
      ),
    );
  }

  _ButtonData _getButtonData() {
    switch (widget.type) {
      case EnterpriseButtonType.primary:
        return _ButtonData(
          backgroundColor: widget.customColor ?? AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          gradient:
              widget.customColor == null ? AppTheme.primaryGradient : null,
          elevation: 2,
          borderRadius: _getBorderRadius(),
          horizontalPadding: _getHorizontalPadding(),
          verticalPadding: _getVerticalPadding(),
          height: _getHeight(),
          textStyle: _getTextStyle(),
          iconSize: _getIconSize(),
        );

      case EnterpriseButtonType.secondary:
        return _ButtonData(
          backgroundColor: widget.customColor ?? AppTheme.secondaryBlue,
          foregroundColor: Colors.white,
          gradient:
              widget.customColor == null ? AppTheme.secondaryGradient : null,
          elevation: 1,
          borderRadius: _getBorderRadius(),
          horizontalPadding: _getHorizontalPadding(),
          verticalPadding: _getVerticalPadding(),
          height: _getHeight(),
          textStyle: _getTextStyle(),
          iconSize: _getIconSize(),
        );

      case EnterpriseButtonType.outline:
        final color = widget.customColor ?? AppTheme.primaryBlue;
        return _ButtonData(
          backgroundColor: Colors.transparent,
          foregroundColor: color,
          borderColor: color,
          elevation: 0,
          borderRadius: _getBorderRadius(),
          horizontalPadding: _getHorizontalPadding(),
          verticalPadding: _getVerticalPadding(),
          height: _getHeight(),
          textStyle: _getTextStyle(),
          iconSize: _getIconSize(),
        );

      case EnterpriseButtonType.ghost:
        final color = widget.customColor ?? AppTheme.primaryBlue;
        return _ButtonData(
          backgroundColor: Colors.transparent,
          foregroundColor: color,
          elevation: 0,
          borderRadius: _getBorderRadius(),
          horizontalPadding: _getHorizontalPadding(),
          verticalPadding: _getVerticalPadding(),
          height: _getHeight(),
          textStyle: _getTextStyle(),
          iconSize: _getIconSize(),
        );

      case EnterpriseButtonType.danger:
        return _ButtonData(
          backgroundColor: AppTheme.errorRed,
          foregroundColor: Colors.white,
          elevation: 1,
          borderRadius: _getBorderRadius(),
          horizontalPadding: _getHorizontalPadding(),
          verticalPadding: _getVerticalPadding(),
          height: _getHeight(),
          textStyle: _getTextStyle(),
          iconSize: _getIconSize(),
        );

      case EnterpriseButtonType.success:
        return _ButtonData(
          backgroundColor: AppTheme.successGreen,
          foregroundColor: Colors.white,
          elevation: 1,
          borderRadius: _getBorderRadius(),
          horizontalPadding: _getHorizontalPadding(),
          verticalPadding: _getVerticalPadding(),
          height: _getHeight(),
          textStyle: _getTextStyle(),
          iconSize: _getIconSize(),
        );
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case EnterpriseButtonSize.small:
        return AppTheme.radiusSm;
      case EnterpriseButtonSize.medium:
        return AppTheme.radiusMd;
      case EnterpriseButtonSize.large:
        return AppTheme.radiusLg;
    }
  }

  double _getHorizontalPadding() {
    switch (widget.size) {
      case EnterpriseButtonSize.small:
        return AppTheme.spacingMd;
      case EnterpriseButtonSize.medium:
        return AppTheme.spacingLg;
      case EnterpriseButtonSize.large:
        return AppTheme.spacingXl;
    }
  }

  double _getVerticalPadding() {
    switch (widget.size) {
      case EnterpriseButtonSize.small:
        return AppTheme.spacingSm;
      case EnterpriseButtonSize.medium:
        return AppTheme.spacingMd;
      case EnterpriseButtonSize.large:
        return AppTheme.spacingLg;
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case EnterpriseButtonSize.small:
        return 36;
      case EnterpriseButtonSize.medium:
        return 44;
      case EnterpriseButtonSize.large:
        return 52;
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case EnterpriseButtonSize.small:
        return AppTheme.labelMedium;
      case EnterpriseButtonSize.medium:
        return AppTheme.labelLarge;
      case EnterpriseButtonSize.large:
        return AppTheme.titleMedium;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case EnterpriseButtonSize.small:
        return 16;
      case EnterpriseButtonSize.medium:
        return 20;
      case EnterpriseButtonSize.large:
        return 24;
    }
  }
}

class _ButtonData {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final Gradient? gradient;
  final double elevation;
  final double borderRadius;
  final double horizontalPadding;
  final double verticalPadding;
  final double height;
  final TextStyle textStyle;
  final double iconSize;

  _ButtonData({
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    this.gradient,
    required this.elevation,
    required this.borderRadius,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.height,
    required this.textStyle,
    required this.iconSize,
  });
}

enum EnterpriseButtonType {
  primary,
  secondary,
  outline,
  ghost,
  danger,
  success,
}

enum EnterpriseButtonSize {
  small,
  medium,
  large,
}
