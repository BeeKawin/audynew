# Student cleanup and break customization verification

Last verified on 27 October 2026; the original Student cleanup was implemented on 24 October 2026. The changes were implemented with the approved correction: only Student tips were removed. Caretaker guide controls, defaults and preview instructions were retained.

## Results

- Full Flutter suite: **109 tests passed**, with no exclusions, including the subsequent logout/debug/legacy FlashCard corrections and full achievement removal.
- Debug asset/kernel bundle: **build passed** (`flutter build bundle --debug --no-pub`). This is not an APK installation or device test.
- Static analysis: no errors or new warnings. Three pre-existing unused STT debug declarations remain in `read_pronounce_practice.dart`.
- Whitespace checks passed. Existing CRLF conversion notices are Git configuration notices.
- Live Supabase Caretaker sign-in, stored role and authorized roster access passed using the supplied credential. The verification session was signed out. Credentials/tokens were not printed, and no account password was changed.
- Break settings migration `20261024102706_child_break_settings.sql` was applied to the linked AUDY project.
- Break settings, Caretaker configuration and child-progress SQL integration checks passed in rolled-back transactions. No test accounts/settings were retained.

## Feature checks

| Feature | Verification and outcome |
| --- | --- |
| App startup/login | Startup smoke test initializes mocked services and verifies the unauthenticated login screen, Student/Caretaker debug choices, and absence of Parent/Teacher debug choices. Real Caretaker authentication and roster access also passed. |
| Caretaker Home/Profile/Child Progress | Existing Home card order, child overview, child selection, level/points/history and original Analysis widget tests pass. Shared analytical widgets/calculations and the progress adapter match the pre-change source snapshot. |
| Multiple children | Existing count/selection tests and SQL linking/deduplication/permission checks pass. Break thresholds and session counts have separate account-scoped cache keys and stale-response protection. |
| Five game customization editors | Default/validation/serialization tests, per-child saves, FlashCard legacy controls, reset preserving custom cards, conflicts, future versions and narrow English/Thai forms pass. |
| Caretaker guides | Snapshot comparison confirms the configuration model, guide switches and all five preview guide implementations were preserved. MiniPuzzle preview changes only its renamed Odd One Out import. |
| Caretaker game previews | All five preview screens are covered by widget checks. Emotion/Social isolation tests and FlashCard/MiniPuzzle/Fruit startup/disposal tests pass; MiniPuzzle preview starts successfully. No preview changes Student counters/points. Live network services and physical hardware remain separate checks. |
| Break customization | Integer range 1-20, default 5, validation, save/reset, conflict retention, per-child persistence and isolated local simulation pass. Database checks reject invalid thresholds, stale saves, unrelated adults, inactive care-list writes, Student writes and anonymous access. |
| Student break behavior | Account-scoped restart/offline caches, stale responses and count restoration races pass. Game-entry/completion checks refresh the threshold and prevent duplicate navigation. Actual controller completion counts trigger the configured threshold and reset after a break. The existing countdown starts at 05:00 and enables its return action after completion. |
| Emotion classification | Student screen opens without tips; selecting the matching answer produces feedback. Existing combined emotion round/progression tests pass. Camera/model accuracy is not asserted by widget tests. |
| Emotion mimic | Student screen opens/disposes without tips; combined emotion progression and existing remote-control event tests pass. Physical expression capture/inference still requires device testing. |
| FlashCard | Student screen opens/disposes without tips. Three-round play/validation completes at easy, medium and hard levels using a deterministic API test double. Existing reset behavior passes. Actual local Python backend generation/validation also passed for English/Thai and 3/5-card rounds using isolated temporary verification dependencies. |
| MiniPuzzle | Pattern, Odd One Out and Puzzle open/dispose without tips. All nine activity/difficulty combinations complete three rounds with expected points/stars. The current Odd One Out widget was renamed, not deleted. |
| Fruit Catch | Student screen opens/disposes without tips; tapping the opposite lane moves the bear. Preview isolation/startup checks pass. Game rules/high-score behavior were not changed. |
| Read & Speak | Student screen opens/disposes without tips after correcting inherited-state initialization timing. Letters/words/sentences validate answers and complete their four-round sessions in controller tests. Physical microphone/STT remains a device check. |
| Road Safety | Student screen opens/disposes without tips after bounding the positioned road scene's height. Existing correct/wrong-action controller tests pass. Essential crossing prompts/feedback remain. |
| Social Chat | Student screen opens/disposes without a tips panel. Existing preview text-input/isolation tests pass. Live conversation generation is not established by these mocked tests. |
| Student Profile/Settings | Only Profile and Settings remain; shared app settings and separate learning preferences remain accessible. Device-local persistence, language and separation from learning preferences pass. |
| Assignments | Current options exclude retired games. A fixture containing old Sorting/Reaction tasks confirms they are excluded from playable Student tasks rather than incorrectly mapped to Emotion. Existing stored rows and analytical history are retained. |
| Rewards and skins | New reward choices exclude retired games. Old enum identifiers/order and stored rewards remain readable; unfinished retired rewards do not consume current slots. Earned/completed history is retained. Achievements have been removed entirely. Existing rewards, claims, skins and level progression continue to pass regression checks. |
| Remote controls | Existing parsing, mapping, request, duplicate-send, failure, disposal and narrow English/Thai layout tests pass. Physical robot operation is not claimed. |
| Study Plan, Manual and new Assignments & Rewards | Remain the approved TBD placeholders. Their functionality was not added or removed. |

