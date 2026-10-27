# Web deployment verification

Verified locally on Windows on 27 October 2026 with Flutter 3.41.6 /
Dart 3.11.4. No Vercel or Railway deployment was published from this workspace.

| Check | Result |
|---|---|
| Flutter test suite | **114 passed**: existing 109 plus 5 browser stats/streak tests |
| Backend tests | **7 passed**: 4 CORS tests and 3 optional emotion-model activation/failure tests; model downloads mocked |
| Dart analysis | No errors or new warnings; 3 pre-existing unused Read & Speak debug declarations |
| JavaScript web release | Built successfully; compiled worker uses locked dependencies |
| Windows release script | Executed successfully, including checksum, build, cleanup and public artifact checks |
| Bash script | Syntax checked with Git Bash; Linux/Vercel execution still needs your account setup |
| Android debug APK | Built successfully; native database schema remains 9 |
| Public web artifact | SQLite WASM/worker present; AUDY metadata; both debug credentials absent; native ONNX model and storage probe outputs excluded |
| Chrome + Edge startup | Compiled public app loads without JavaScript exceptions |
| Chrome + Edge Caretaker | Password login; all 4 Home sections; 5 customization entries; legacy FlashCard form; editor refresh → signed-in Home; Child Progress; Profile; Settings; logout → Login |
| Chrome Student | Existing account signs in; Student Home and Games hub load without JavaScript exceptions; only the four current game choices appear |
| Chrome + Edge SQLite probe | Actual matching WASM/worker stack restores a saved value after database close/reopen and isolates a second database |
| Vercel CLI | **Logged out**; no account/project link available |
| Configured Railway URL | Initially 404; final health checks returned 200. Real generic chat returned JSON and TTS returned WAV with browser CORS headers. Emotion model remains disabled remotely |

Browser account checks used the existing test accounts and isolated browser
contexts. The smoke test blocks cloud data writes; it does not alter child
configurations, rewards or progress. The storage probe writes only randomly
named local test databases. Student game settings remain as before; Caretaker
game configs remain preview-only. Unit/widget regression coverage includes
all five configurations, legacy FlashCard editing, child isolation, break
thresholds, remaining game controllers/screens, reward/level behavior,
auth/navigation, analytics helpers and the achievement schema migration.

Logs are in the current machine's temporary directory:

- `audy-web-final-tests.log`
- `audy-web-final-analysis.log`
- `audy-web-final-build.log`
- `audy-web-android-final.log`

Remaining release checks require the user's services/devices: build on Vercel
Linux, real HTTPS emotion inference, physical camera/microphone and BLE,
Safari/Firefox and mobile browsers, and macOS/Xcode for an iOS build. Actual
cloud saves/completed games should be checked with staging/test children after
the backend CORS and emotion-model activation are configured. Concurrent additive
progress across offline/native snapshots is not a fully solved sync ledger;
the implemented web guard prevents decreasing existing cloud lifetime totals.

See [vercel-deployment.md](vercel-deployment.md) for the exact setup and checks.
Complete changed source/config contents are included in
[caretaker-source.md](caretaker-source.md); binary asset provenance is in
`web/DATABASE_ASSETS.md`.
