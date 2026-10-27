# Caretaker Phase 1 implementation

## Behavior

- Parent, Teacher, and new Caretaker accounts open the Caretaker home. Stored legacy roles are retained for their existing tools.
- The original Parent background, responsive page, white panels, rounded controls and AUDY palette are reused throughout Caretaker pages, editors and previews. Home uses the same AudyActionCard component as Student game selection.
- Bottom navigation is Home / Child Progress / Profile. Home cards are ordered Study Plan, Manual (Guide), Customization, Assignments & Rewards. All except Customization remain clearly marked TBD.
- Profile shows every linked child, including whether the child is in care, plus the selected/planned child count, Manage Children, Settings and Logout. Manage Children retains email linking, the count stepper/input, explicit care-list selection and unsaved-change protection. Inactive children open management before progress can be viewed.
- Child Progress selects a child from the active care list, then offers Level, Points & History or Analysis. Existing level thresholds and stored points/games/streak counters are retained. History shows the latest 200 recorded sessions; it does not imply every game emits telemetry. Achievements have since been removed application-wide; levels, points and history remain.
- All five games have persistent per-child settings, validation, draft previews, reset, and revision conflict handling.
- The old FlashCard word/text field, five word types, image picker, and teacher word-bank import are included in the per-child editor. Adjective/adverb cards remain available in the library, with a notice explaining that the existing sentence generator does not use them yet.
- Existing Parent/Teacher assignment and reward tools are accessible under Profile > Settings > Legacy Tools for legacy accounts. They retain their original linked child lists and write permissions. Compatibility routes remain available, with adult achievement tabs removed.
- Shared App Settings are available in Caretaker Profile and the existing Student Profile Settings tab: English/Thai, larger text (20% above the system scaler), app sound effects and original/plain app background. Values persist on this device across accounts and app restarts. Game-specific backgrounds and narration are independent. Student learning preferences remain separate, and editing them does not restart onboarding.
- Login debug choices are Student and Caretaker in every build mode, as requested. Student uses the original test@audy.com account; Caretaker uses caretaker@gmail.com with the supplied credential. Both use real authenticated sessions and validate the returned profile mode. Live sign-ins passed and verification sessions were signed out individually. No remote password or account data was changed.
- The five game configurations remain preview-only. The newly approved break threshold applies during Student play. Student tips panels and adult dashboard tabs have been removed; analytical calculations and exports remain unchanged.

## Data and deployment

- Applied migration `20261023165403_caretaker_customization.sql` to the linked AUDY project using the Supabase CLI migration workflow.
- Created `caretaker_children`, `caretaker_preferences`, and `child_game_configs`, with RLS and narrowly scoped RPCs.
- Backfilled seven legacy relationships with no missing legacy links. Preserved both original relationship columns and existing account IDs.
- Database integration fixtures ran inside rolled-back transactions; no fixture accounts or example game settings remain in the live database.
- New sign-ups use the existing profile trigger, which already accepts the new role. Existing role values were not rewritten.
- New relationship/configuration authorization uses stored profile roles; direct authenticated role changes are rejected.
- FlashCard pictures are bounded data URLs in the game payload; no storage bucket or new dependency was needed.
- Legacy relationships and analytical tables retain their original policies. Applied migration `20261024100102_caretaker_progress_read.sql`: the read-only `caretaker_child_progress` RPC authorizes active care-list members, returns stored stats, up to 200 existing sessions and existing assignments, and feeds the original Parent analytical widget through an optional snapshot. It adds no analytical calculations, writes, exports or policy changes. The definer function is private, with an authenticated invoker wrapper; Student, anonymous, unrelated and deselected-child requests are denied.

## Checks and limits

