# AUDY web deployment — your Vercel account

Implemented 27 October 2026. Flutter remains the shared Android/iOS/web app.
The frontend is a static JavaScript release; Supabase and the Python backend
remain separate services. No live Vercel deployment has been created: the CLI
in this workspace reports **Logged out**.

## Deploy from your GitHub repository

1. Commit and push the reviewed app/backend changes to
   https://github.com/BeeKawin/audynew. Include `web/sqlite3.wasm`, the worker
   source, build scripts and `vercel.json`. Do not commit `build/`, generated
   worker JavaScript, `.vercel/`, or credentials. The repository currently also
   contains earlier approved Caretaker changes; include those deliberately.
2. Open https://vercel.com/new and sign in to **your own account/team**.
   Import `BeeKawin/audynew` and select the branch containing these changes.
3. Configure:

   | Setting | Value |
   |---|---|
   | Root Directory | `audy_app` |
   | Framework Preset | Other |
   | Build Command | `bash tool/build_web.sh` |
   | Output Directory | `build/web` |
   | Install Command | From vercel.json; dependency restoration is inside the build |

4. Add these environment variables in Vercel **before building**:

   | Variable | Value / scope |
   |---|---|
   | `API_BASE_URL` | Working HTTPS Python backend origin, **without `/api`**; Preview and Production |
   | `ENABLE_DEBUG_ACCOUNTS` | `false` for public Preview and Production |
   | `SUPABASE_URL` | Optional override; the existing project is the default |
   | `SUPABASE_PUBLISHABLE_KEY` | Optional public key override; the existing publishable key is the default |

   Do not add Gemini keys or Supabase service-role keys to the frontend.
   These variables are compiled into the app; changing them requires a rebuild.
   The script rejects Vercel builds without an HTTPS backend URL and rejects
   debug accounts for Production. Protected test previews may explicitly enable
   debug accounts; those artifacts contain the existing test credentials.
5. Deploy a branch preview first. Keep preview protection enabled if it accesses
   your live Supabase project. Complete the checks below, then promote that
   deployment to Production through your Vercel project.
6. Add a custom domain later in Vercel Settings → Domains. Add that exact origin
   to backend CORS and Supabase's applicable URL settings too.

Git import does not require a local CLI login. If you want to link the CLI
after creating the project, run these from the **repository root**:

```powershell
cd C:\Users\BKAWIN\Desktop\audynew
npx vercel login
npx vercel link --repo
```

