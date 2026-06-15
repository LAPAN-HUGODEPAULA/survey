# Survey Skylos OpenSpec Triage Bundle

This bundle contains:

- `triage-model.md`: categorical triage model, confidence policy, exclusions, and ranked backlog.
- `proposal-ranking.csv`: machine-readable ranking summary.
- `openspec/changes/*`: OpenSpec-style change proposals generated from the Skylos report.

Suggested usage:

1. Copy the selected `openspec/changes/<change-id>` directory into the repository.
2. Review and edit the proposal/design/spec/tasks before implementation.
3. Run `openspec validate <change-id> --strict` if OpenSpec is installed.
4. Implement one change at a time.

Do not implement all proposals in one PR. The ranking is designed for sequencing.
