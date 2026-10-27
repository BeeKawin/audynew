# Restored Teacher FlashCard customization

Implemented on 24 October 2026. This document explains the delivered behavior; it is not a new implementation plan.

## What was restored

The source is `lib/src/features/teacher/teacher_dashboard.dart`, specifically `_buildWordBankCard`, `_pickImage` and `_addClassWord`. The Caretaker editor now uses the same inline sequence:

1. **Word / Text**, with the original label icon and rounded input.
2. **Word Type**, with the original five categories.
3. **Add Card Image**, followed by a small image thumbnail and remove-image action.
4. **Add Custom Flashcard Card**, the original blue rounded button.
5. **Custom Flashcards Added**, displayed as wrapping chips with category colors and optional thumbnails.

The white rounded card, original AUDY colors, spacing, field icons and background remain consistent with the legacy Teacher/Parent design. The card form is now the first functional section in FlashCard customization. Creating a card no longer requires opening the newer modal dialog. Labels are available in English and Thai. Narrow layouts use wrapping controls; card and delete targets accommodate at least 48 pixels, and the library was checked with doubled text size in both languages.

The title is **Flashcard Custom Cards**, rather than **Class Flashcard Custom Cards**, because the destination is one selected child's library. Editing, deletion, per-child persistence and save-conflict protection from the existing Caretaker implementation remain available.

## How to use it

Open **Caretaker Home → Customization → select a child in your care → FlashCard**.

The screen loads that child's saved FlashCard configuration. Existing custom cards appear as chips. An empty library means that no custom cards have been saved for that child; it does not remove the game's built-in cards.

Enter a word, choose its type, optionally choose an image, then press **Add Custom Flashcard Card**. This adds the card to the screen's draft and clears the inline form back to Noun with no image. The confirmation explicitly tells you to use **Save settings** to persist the draft. You can add several cards before saving.

Tap a card chip to load it back into the inline form. The button becomes **Update Flashcard Card**. Updating preserves its existing identifier and replaces the draft's word, category and image. If another unfinished card is already in the form, the app asks whether to replace that unfinished entry. **Clear card form** cancels that unfinished entry without removing cards already in the library. The chip's remove action removes that card from the draft; **Save settings** persists the removal.

Unfinished inline text, a selected image, a changed type or an active edit counts as unsaved work. Save and Preview require you to add/update that card or clear the form first. Leaving the screen offers Stay, Discard, or Save and continue. A failed save keeps the draft. A stale revision requires reloading the saved revision before writing again. This avoids silently dropping typed text or overwriting another Caretaker's saved settings.

## Card fields and limits

| Field | Values/default | Behavior |
| --- | --- | --- |
| Word / Text | Required, trimmed, 1–40 characters under the existing configuration validator | The displayed/spoken text of the custom card. Blank entries are rejected. |
| Word Type | Pronouns, Noun, Actions, Feeling, Adverbs; default Noun | Stored as `pronoun`, `noun`, `verb`, `adjective`, `adverb`, preserving legacy identifiers. |
| Image | Optional; default none | Choose from the device gallery. Preview immediately shows the selected image; remove it independently of the word. |
| Library size | Up to 20 cards per child | Add and import are disabled at the limit; existing cards can still be edited or removed. |
| Duplicates | A word/type combination must be unique | Comparison trims the word and ignores letter case. The same word may have different word types. |

Images retain the legacy gallery settings: up to 400 × 400 and quality 70. The Caretaker implementation also corrects orientation and normalizes the picture to JPEG off the UI thread. Each stored picture must fit within 128 KiB; the existing complete-configuration size limit is 2 MiB. Canceling the gallery leaves the current image intact, and image failures produce a friendly message. Existing supported bundled pictures and stored JPEG/PNG data URLs remain readable.

## Meaning of the five legacy word types

| Legacy label | Stored category | Current generator behavior |
| --- | --- | --- |
| Pronouns | `pronoun` | Added to the sentence-subject pool. |
| Noun | `noun` | Registered in the custom food/washable pools. See the object-list limitation below. |
| Actions | `verb` | Added as an action, using the extended food-object pool. An unsuitable action/object pairing is possible. |
| Feeling | `adjective` | Saved in the word bank, but the current sentence templates do not select this category. |
| Adverbs | `adverb` | Saved in the word bank, but the current sentence templates do not select this category. |

These behaviors come from `backend/app/services/flashcard_service.py`, especially `_create_context` and `_build_sentence_ids`. Restoring the old UI does not extend that grammar engine.