- Database rehearsal and post-deployment integration checks passed: linking, deduplication, care selection, persistence, shared saves, conflicts, role protection, and denial of unrelated/Student/anonymous access.
- Flutter debug asset/kernel bundle builds successfully. This is a compilation check, not an Android/iOS device installation.
- Focused tests cover configuration validation and immutability, the merged FlashCard controls, reset preserving cards, save conflicts, future schema versions, session changes, preview isolation, child-count behavior, and narrow English/Thai forms.
- The full Flutter suite now passes: 109 tests, with no excluded test files. See student-cleanup-verification.md for the feature-by-feature evidence. Coverage includes Home card order, profile overview, progress navigation, recorded counters, original Analysis widget reuse, narrow English/Thai layouts, settings persistence, per-child break behavior, remaining game logic, preview isolation, logout timing, both debug accounts and the restored inline FlashCard form.
- `supabase/tests/caretaker_progress_test.sql` passed against the linked project inside a rolled-back transaction, verifying active care-list authorization, the 200-session limit/order, unchanged stored counters/history, deselection, unrelated adult, Student and anonymous denial. No fixtures were retained.
- Static analysis has no new errors or warnings; three pre-existing unused STT debug declarations remain in Read & Speak. Sound-service native initialization is lazy so app settings remain usable when the audio engine cannot load; normal initialized playback behavior is retained.
- Updated the obsolete startup smoke test to initialize its mocked services and verify the current unauthenticated login flow, including Student/Caretaker debug choices. It is included in the passing full suite.
- Full-project analysis also reports three existing unused debug declarations in `read_pronounce_practice.dart`. New Caretaker code is checked separately.
- Security advisor findings concern existing public trigger/link functions and Auth settings; the new Caretaker functions did not produce exposed-definer warnings. Those unrelated existing functions/settings were not changed.
- Real-device camera, microphone, speech synthesis, and hardware operation have not been verified in this environment. Emotion preview intentionally shows only classification and the selfie target, without creating an inference result.

## Changed sections in existing files

| File | Changed section |
| --- | --- |
| `lib/main.dart` | Caretaker imports/routes, adult home/progress/profile dispatch and system-aware larger text |
| `lib/src/core/app_routes.dart` | Caretaker route constants |
| `lib/src/services/auth_service.dart` | `AppMode` and nonbreaking `UserProfile.mode` getter |
| `lib/src/features/auth/login_page.dart` | Registration choices; replace Parent/Teacher debug buttons with authenticated Caretaker shortcut |
| `lib/src/core/audy_ui.dart` | Shared original-style controls with 48/56 px minimum targets; optional device background preference |
| `lib/src/state/audy_controller.dart` | Load/save device app settings, persisted language and sound-effects binding |
| `lib/src/features/profile_and_rewards_pages.dart` | Student App Settings entry, separate existing learning preferences editor |
| `lib/src/features/parent/parent_child_progress_page.dart` | Share original level panel and rounded tab control; remove adult achievements tab; retain legacy reward tools |
| `lib/src/features/parent/parent_child_analytics.dart` | Optional authorized snapshot input; original analytical rendering/calculations retained |
| `lib/src/services/sound_service.dart` | Lazy native engine access and safe disposal when not initialized |
| `test/emotion_round_flow_test.dart` | Missing SharedPreferences/audio/TTS test mocks |

All files under `lib/src/features/caretaker`, the Caretaker repository/controller/configuration models, shared App Settings page/model, new tests, and migrations are additions. Earlier user changes elsewhere in the working tree were preserved.

Full contents of added/updated source files are provided in `caretaker-source.md`.

## Logout, debug login and legacy FlashCard restoration

- Caretaker Logout now clears local account state and navigates to Login immediately, removing the protected route stack while remote sign-out finishes. Login temporarily disables sign-in actions until sign-out completes. The shared shell returns Login for an absent account, and authentication revisions prevent delayed profile reads from undoing logout. Auth subscriptions are canceled when the controller is disposed.
- Restored the legacy Teacher `_buildWordBankCard` layout inside the per-child FlashCard editor: inline Word / Text, Word Type, Add Card Image, blue Add button and wrapping category-colored library chips. The card form is displayed first. Chip editing/deletion, image bounds, legacy Teacher import, explicit per-child Save, revisions and reset preserving cards remain supported.
- An unfinished inline card participates in unsaved-change protection and must be added/updated or cleared before Save/Preview. Editing a different chip asks before replacing unfinished form content.
- No game configuration schema, database table, migration or Student FlashCard behavior was changed. Existing Caretaker guide controls and other game previews were retained.
- `docs/flashcard-legacy-restoration.md` provides the full workflow, comparison with the former teacher-scoped bank, settings and actual backend grammar limitations.
- Added `test/auth_navigation_test.dart`; expanded `test/caretaker_editor_test.dart` and `test/widget_test.dart`. Full file contents remain available in `docs/caretaker-source.md`.

## Approved Student cleanup and break customization

