import 'package:flutter/material.dart';
import 'package:design_system_flutter/widgets/ds_buttons.dart';

class DsTaskButton extends StatelessWidget {
  const DsTaskButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.size = DsTaskButtonSize.medium,
    this.emotion = DsEmotion.neutral,
    this.isLoading = false,
    this.progress = 0.0,
    this.showChevron = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final DsTaskButtonSize size;
  final DsEmotion emotion;
  final bool isLoading;
  final double progress;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (size) {
      case DsTaskButtonSize.large:
        return _buildLargeButton(context, theme);
      case DsTaskButtonSize.medium:
        return _buildMediumButton(context, theme);
      case DsTaskButtonSize.small:
        return _buildSmallButton(context, theme);
    }
  }

  Widget _buildLargeButton(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _getBackgroundColor(theme),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(theme),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 32,
            color: _getIconColor(theme),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: _getTextColor(theme),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (showChevron)
            Icon(
              Icons.chevron_right,
              color: _getTextColor(theme),
            ),
        ],
      ),
    );
  }

  Widget _buildMediumButton(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _getBackgroundColor(theme),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBorderColor(theme),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: _getIconColor(theme),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _getTextColor(theme),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress,
                  valueColor: AlwaysStoppedAnimation<Color>(_getIconColor(theme)),
                ),
              )
            else if (showChevron)
              Icon(
                Icons.chevron_right,
                color: _getTextColor(theme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallButton(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: _getTextColor(theme),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (isLoading) {
      return theme.colorScheme.surfaceVariant;
    }

    switch (emotion) {
      case DsEmotion.delight:
        return theme.colorScheme.primaryContainer.withOpacity(0.1);
      case DsEmotion.urgent:
        return theme.colorScheme.errorContainer.withOpacity(0.1);
      case DsEmotion.warning:
        return theme.colorScheme.outlineVariant.withOpacity(0.1);
      case DsEmotion.neutral:
      default:
        return theme.colorScheme.surface;
    }
  }

  Color _getBorderColor(ThemeData theme) {
    if (isLoading) {
      return theme.colorScheme.outline.withOpacity(0.2);
    }

    switch (emotion) {
      case DsEmotion.delight:
        return theme.colorScheme.primary;
      case DsEmotion.urgent:
        return theme.colorScheme.error;
      case DsEmotion.warning:
        return theme.colorScheme.outline;
      case DsEmotion.neutral:
      default:
        return theme.colorScheme.outline.withOpacity(0.2);
    }
  }

  Color _getIconColor(ThemeData theme) {
    if (isLoading) {
      return theme.colorScheme.onSurfaceVariant;
    }

    switch (emotion) {
      case DsEmotion.delight:
        return theme.colorScheme.primary;
      case DsEmotion.urgent:
        return theme.colorScheme.onError;
      case DsEmotion.warning:
        return theme.colorScheme.onSurfaceVariant;
      case DsEmotion.neutral:
      default:
        return theme.colorScheme.onSurface;
    }
  }

  Color _getTextColor(ThemeData theme) {
    if (isLoading) {
      return theme.colorScheme.onSurfaceVariant;
    }

    switch (emotion) {
      case DsEmotion.delight:
        return theme.colorScheme.onPrimaryContainer;
      case DsEmotion.urgent:
        return theme.colorScheme.onError;
      case DsEmotion.warning:
        return theme.colorScheme.onSurfaceVariant;
      case DsEmotion.neutral:
      default:
        return theme.colorScheme.onSurface;
    }
  }
}

enum DsTaskButtonSize {
  large,  // Icon + Label + Description (dashboard)
  medium, // Icon + Label (sidebar)
  small,  // Label only (mobile bottom nav)
}

enum DsEmotion {
  neutral,
  delight,  // Success, positive actions
  urgent,   // Error, critical actions
  warning,  // Caution, attention needed
}