There is an additional existing limitation: the generator copies the built-in actions' object lists before adding custom nouns. Those copied lists therefore do not automatically gain the new noun. Custom actions reference the extended food list, so a custom noun can be selected through a custom action. A noun-only addition is not guaranteed to occur in a generated sentence. Custom cards join a randomized pool; the preview does not guarantee that every added card will appear.

Custom text is also used unchanged for both English and Thai by the existing backend. Selecting a content language changes the built-in content and narration language; it does not translate a custom word. Choose words appropriate for the language you intend to preview.

## Retained preview settings

The original inline card editor is now the main section. Existing Caretaker preview controls remain underneath it:

| Setting | Allowed values/default | Effect |
| --- | --- | --- |
| Difficulty | Child chooses (default), Easy, Medium, Hard | Child chooses provides a difficulty selector in the Caretaker preview. Easy uses 3 cards with picture/text placement hints; Medium uses 5 with picture hints; Hard uses 5 without hints. |
| Content language | App language (default), English, Thai | Selects the preview content/narration language. |
| Card preview pace | 2 seconds (default), 3 seconds, 5 seconds, Manual | Controls the initial card presentation; Manual provides a Next card action. |
| Automatic narration | On by default | Controls automatic speech during preview; individual Speak actions remain available. |
| Use this child's custom cards | Off by default | Include the child's custom cards in preview requests. Enabling requires at least one card. Built-in cards remain available. |

**Preview draft** uses the current completed draft without requiring a save. The preview passes its custom-card snapshot to the existing generation and validation API and runs the existing three-round flow. It does not write Student points, progress, assignments, analytics or the break counter.

**Restore defaults** resets preview controls, including turning custom-card use off, while retaining the card library. It also leaves an unfinished inline card available to finish or clear. Saving after reset persists the reset controls and retained cards.

## Storage and legacy compatibility

The former Teacher Add button wrote immediately to the teacher-scoped `class_words` bank. In the Caretaker screen, Add/Update changes a draft and Save writes the existing per-child `child_game_configs` row for game `flashcard`. This intentional persistence difference preserves the approved per-child workflow. No new table, migration or automatic data conversion is needed.

The JSON shape is unchanged: `custom_cards` contains `id`, `word`, `category` and `image_url`. Saved revisions and schema version 1 remain compatible. Older saved Caretaker cards load into the restored chip library and can be edited in place. Future schema versions remain read-only. Saving is authorized through the existing active-care-list RPC and revision check.

An account whose stored legacy role is Teacher retains **Import from my legacy word bank**. It lists that signed-in teacher's existing `class_words`, copies one chosen word/type/image into the inline form, and then follows Add → Save for the selected child. Import does not delete or overwrite the original class card. A new Caretaker account does not receive access to another teacher's bank. Existing Teacher/Student class-word behavior is unchanged.

As previously approved, these five game configurations are still **saved settings plus Caretaker previews**. They are not newly applied to Student gameplay. The separate Break / Meltdown threshold remains the approved exception that already applies to Student checks.

## Related login fixes

- Caretaker Logout clears local account state immediately, opens Login immediately, and removes the previous navigation stack. It no longer waits on a Caretaker widget that sign-out can dispose.
- A missing account cannot fall through the shared shell into Student Profile. A delayed profile response cannot restore the account after logout.
- Login displays both Student and Caretaker debug buttons in all build modes, including release. They are temporarily disabled while a previous sign-out is finishing.
- Student uses the original `test@audy.com` account; Caretaker uses `caretaker@gmail.com` with the supplied password. Both use real authentication and validate the returned profile mode. Failed authentication remains on Login rather than inventing a local Student profile.

## Verification and practical limits

The full Flutter suite passed 105 tests. The restored inline card form, saved-card edits/deletion, duplicate validation, unfinished-entry protection, per-child save/reset behavior and doubled-text English/Thai layout have regression coverage. Logout is tested with remote sign-out deliberately held pending; Login appears first and Back cannot reopen the protected screen. Debug success, failure, unexpected roles and late profile responses are also covered.

Both actual Supabase debug-account sign-ins passed, and the Student account ID matches the original account. Verification sessions were signed out individually; no password or account record was changed. Access tokens and passwords were not printed.

Static analysis and debug compilation results are recorded in `student-cleanup-verification.md`. Physical gallery selection, camera, microphone, audible speech and device installation still require real-device checks. The configured Railway backend has returned HTTP 404, so successful live sentence generation is not claimed. The existing local-backend and deterministic-controller checks do not establish a successful deployed-service preview.
