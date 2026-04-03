## Flutter Theme Audit

- All four Flutter applications were bootstrapping `MaterialApp` with `AppTheme.light()`.
- `packages/design_system_flutter/lib/theme/app_theme.dart` was still seeded from `Colors.orange` and exposed only a light palette.
- `packages/design_system_flutter/lib/theme/color_palette.dart` still used a legacy `greenToRed` scale that did not match the LAPAN amber-on-charcoal specification.
- Shared shell primitives still defaulted to raw `AppBar` composition in `DsScaffold`.
- Shared components and app screens still contain raw `AppBar`, `Card`, `Colors.orange`, and app-local `AsyncScaffold` wrappers that need migration in later tasks.