Select your account and the imported AUDY project during linking. Follow
[Vercel's monorepo CLI instructions](https://vercel.com/docs/monorepos#add-a-monorepo-through-vercel-cli)
for subsequent commands; do not create a second project rooted at the wrong
folder. The Git/Dashboard preview and promotion workflow above is sufficient.
Avoid a temporary unclaimed Vercel deployment.

## Required Python backend setup

The repository's default address,
`https://audynew-production.up.railway.app`, initially returned 404 but later
responded with the AUDY API during final verification. `/`, `/api/health`,
`/api/flashcard/health` and `/api/tts/health` returned 200. A generic chat request
returned JSON and a short TTS request returned WAV audio with browser CORS
headers. Emotion health returned `available: false` because model loading is
explicitly disabled. No remote deployment was changed here.

In your Railway project, retain your current deployment settings and review
the backend changes before deploying this repository's **`backend`** directory
with its Dockerfile. The updated container respects Railway's `PORT` variable.
Keep `GEMINI_API_KEY` on Railway. Verify the actual public domain responds to `/`
with the AUDY API identity, then test `/api/flashcard/health`,
`/api/emotion/health`, and the chat/TTS endpoints. Models may need a cold start;
the container liveness check uses `/` rather than loading the emotion model.

For browser emotion inference, set Railway **`EMOTION_MODEL_ENABLED=true`**
after deploying the updated backend. Its default remains `false` to preserve
the repository's existing disabled state. This flag enables loading the same
existing Hugging Face ViT classifier with its image processor and safetensors
weights; model labels, preprocessing and inference calculations are unchanged.
Install the Dockerfile's ML dependencies, allow the model download and provide
adequate server resources. Warm `/api/emotion/health` until it reports
`available: true` before testing the browser capture flow. Loading errors stay
unavailable with a friendly message; inspect backend logs and restart after
correcting download/dependency problems. The web client never downloads the
native ONNX model, and Android/iOS keep their native classifier.

Set Railway `CORS_ORIGINS` to a comma-separated list of **exact origins**, e.g.
`https://YOUR-PROJECT.vercel.app,http://localhost:8080`.
Include the exact protected preview URLs that you test. Optionally set
`CORS_ORIGIN_REGEX` to an anchored expression restricted to previews belonging
to your project/team. Do not allow every `*.vercel.app` origin. Redeploy the
backend after changing this configuration. Native apps continue to work
without an Origin header; API request/response contracts are unchanged.

Use the verified backend origin as Vercel `API_BASE_URL`, then rebuild the
frontend. Browser requests must reach HTTPS and receive the matching CORS
allow-origin response. This work does not move PyTorch/Gemini into Vercel.

## Supabase setup

Email/password sign-in uses the existing project and account roles. No SQL
migration or RLS change is required for web. Caretaker rosters, child configs,
rewards and break thresholds use the existing protected repositories.

In Supabase Authentication → URL Configuration, set the appropriate web Site
URL and allow the exact production/approved preview callback URLs needed for
email confirmation or recovery. **Preserve existing mobile deep-link entries.**
Direct password sign-in does not need a new OAuth provider. OAuth and password
recovery UI are not added by this deployment work. If using a different
Supabase project for staging, apply the existing project migrations there and
set both public Supabase variables for that Vercel environment.

## Local build and browser checks

Use Flutter **3.41.6**, Dart **3.11.4**. Dependency versions remain locked; this
work does not upgrade the SDK or mobile packages.

```powershell
cd C:\Users\BKAWIN\Desktop\audynew\audy_app
$env:FLUTTER_BIN = 'C:\Users\BKAWIN\Downloads\flutter\flutter\bin\flutter.bat'
.\tool\build_web.ps1 -ApiBaseUrl 'https://YOUR-WORKING-BACKEND'
python -m http.server 8080 --bind 127.0.0.1 --directory build/web
```

Open http://localhost:8080. In another terminal, install Playwright if needed
and run `python tool/smoke_web.py`. This uses installed Chrome/Edge. Optional
`AUDY_SMOKE_EMAIL` and `AUDY_SMOKE_PASSWORD` enable Caretaker login, editor,
refresh, navigation and logout checks. The test blocks cloud data writes and
uses an isolated temporary browser context. It never saves child configs.

`tool/web_storage_probe.dart` can be compiled temporarily to
`build/web/storage_probe.js` and injected into an empty page on this same
origin to check the real SQLite/worker storage stack. It creates only randomly
named test databases. This verified reopening a saved value and isolation
between two databases in Chrome and Edge. Do not upload probe outputs; a normal
release rebuild removes them.

## What changed and what remains platform-dependent

- `vercel.json`: static build/output, revalidation, WASM MIME type and document
  rewrites. Missing assets with extensions return 404 instead of HTML. Hash
  navigation remains; a refresh restores authenticated home rather than trying
  to recreate an in-memory game/result argument. No new routing framework.
- `tool/build_web.sh` bootstraps pinned Flutter on Linux/Vercel, restores the
  lockfile, compiles the Drift worker, builds JavaScript, removes the native
  ONNX model from the upload and checks the artifact for debug credentials.
  `tool/build_web.ps1` provides the equivalent public release on Windows.
- `web/sqlite3.wasm` matches locked sqlite3 3.3.0; its checksum is checked.
  The worker is compiled against the same lockfile, including Drift 2.32.1.
  See `web/DATABASE_ASSETS.md` for provenance and upgrade instructions.
- Browser databases are named per authenticated account. Login waits for its
  own storage initialization, resets the previous account's runtime state,
  and restores cloud lifetime points/games before play. Native `audy_db` and
  schema version **9** remain unchanged. App appearance settings remain
  device-wide by the earlier approved design.
- Browser stats use compare-and-swap retries and monotonic lifetime totals;
  a fresh/stale web cache cannot decrease cloud points/games. The existing
  elapsed-day streak rule is retained. This is **not a complete cross-device
  event ledger**: simultaneous offline/mobile snapshots may still lose additive
  contributions, and existing native clients still use absolute sync. Game
  history/skins/local preferences are not automatically merged across devices.
  Clearing site data removes that browser's local cache. Private browsing and
  restricted storage may be temporary; memory-only or unsafe storage modes
  show a friendly message. Chrome on Android without shared workers/isolation
  needs a single tab; this phase leaves cross-origin isolation headers off.
- Browser emotion capture reads `XFile` bytes and displays a `MemoryImage`.
  The browser explicitly captures a photo and calls `EmotionService`'s API
  implementation. Native File/ONNX/ML Kit preprocessing and automatic face
  guidance remain in place. Browsers require camera permission and HTTPS
  (localhost is allowed). Actual classification depends on the backend.
- Browser sound uses the existing audioplayers dependency, loads on demand,
  and begins after a pointer gesture; native SoLoud loading remains unchanged.
  Speech capability/permission failures do not block startup. Social Chat
  keeps text input, and Read & Speak reports unavailable recognition instead
  of completing a fake speech attempt. Browser Thai voices vary by device.
- Web Bluetooth uses runtime support checks, a user-triggered chooser,
  the AUDY name filter and the correct optional GATT service. Unsupported
  browsers get a friendly explanation; existing screen controls still work.
  Physical BLE/robot verification requires supported hardware. Realtime
  message formats are unchanged.
- The legacy Caretaker UI/background, guides, analytical calculations, exports,
  TBD sections, and removal of achievements remain intact. Five game configs
  still apply only to Caretaker previews; the separately approved break
  threshold still applies to Student gameplay.
- AUDY web metadata and launcher icons reuse the existing app icon. The web
  upload excludes the native ONNX model. Other large media load as requested;
  no offline PWA/service-worker cache is introduced.

## Verification and production checks

Automated/unit results and final browser observations are recorded in
`web-verification.md`. Before promoting your own deployment:

1. Confirm HTTPS, app title/icons, `/sqlite3.wasm` with `application/wasm`,
   `/drift_worker.js` as JavaScript, and a missing `.wasm` returning 404.
2. Check both roles with test accounts, logout immediately returning to Login,
   refreshing signed-in home/editor, back navigation, child selection, all
   five saved configs/legacy FlashCard form/previews, guides, break settings,
   profile/settings and unchanged Analysis/exports.
3. Use staging/test children for actual saves and completed games. Check local
   persistence after refresh, separate accounts, points/rewards/history,
   break thresholds, stale progress sync and interrupted network requests.
4. Test camera allow/deny/retry with the real HTTPS API, microphone allow/deny,
   text chat, TTS/audio after a gesture, on-screen game controls and supported
   physical BLE. An unavailable backend or disabled emotion model cannot pass
   the corresponding AI gate.
5. Exercise phone/tablet/desktop sizes in Chrome/Edge and the supported target
   versions of Safari/Firefox. Their speech/Bluetooth capabilities differ.
6. Keep running Android/iOS checks from the same repository. Android builds on
   Windows; an iOS build/device check requires macOS/Xcode. Web deployment
   does not alter either app's release channel or mobile signing.

Official references: [Flutter web deployment](https://docs.flutter.dev/deployment/web),
[Vercel project configuration](https://vercel.com/docs/project-configuration/vercel-json),
[Drift web setup](https://drift.simonbinder.eu/platforms/web/),
[Supabase redirect URLs](https://supabase.com/docs/guides/auth/redirect-urls).
