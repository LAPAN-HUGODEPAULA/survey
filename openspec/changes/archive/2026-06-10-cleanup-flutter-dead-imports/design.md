## Context

The LAPAN Survey Platform's Flutter ecosystem has accumulated technical debt in the form of unused imports across all four client applications. This increases the complexity of the code and the noise during static analysis.

## Goals / Non-Goals

**Goals:**
- Eliminate all "unused_import" warnings/hints across the `apps/` directory.
- Achieve a clean `flutter analyze` state for all four apps.
- Verify that core functionalities (routing, state management, models) are unaffected.

**Non-Goals:**
- Refactoring generated files (e.g., `*.g.dart`, `*.freezed.dart`).
- Making architectural changes or updating package versions.
- Implementing new features.

## Decisions

- **Tool Selection**: Use `dart fix --apply` as the primary mechanism for removing unused imports. This tool is built into the Dart SDK and is designed specifically for safe automated code fixes.
- **Sequential Execution**: Process each application independently (one-by-one) to ensure that validation and testing are focused and manageable.
- **Manual Verification**: After automated fixes, a manual check of `pubspec.yaml` and critical library exports will be performed to ensure no intentional but "seemingly unused" imports (like those needed for certain build_runner triggers) were removed.

## Risks / Trade-offs

- **Risk**: Automated tools might remove imports that are only used in comments or by specific reflection-based tools not visible to static analysis.
  - **Mitigation**: Rely on the project's existing `flutter analyze` configuration and perform a smoke test of all applications after the cleanup.
- **Risk**: Conflict with generated code.
  - **Mitigation**: Exclude generated files from manual edits and verify that `build_runner` still works if needed.
