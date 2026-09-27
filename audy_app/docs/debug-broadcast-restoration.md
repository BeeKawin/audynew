The debug broadcast controls have been restored on `working`. Open **Profile**, tap the **AUDY model/mascot**, then use **App Controls** to send a command to another running app instance.

**Branch and source**

- Edited branch: `working`, based on `0d0b4bc` (`Add AI`).
- Source branch: the locally available `origin/Kongnew2` reference at `94bb19c45e1aab7ffad422b915446be49c21c467`.
- Feature's introducing commit: `f4b540d09be239fa4fadd5f6be60640ff3fe5813`, **Save local work before syncing Kongnew**, July 22, 2026.
- That commit is also contained in `origin/Kongnew` (local reference `0104edfded8b1270eb7ab7be42b987745ec7d866`). Git records commit ancestry; this does not establish which branch name was checked out when the original author wrote it.
- The new control page, both services, and original tests at the source branch match the introducing commit. Restoration used that commit's feature diff, with the adaptations below.
- Changes are in the working tree. No new commit, branch merge, or push was made.

**How the feature works**

The profile mascot opens `/remote-control`. `RemoteControlPage._send` calls `RealtimeControlService.send`, which sends an HTTP broadcast through the existing Supabase client. Receiving instances subscribe to event `control` on channel `audy-interactive-controls-v1`. This retains the source protocol, including `id`, `action`, and `sent_at` in each payload.

`InteractiveInputService` combines remote commands with the existing Bluetooth input stream. Game screens use their existing handlers and accept inputs only while their route is current. This lets remote controls use the same actions as the robot.

| Control | Wire action | Receiver input |
| --- | --- | --- |
| Left ear | `left_ear` | `ears=1` |
| Right ear | `right_ear` | `ears=2` |
| Nose | `nose` | `nose=1` |
| Left arm | `left_arm` | `force=1` |
| Right arm | `right_arm` | `force=2` |
| Tummy | `tummy` | `tummy=1` |
| Correct mimic | `correct_mimic` | Display the target emotion in the standalone mimic screen |
| Incorrect mimic | `incorrect_mimic` | Display a different emotion in the standalone mimic screen |

The two mimic commands retain the original preview behavior: they do not generate an AI inference result or change the camera flow's score. The standalone `/games/emotion-mimic` route now opens `EmotionMimicScreen`, as in the source commit. The existing combined classification/selfie flow keeps its automatic capture behavior.

Both devices need the same Supabase project and an internet connection. The source channel is shared across listening instances; it has no per-child pairing or room code. “Sent” means the broadcast request was accepted, not that a receiver acknowledged performing the action. The broadcast transport follows the [Supabase Broadcast documentation](https://supabase.com/docs/guides/realtime/broadcast); compatibility was also checked against the installed `realtime_client` 2.7.3 implementation of `httpSend`.

**Changed files and sections**

Links below open the complete resulting files. Paths are relative to `audy_app`.

| File | Changed section / purpose |
| --- | --- |
| [lib/main.dart](../lib/main.dart) | Control page import/route; restore the standalone mimic route |
| [app_routes.dart](../lib/src/core/app_routes.dart) | Add `remoteControl` route constant |
| [app_strings.dart](../lib/src/core/app_strings.dart) | Add English/Thai control labels, status messages, and mimic preview labels |
| [profile_and_rewards_pages.dart](../lib/src/features/profile_and_rewards_pages.dart) | Make the profile mascot a labeled 144×144 control-page entry point |
| [remote_control_page.dart](../lib/src/features/remote_control/remote_control_page.dart) | New eight-button sender with pending, success, failure, and retry feedback |
| [realtime_control_service.dart](../lib/src/services/realtime_control_service.dart) | New protocol model, broadcast send/listen, and mimic emotion selection helper |
| [interactive_input_service.dart](../lib/src/services/interactive_input_service.dart) | New combined Bluetooth/remote input stream and subscription cleanup |
| [audy_controller.dart](../lib/src/state/audy_controller.dart) | Read-only `mimicEmotionPool` getter |
| [emotion_mimic_screen.dart](../lib/src/features/emotion_mimic_game/emotion_mimic_screen.dart) | Subscribe to correct/incorrect mimic commands and render the received preview |
| [selfie_capture_screen.dart](../lib/src/features/emotion_mimic_game/selfie_capture_screen.dart) | Subscribe through the combined input service |
| [emotion_classify_screen.dart](../lib/src/features/emotion_classify_game/emotion_classify_screen.dart) | Combined input subscription and current-route guard |
| [flashcard_screen.dart](../lib/src/features/flashcard/flashcard_screen.dart) | Combined input subscription; retain the existing route/difficulty guards |
| [fruit_catching_bear_screen.dart](../lib/src/features/fruit_catching_bear/fruit_catching_bear_screen.dart) | Combined input subscription and current-route guard |
| [reaction_game_screen.dart](../lib/src/features/reaction_game/reaction_game_screen.dart) | Combined input subscription and current-route guard |
| [read_pronounce_practice.dart](../lib/src/features/read_pronounce/read_pronounce_practice.dart) | Combined input subscription and current-route guard |
| [social_chat_page.dart](../lib/src/features/social_chat/social_chat_page.dart) | Combined input subscription and current-route guard |
| [realtime_control_service_test.dart](../test/realtime_control_service_test.dart) | Restored protocol tests; add HTTP success/failure and rapid resubscription coverage |
| [remote_control_page_test.dart](../test/remote_control_page_test.dart) | Restored sender test; add failure/retry, pending/disposal, and large-text layout coverage |

**Adaptations from the original**

- Merged the translations, flashcard input hookup, and fruit-catching input hookup into the current files to preserve existing local edits.
- Fixed the input adapter's cancellation race: it clears old subscription references before awaiting cancellation, so a newly opened screen can subscribe immediately.
- Kept the source controls and colors, with dark foreground icons for contrast, growing button heights for large text, untruncated labels, and a minimum-height back target.
- Extended the source tests to cover the adaptations. No new runtime dependency or backend/schema change was required.
- Compared tracked files against a snapshot taken before restoration; no unrelated tracked file was changed by this task.

**Verification**

- 20 checks passed: 10 broadcast/input service tests, 6 control-page tests, 1 existing flashcard test, and 3 existing emotion-round tests.
- Layout checks cover English and Thai at 320×640 with text scaled to 200%, including scrolling to and activating the last control and checking its touch-target size.
- The existing emotion-round test lacks SharedPreferences and audio-plugin mocks. Its unchanged assertions passed through a temporary harness with those mocks; running the original test file directly still has that pre-existing setup limitation.
- Full Flutter analysis: zero errors, three pre-existing unused-code warnings in `read_pronounce_practice.dart` (`_sttDebugStatus`, `_sttDebugText`, `_SttDebugPanel`). Focused analysis of the final new page/services/tests passed.
- `git diff --check` passed.
- HTTP delivery tests used a mock server response. Live cross-device delivery and physical Bluetooth hardware were not tested.
