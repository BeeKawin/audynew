# Achievement removal

Implemented on 27 October 2026 under the user's instruction to remove the entire feature without another approval step.

## Delivered behavior

- Removed the Achievements tab and its card list from Student Rewards. The remaining sections are Progress, My Rewards and Skins.
- Removed the achievement count from Student Profile. Points, games played and streak remain, using three columns on larger screens.
- Removed automatic unlock checks, achievement definitions/catalogs, callback state, unlock popups, the dedicated sound and its preload entry, and achievement-specific English/Thai strings. Removed the achievement-only fields from the old report/profile summary models.
- Removed all application reads/writes/synchronization for local and cloud achievement records. Signing in and completing games no longer read or attempt to upload achievement keys.
- Kept the existing game completion counters, points, level thresholds, level-up feedback, rewards/claims, skins, break protection, game history, analytical calculations and exports. The gameplay counters used by existing progress reports remain stored and updated.
- Caretaker guide elements, customization and previews were retained.
- During Rewards verification, fixed an existing Thai progress-text overflow by allowing the two progress labels to wrap. Their wording, values and calculations are unchanged.

## Data cleanup

The local Drift schema is now version **9**. New databases create only UserProgress, UserRewards, GameSessions and UserPreferences. Existing databases drop `user_achievements` followed by `achievements` inside the upgrade transaction. The generated database code was regenerated from the remaining table declarations. Other local records are preserved; the upgrade does not reset progress or history for version 8 users.

Supabase migration **20261027002309_remove_achievements.sql** removes `public.child_achievements`, including its owned indexes and policies. It uses `RESTRICT`, so an unexpected external dependency would stop deployment rather than delete another feature. Existing historical migration files remain unchanged to preserve migration history and reproducible setup; the final migration removes the feature when that history is replayed.

The cloud migration rehearsal ran inside a rolled-back transaction. It verified removal and unchanged row counts in all **10 other public tables**, plus the continuing presence of reward RLS and the roster RPC. The final migration was then applied to the linked AUDY project. Achievement records are intentionally removed; no other user data is targeted.

The local cleanup runs when each installation opens its database with this updated app. A new APK/device installation was not performed by this change.

## Verification

- Full Flutter suite: **109 tests passed**, no excluded test files.
- Fresh database: seeding is repeatable, progress/preferences are available and neither achievement table is created.
- Actual persisted version 8 → 9 upgrade: all fields in existing progress, preferences/owned skins, rewards and recorded sessions remain identical. Achievement tables disappear, foreign-key checks pass, and later seeding does not recreate them.
- Controller completion paths: Emotion classification/mimic, MiniPuzzle, Reading, FlashCard and Road Safety continue advancing the game/break counts. Social messages advance their counter. Rewards complete/claim, points increase and the existing level-up callback fires at the same threshold.
- English/Thai Rewards and Profile: achievement sections/counts are absent; remaining rewards and skins tabs open, and points/games/streak remain visible.
- Existing regression tests continue covering the other games, Caretaker customization/preview isolation, settings, account/logout behavior and break protection.
- Static analysis uses `dart analyze --no-fatal-warnings`; the Flutter analyzer wrapper stalled while starting its analysis server. Only the three pre-existing unused STT debug declarations in Read & Speak remain.
- `flutter build bundle --debug --no-pub`: passed. This checks Flutter compilation/assets, not Android/iOS installation or physical hardware.
- Cloud checks: the updated child portal RLS test and the existing Caretaker progress, configuration and break-setting authorization tests are run after migration inside rolled-back transactions.

Physical camera, microphone, audible playback and hardware operation are not established by mocked widget tests. The separately documented deployed FlashCard HTTP 404 issue was not changed by removing achievements.

## Affected files

| Area | Files / changes |
| --- | --- |
| Startup | `lib/main.dart`: remove achievement callback/toast registration |
| Student UI | `lib/src/features/profile_and_rewards_pages.dart`: remove tab, list and count; retain remaining navigation and wrap progress text |
| Runtime state | `lib/src/state/audy_controller.dart`: remove catalog/unlock state/checks/storage/cloud calls; preserve completion and reward work |
| Account service | `lib/src/services/auth_service.dart`: remove achievement fetch/upsert methods |
| Local storage | `database/database.dart`, regenerated `database.g.dart`, `datasources/local_data_source.dart`, `repositories/storage_repository.dart`: remove table registration, seeding and APIs; add schema 9 upgrade |
| Models | `progress_model.dart`, `parent_portal_model.dart`: remove achievement-only model definitions and summary fields |
| Assets/localization | `app_strings.dart`, `app_sounds.dart`, `sound_service.dart`: remove feature copy, sound constant/preload and playback helper |
| Tests | Add `test/achievement_removal_test.dart`; remove the obsolete catalog test and auth-service test override; update `supabase/tests/child_portal_rls_test.sql` |
| Migration | Add `supabase/migrations/20261027002309_remove_achievements.sql` |

Deleted files:

- `lib/src/widgets/achievement_toast.dart`
- `lib/src/data/database/tables/achievements.dart`
- `lib/src/data/database/tables/user_achievements.dart`
- `assets/sounds/achievement.mp3`

Full current contents of added/updated source files are included in `caretaker-source.md`. Existing unrelated working-tree edits were preserved.