- Removed Student GameGuideBox panels and their screen-specific layout/state plumbing from Emotion classification/mimic, FlashCard, all MiniPuzzle activities, Fruit Catch, Read & Speak and Road Safety. Task prompts, feedback, FlashCard placement hints and audio instructions remain. Social Chat had no such tips panel.
- Preserved all Caretaker guide/instruction switches, game-configuration defaults and preview guide code. Snapshot comparison verified exact preservation; MiniPuzzle preview has only the required renamed widget import.
- Student Profile now contains Profile and Settings. Student-only Parent Dashboard and Institution Panel content and their unused private widgets were deleted. Legacy adult pages and analytical widgets remain.
- Retired the standalone Sorting and Reaction screens/engines/models/routes, exclusive image/audio assets and dead guide translations. Renamed the live MiniPuzzle Odd One Out widget from sorting_game_widget.dart to odd_one_out_game_widget.dart, updating both Student and Caretaker imports.
- Removed retired game options from new assignments and reward creation, and excluded unfinished retired rewards from active reward slots. Stored enum names/order, old reward records, earned rewards, historical labels, analytical contributions and legacy progress fields remain compatible. Old assignments are excluded from Student playable tasks instead of being incorrectly relabeled as Emotion assignments.
- Added per-child Break / Meltdown Protection under Customization. Integer threshold 1-20, default 5, explicit save/reset, validation, unsaved-change protection, conflict handling and a local counter simulation. The fixed five-minute break UI/duration is retained.
- Applied migration 20261024102706_child_break_settings.sql. The child_break_settings table uses RLS; only linked Caretakers can read its metadata and only active care-list adults can save via a revision-checked RPC. Students receive only their own threshold/version/revision through student_break_settings and cannot write it. No changes were made to the game-settings schema.
- Student thresholds refresh on login, game selection and completion checks. Three-second network timeout falls back to that child's cached threshold or 5. Cache keys include child identity, stale responses are ignored and repeated navigation taps cannot create duplicate break pages. Changes apply at the next check, not mid-game.
- Session counts are now cached per child. An unowned legacy device-wide session counter is not copied into a child's cache: a child's first use starts a fresh session count. Historical game totals, points and stored records are retained. Existing dashboard count reset behavior is unchanged.
- Regression checks found and fixed Read & Speak accessing inherited app state during initState, and Road Safety's positioned scene receiving unbounded height inside a scroll view. Both screens now open and dispose successfully in widget tests.
- Existing analytical cooldown estimates are intentionally unchanged; their legacy sessions/5 calculation is not an audit of actual configured break events.

### Additional changed sections

| File/area | Change |
| --- | --- |
| Student game screens | Remove tips panel usage and unused header parameters/state |
| profile_and_rewards_pages.dart | Remove Student adult-dashboard tabs/private content |
| state/audy_controller.dart | Remove retired gameplay state, retain legacy decoding/report fields, bind per-child break settings |
| features/assignments_page.dart | Remove retired options; exclude retired stored tasks from playable Student assignments |
| teacher/teacher_dashboard.dart | Remove retired assignment creation options; preserve historical display mappings |
| widgets/add_reward_dialog.dart | Filter retired conditions from creation without reordering stored enum IDs |
| core/app_routes.dart and feature_pages.dart | Remove old routes, refresh break threshold, guard duplicate navigation |
| features/dashboard_page.dart | Display the current child's configured break threshold |
| core/app_sounds.dart, services/sound_service.dart, pubspec.yaml | Remove exclusive retired assets and audio preload references |
| features/minipuzzle_game/games/odd_one_out_game_widget.dart | Rename only; game behavior retained |
| features/read_pronounce/read_pronounce_practice.dart | Initialize inherited-state-dependent session in didChangeDependencies |
| features/road_safety/road_safety_widgets.dart | Give the positioned road scene its intended finite height |
| New break model/repository/state/editor | Persistence, permissions, offline cache, live gating and isolated Caretaker testing |
| Test files and SQL fixtures | Full startup, gameplay, previews, retirement, account isolation and database regression checks |

## Achievement removal (27 October 2026)

- Removed the feature throughout Student UI, runtime unlock logic, notifications/sounds, local storage, cloud syncing and obsolete summary models.
- Local schema 9 removes the two achievement tables while preserving existing progress, preferences, owned skins, rewards and session history. Supabase migration 20261027002309_remove_achievements.sql removes only child_achievements.
- Rewards, levels, points, break protection, analytical calculations and Caretaker guide elements remain functional. A Thai Rewards progress-label overflow found in regression testing was fixed by allowing wrapping.
- The full suite now passes 109 tests. See achievement-removal.md for the exact changed/deleted files, data cleanup and verification evidence. Full current source remains available in caretaker-source.md.
