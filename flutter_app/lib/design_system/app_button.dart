import 'package:flutter/material.dart';
import '../core/theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : isPrimary = true;

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : isPrimary = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = onPressed == null || isLoading;

    if (isPrimary) {
      return FilledButton(
        onPressed: disabled ? null : onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: 14),
        ),
        child: _buildContent(theme),
      );
    }

    return OutlinedButton(
      onPressed: disabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: 14),
        side: BorderSide(
          color: disabled ? theme.disabledColor : theme.colorScheme.primary,
        ),
      ),
      child: _buildContent(theme),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            isPrimary ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppTheme.spacingSm),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}
