import 'package:flutter/material.dart';

enum DsButtonSize { small, medium, large }

Size _buttonSize(DsButtonSize size) {
  switch (size) {
    case DsButtonSize.small:
      return const Size(36, 36);
    case DsButtonSize.medium:
      return const Size(44, 44);
    case DsButtonSize.large:
      return const Size(52, 52);
  }
}

TextStyle _buttonTextStyle(BuildContext context, DsButtonSize size) {
  final base = Theme.of(context).textTheme.labelLarge ?? const TextStyle();
  switch (size) {
    case DsButtonSize.small:
      return base.copyWith(fontSize: 12, fontWeight: FontWeight.w600);
    case DsButtonSize.medium:
      return base.copyWith(fontSize: 14, fontWeight: FontWeight.w600);
    case DsButtonSize.large:
      return base.copyWith(fontSize: 16, fontWeight: FontWeight.w600);
  }
}

class DsFilledButton extends StatelessWidget {
  const DsFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.size = DsButtonSize.medium,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final DsButtonSize size;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final buttonSize = _buttonSize(size);
    final textStyle = _buttonTextStyle(context, size);
    final child = loading
        ? SizedBox(
            width: buttonSize.height * 0.5,
            height: buttonSize.height * 0.5,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label, style: textStyle);

    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      child: SizedBox(
        height: buttonSize.height,
        child: icon == null
            ? FilledButton(
                onPressed: loading ? null : onPressed,
                child: child,
              )
            : FilledButton.icon(
                onPressed: loading ? null : onPressed,
                icon: Icon(icon, size: textStyle.fontSize != null ? textStyle.fontSize! + 2 : 16),
                label: child,
              ),
      ),
    );
  }
}

class DsOutlinedButton extends StatelessWidget {
  const DsOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.size = DsButtonSize.medium,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final DsButtonSize size;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final buttonSize = _buttonSize(size);
    final textStyle = _buttonTextStyle(context, size);
    final child = loading
        ? SizedBox(
            width: buttonSize.height * 0.5,
            height: buttonSize.height * 0.5,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label, style: textStyle);

    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      child: SizedBox(
        height: buttonSize.height,
        child: icon == null
            ? OutlinedButton(
                onPressed: loading ? null : onPressed,
                child: child,
              )
            : OutlinedButton.icon(
                onPressed: loading ? null : onPressed,
                icon: Icon(icon, size: textStyle.fontSize != null ? textStyle.fontSize! + 2 : 16),
                label: child,
              ),
      ),
    );
  }
}

class DsTextButton extends StatelessWidget {
  const DsTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.size = DsButtonSize.medium,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final DsButtonSize size;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final buttonSize = _buttonSize(size);
    final textStyle = _buttonTextStyle(context, size);
    final child = loading
        ? SizedBox(
            width: buttonSize.height * 0.5,
            height: buttonSize.height * 0.5,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label, style: textStyle);

    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      child: SizedBox(
        height: buttonSize.height,
        child: icon == null
            ? TextButton(
                onPressed: loading ? null : onPressed,
                child: child,
              )
            : TextButton.icon(
                onPressed: loading ? null : onPressed,
                icon: Icon(icon, size: textStyle.fontSize != null ? textStyle.fontSize! + 2 : 16),
                label: child,
              ),
      ),
    );
  }
}