## External-service and device limits

The app's configured live AI backend is `https://audynew-production.up.railway.app`. Checks of `/api/health`, `/api/flashcard/health`, `/api/emotion/health` and `/api/tts/health` returned HTTP 404. The repository defines those health endpoints, so the deployed backend needs investigation. These checks do not establish successful live Chat, FlashCard or remote speech synthesis. No backend deployment/configuration was changed as part of this task.

Camera capture, on-device emotion inference, physical microphone/STT, audible playback, Bluetooth/robot commands and Android/iOS installation require real-device checks. The widget tests mock platform channels; they verify application state/UI behavior without claiming physical-device operation.

## Compatibility decisions

- Retired standalone game directories, routes and exclusive image/audio assets are removed. Active Student tips references are removed from every affected screen.
- Historical analytical records, exports, reward IDs and legacy local database fields are retained. No destructive user-data migration was run.
- The old unowned device-wide break counter is not attributed to an arbitrary child. The first use of a child without a new account-specific cache starts a fresh session counter; existing learning points and recorded game totals are preserved.
- The legacy analytical cooldown estimate remains `sessions / 5`; analytics calculations were deliberately not changed. It is not a log of actual configured break events.
- The five existing game settings remain Caretaker-preview-only. The new break threshold is the specific setting applied to Student gameplay.

Complete current source files are included in `caretaker-source.md`; changed sections are documented in `caretaker-implementation.md`.

## Subsequent logout and FlashCard recheck

- Caretaker Logout opens the named Login route before a deliberately delayed remote sign-out completes; local account state is cleared and Back cannot reopen the protected screen. Login actions remain disabled until the prior sign-out finishes. A delayed profile read cannot restore the logged-out account, and unauthenticated Profile navigation renders Login instead of Student Profile.
- Both debug buttons authenticate with the specified real account credentials and reject unexpected roles or failed sign-ins. Student no longer falls back to an invented signed-in profile. Both actual Supabase sign-ins and stored roles were verified; the Student UUID matches the original account. Verification sessions were signed out individually.
- Legacy inline FlashCard controls load saved cards, add cards to the selected child's draft, preserve IDs while editing, remove cards, reject duplicates, protect unfinished form content and retain the library when resetting preview controls. English/Thai library layouts include long words, pictures and doubled text; edit/delete touch targets are at least 48 pixels.
- The restored UI reuses the existing configuration JSON and persistence; no additional database changes were required. The remaining features continue to have the feature-matrix coverage above. Caretaker guide elements were not removed or redesigned.
- A direct POST to the configured deployed `/api/flashcard/round` endpoint also returned HTTP 404. Successful deployed sentence generation is therefore not claimed. See `flashcard-legacy-restoration.md` for the unchanged generator's category and object-pool limitations.

## Subsequent complete achievement removal

On 27 October 2026, all achievement UI, unlock checks, popups, dedicated sound, localization, catalogs, storage APIs and cloud synchronization were removed. Local schema 9 drops the old achievement tables; a version 8 upgrade test confirms identical retained progress, preferences/skins, rewards and sessions. The Supabase cleanup removes only child_achievements. The prior retained-achievement compatibility decision is superseded by this explicit removal request. Other history, analytical content and exports are preserved. See achievement-removal.md for the complete implementation and verification record.
