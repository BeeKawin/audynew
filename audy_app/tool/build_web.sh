#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Vercel runs Linux. Use the exact SDK used by Android/iOS development.
readonly FLUTTER_REVISION=db50e20168db8fee486b9abf32fc912de3bc5b6a
if [[ -z "${FLUTTER_BIN:-}" ]]; then
  sdk_dir="${TMPDIR:-/tmp}/audy-flutter-3.41.6"
  if [[ ! -x "$sdk_dir/bin/flutter" ]]; then
    git clone --depth 1 --branch 3.41.6 https://github.com/flutter/flutter.git "$sdk_dir"
  fi
  [[ "$(git -C "$sdk_dir" rev-parse HEAD)" == "$FLUTTER_REVISION" ]]
  FLUTTER_BIN="$sdk_dir/bin/flutter"
fi
readonly dart_bin="$(dirname "$FLUTTER_BIN")/dart"

if [[ "${VERCEL:-0}" == 1 && -z "${API_BASE_URL:-}" ]]; then
  echo 'Set API_BASE_URL to your working HTTPS backend URL in Vercel.' >&2
  exit 1
fi
if [[ "${VERCEL:-0}" == 1 && "${API_BASE_URL:-}" != https://* ]]; then
  echo 'API_BASE_URL must use HTTPS for a Vercel deployment.' >&2
  exit 1
fi
if [[ "${VERCEL_ENV:-}" == production && "${ENABLE_DEBUG_ACCOUNTS:-false}" == true ]]; then
  echo 'Debug accounts must be disabled in production.' >&2
  exit 1
fi

defines=("--dart-define=API_BASE_URL=${API_BASE_URL:-}"
         "--dart-define=ENABLE_DEBUG_ACCOUNTS=${ENABLE_DEBUG_ACCOUNTS:-false}")
if [[ -n "${SUPABASE_URL:-}" ]]; then
  defines+=("--dart-define=SUPABASE_URL=$SUPABASE_URL")
fi
if [[ -n "${SUPABASE_PUBLISHABLE_KEY:-}" ]]; then
  defines+=("--dart-define=SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY")
fi
echo '3c611e38db0a2609c34a141ccf70c89b407b262c9bf06877c4ba213cf9f3624b  web/sqlite3.wasm' | sha256sum --check
"$FLUTTER_BIN" --version
"$FLUTTER_BIN" pub get --enforce-lockfile
"$dart_bin" compile js -O4 web/drift_worker.dart -o web/drift_worker.js
"$FLUTTER_BIN" build web --release --no-wasm-dry-run --pwa-strategy=none \
  "${defines[@]}"

# The web classifier uses the API. Keep the native-only model out of the upload.
"$dart_bin" run tool/prepare_web_artifact.dart
"$dart_bin" run tool/verify_web_build.dart
