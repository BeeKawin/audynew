# Assignments & Rewards placeholder

Restored 30 October 2026 at the user's request.

- Caretaker Home's existing Assignments & Rewards entry opens a dedicated page
  using the existing background, panel, button styling and account guard.
- Assignments remain TBD. The Rewards section has an Add Rewards button that
  opens the legacy prize/activity/target-count form.
- That form is explicitly preview-only on this page. Its Create action stays
  disabled and marked TBD even after valid input. Cancel closes the form.
  Preview input is temporary; nothing is assigned to a child or persisted.
- `AddRewardDialog.previewOnly` defaults to false, preserving existing legacy
  callers and their `RewardDraft` results. The placeholder passes true and has
  no reward-saving callback or repository integration.
- Existing Caretaker guides, Student rewards, analytical content and other
  TBD sections retain their existing behavior.

Verification covers the actual Caretaker route, opening/editing/cancelling
the placeholder, disabled creation and unchanged rewards in English and Thai
at a narrow viewport with enlarged text. The existing legacy dialog check
also verifies that valid input still enables its normal Create action.

Complete affected files are included in `caretaker-source.md` under their
file paths.
