import 'package:flutter/material.dart';
import '../../core/theme/enterprise_theme.dart';

/// Enterprise-grade card component with consistent styling and animations
class EnterpriseCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final EnterpriseCardType type;
  final bool isElevated;
  final bool isGradient;
  final Gradient? customGradient;
  final Color? customColor;
  final double? customRadius;
  final List<BoxShadow>? customShadow;
  final Widget? header;
  final Widget? footer;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final bool isAnimated;

  const EnterpriseCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.type = EnterpriseCardType.standard,
    this.isElevated = false,
    this.isGradient = false,
    this.customGradient,
    this.customColor,
    this.customRadius,
    this.customShadow,
    this.header,
    this.footer,
    this.title,
    this.subtitle,
    this.trailing,
    this.isAnimated = true,
  }) : super(key: key);

  @override
  State<EnterpriseCard> createState() => _EnterpriseCardState();
}

class _EnterpriseCardState extends State<EnterpriseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isAnimated) {
      _animationController = AnimationController(
        duration: AppTheme.animationMedium,
        vsync: this,
      );
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 0.98,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    if (widget.isAnimated) {
      _animationController.dispose();
    }
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isAnimated && widget.onTap != null) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isAnimated && widget.onTap != null) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.isAnimated && widget.onTap != null) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardData = _getCardData();

    Widget cardContent = _buildCardContent(cardData);

    if (widget.isAnimated && widget.onTap != null) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: widget.onTap,
              child: cardContent,
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: cardContent,
    );
  }

  Widget _buildCardContent(_CardData cardData) {
    return Container(
      margin: widget.margin ?? EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: widget.isGradient ? null : cardData.backgroundColor,
        gradient: widget.isGradient
            ? (widget.customGradient ?? cardData.gradient)
            : null,
        borderRadius:
            BorderRadius.circular(widget.customRadius ?? cardData.borderRadius),
        border: cardData.borderColor != null
            ? Border.all(color: cardData.borderColor!, width: 1)
            : null,
        boxShadow: widget.customShadow ?? cardData.boxShadow,
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(widget.customRadius ?? cardData.borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.header != null) widget.header!,
            if (widget.title != null || widget.subtitle != null)
              _buildCardHeader(),
            Flexible(
              child: Container(
                padding: widget.padding ?? cardData.padding,
                child: widget.child,
              ),
            ),
            if (widget.footer != null) widget.footer!,
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null)
                  Text(
                    widget.title!,
                    style: AppTheme.titleLarge,
                  ),
                if (widget.subtitle != null) ...[
                  SizedBox(height: AppTheme.spacingXs),
                  Text(
                    widget.subtitle!,
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) widget.trailing!,
        ],
      ),
    );
  }

  _CardData _getCardData() {
    switch (widget.type) {
      case EnterpriseCardType.standard:
        return _CardData(
          backgroundColor: widget.customColor ?? AppTheme.surfaceLight,
          borderRadius: AppTheme.radiusLg,
          padding: EdgeInsets.all(AppTheme.spacingMd),
          boxShadow: widget.isElevated ? AppTheme.shadowMd : AppTheme.shadowSm,
        );

      case EnterpriseCardType.premium:
        return _CardData(
          backgroundColor: widget.customColor ?? AppTheme.surfaceLight,
          borderRadius: AppTheme.radiusXl,
          padding: EdgeInsets.all(AppTheme.spacingLg),
          boxShadow: AppTheme.shadowLg,
          gradient: AppTheme.primaryGradient,
        );

      case EnterpriseCardType.outlined:
        return _CardData(
          backgroundColor: widget.customColor ?? Colors.transparent,
          borderColor: AppTheme.borderColor,
          borderRadius: AppTheme.radiusLg,
          padding: EdgeInsets.all(AppTheme.spacingMd),
          boxShadow: [],
        );

      case EnterpriseCardType.elevated:
        return _CardData(
          backgroundColor: widget.customColor ?? AppTheme.surfaceLight,
          borderRadius: AppTheme.radiusXl,
          padding: EdgeInsets.all(AppTheme.spacingLg),
          boxShadow: AppTheme.shadowXl,
        );

      case EnterpriseCardType.minimal:
        return _CardData(
          backgroundColor: widget.customColor ?? AppTheme.surfaceMedium,
          borderRadius: AppTheme.radiusMd,
          padding: EdgeInsets.all(AppTheme.spacingSm),
          boxShadow: [],
        );

      case EnterpriseCardType.alert:
        return _CardData(
          backgroundColor:
              widget.customColor ?? AppTheme.errorRed.withValues(alpha: 0.1),
          borderColor: AppTheme.errorRed.withValues(alpha: 0.3),
          borderRadius: AppTheme.radiusLg,
          padding: EdgeInsets.all(AppTheme.spacingMd),
          boxShadow: [
            BoxShadow(
              color: AppTheme.errorRed.withValues(alpha: 0.1),
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        );

      case EnterpriseCardType.success:
        return _CardData(
          backgroundColor: widget.customColor ??
              AppTheme.successGreen.withValues(alpha: 0.1),
          borderColor: AppTheme.successGreen.withValues(alpha: 0.3),
          borderRadius: AppTheme.radiusLg,
          padding: EdgeInsets.all(AppTheme.spacingMd),
          boxShadow: [
            BoxShadow(
              color: AppTheme.successGreen.withValues(alpha: 0.1),
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        );

      case EnterpriseCardType.warning:
        return _CardData(
          backgroundColor: widget.customColor ??
              AppTheme.warningOrange.withValues(alpha: 0.1),
          borderColor: AppTheme.warningOrange.withValues(alpha: 0.3),
          borderRadius: AppTheme.radiusLg,
          padding: EdgeInsets.all(AppTheme.spacingMd),
          boxShadow: [
            BoxShadow(
              color: AppTheme.warningOrange.withValues(alpha: 0.1),
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        );
    }
  }
}

class _CardData {
  final Color backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsets padding;
  final List<BoxShadow> boxShadow;
  final Gradient? gradient;

  _CardData({
    required this.backgroundColor,
    this.borderColor,
    required this.borderRadius,
    required this.padding,
    required this.boxShadow,
    this.gradient,
  });
}

enum EnterpriseCardType {
  standard,
  premium,
  outlined,
  elevated,
  minimal,
  alert,
  success,
  warning,
}

/// Quick helper widgets for common card types
class EnterpriseInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final String? trend;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  const EnterpriseInfoCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.color,
    this.trend,
    this.isPositiveTrend = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? AppTheme.primaryBlue;

    return EnterpriseCard(
      type: EnterpriseCardType.elevated,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: EdgeInsets.all(AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppTheme.spacingMd),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.titleSmall,
                    ),
                    SizedBox(height: AppTheme.spacingXs),
                    Text(
                      value,
                      style: AppTheme.headingMedium.copyWith(
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (trend != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: (isPositiveTrend
                            ? AppTheme.successGreen
                            : AppTheme.errorRed)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositiveTrend
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 16,
                        color: isPositiveTrend
                            ? AppTheme.successGreen
                            : AppTheme.errorRed,
                      ),
                      SizedBox(width: AppTheme.spacingXs),
                      Text(
                        trend!,
                        style: AppTheme.labelMedium.copyWith(
                          color: isPositiveTrend
                              ? AppTheme.successGreen
                              : AppTheme.errorRed,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppTheme.spacingSm),
            Text(
              subtitle!,
              style: AppTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

/// Loading card component
class EnterpriseLoadingCard extends StatelessWidget {
  final double? height;
  final double? width;

  const EnterpriseLoadingCard({
    Key? key,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EnterpriseCard(
      type: EnterpriseCardType.standard,
      child: Container(
        height: height ?? 120,
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerLine(width: double.infinity, height: 20),
            SizedBox(height: AppTheme.spacingSm),
            _buildShimmerLine(width: 150, height: 16),
            SizedBox(height: AppTheme.spacingMd),
            _buildShimmerLine(width: double.infinity, height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
      ),
    );
  }
}
