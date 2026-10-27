# Database assets

`sqlite3.wasm` is the unmodified prebuilt module from
https://github.com/simolus3/sqlite3.dart/releases/tag/sqlite3-3.3.0,
matching `sqlite3: 3.3.0` in pubspec.lock.

SHA-256: `3c611e38db0a2609c34a141ccf70c89b407b262c9bf06877c4ba213cf9f3624b`.

SQLite is public domain. The Dart sqlite3 package is MIT licensed:
https://github.com/simolus3/sqlite3.dart/blob/sqlite3-3.3.0/sqlite3/LICENSE.

The build compiles `drift_worker.dart` against the **locked** dependencies,
including Drift 2.32.1 and sqlite3 3.3.0, instead of mixing prebuilt workers
from another dependency release. Generated worker files are ignored by Git.
Update the module, checksum, and worker together when upgrading dependencies.

These assets are served on the same origin as the app. Vercel sets the WASM
MIME type. Drift uses IndexedDB/shared-worker fallback without cross-origin
isolation headers; this avoids breaking auth popups or external resources.
