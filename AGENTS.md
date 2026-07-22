# 🧠 AUDY — AI Agent Operating Manual

> Flutter app for autistic children | Emotion recognition · Cognitive training · Autism-friendly UX

---

## 1 · Execution Loop (MANDATORY)

1. **PLAN** — Analyze, propose solution, list affected files
2. **WAIT** — Do NOT write code until user approves
3. **IMPLEMENT** — Apply approved changes only
4. **EXPLAIN** — Summarize what changed and why
5. **STOP** — Wait for next instruction

**Hard rules:**
- ❌ Never skip steps
- ❌ Never implement without approval
- ❌ Never assume missing details — ask
- ❌ Never modify unrelated files

---

## 2 · Project Overview

| Aspect        | Detail                                         |
| ------------- | ---------------------------------------------- |
| **Platform**  | Flutter (Dart)                                 |
| **Audience**  | Autistic children                              |

---

## 3 · Architecture

### 3.1 Separation of Concerns

| Layer     | Responsibility              | Location          |
| --------- | --------------------------- | ----------------- |
| **UI**    | Widgets, screens, layouts   | `/lib`            |
| **Logic** | Services, controllers       | `/services`       |
| **Shared**| Reusable components         | `/widgets`        |


### 3.2 State Management
- Use existing state solution (check project first)
- Keep state local when possible
- Avoid global state unless shared across screens

### 3.3 Error Handling
- Always handle ML model failures gracefully
- Show friendly, non-alarming error messages
- Never expose raw stack traces to the user

---



## 5 · UI/UX Rules (CRITICAL)

Design for autistic children — every decision must pass these checks:

| Rule                  | Requirement                        |
| --------------------- | ---------------------------------- |
| Touch targets         | ≥ 48 × 48 px                       |
| Text                  | Minimal; prefer icons over words   |
| Colors                | Hard, Contrast     |
| Animations            | None sudden; gentle transitions only |
| Layout                | Predictable, consistent            |
| Feedback              | Clear, immediate after every action |
| Complexity            | One primary action per screen      |
| Navigation            | Linear, no deep stacks             |

**Test:** Would an autistic child understand this screen in 3 seconds? If not, simplify.

---

## 6 · Emotion Recognition System

### Flow
```
Emotion Selection → Selfie Capture → Model Inference → Result Display
```

### Integration
- **Always** use: `EmotionService.detectEmotion(image)`
- **Response shape:**
  ```dart
  {
    detectedEmotion: String,
    confidenceScore: double,
  }
  ```
- Model logic stays in `/services` — NEVER in UI widgets

### Allowed Navigation
```
EmotionGameScreen → SelfieCaptureScreen → ResultScreen
```
- No deep navigation stacks
- Do not modify global routing unless required

---

## 7 · Coding Standards

- **Language:** Clean, readable Dart
- **Widgets:** Small, reusable, single-purpose
- **Nesting:** Max 3 levels — extract widgets if deeper
- **Naming:** Descriptive, intention-revealing
- **Comments:** Only for non-obvious logic; no fluff
- **Imports:** Sorted, no unused imports

---

## 8 · Performance

- Keep UI thread free of heavy computation
- Lazy-load images and models
- Avoid heavy packages; prefer lightweight alternatives
- Test on low-end devices mentally before coding

---

## 9 · Pre-Implementation Checklist

Before writing ANY code:

- [ ] Check existing code structure
- [ ] Reuse existing components
- [ ] Identify dependencies
- [ ] List files to modify
- [ ] Confirm UI/UX compliance
- [ ] Get user approval

---

## 10 · Output Format

### Phase 1 — Planning
- Bullet points only
- Clear structure
- No code

### Phase 2 — Implementation
- Full file contents (no partial snippets)
- Mark changed sections clearly

### Phase 3 — Explanation
- What changed
- Why it changed
- Assumptions made

---

## 11 · Priority Order

1. **Correctness** — Feature works as intended
2. **Safety** — No breaking changes
3. **Simplicity** — Least complex solution
4. **Accessibility** — Autism-friendly first
5. **Performance** — Fast and lightweight

---

## 12 · Failure Conditions

Any of these = **FAIL**:
- Writing code without approval
- Modifying unrelated files
- Breaking existing functionality
- Ignoring UI/UX rules
- Mixing UI and ML logic
- Assuming details not provided

---

## 13 · Success Criteria

- ✅ Clean, maintainable architecture
- ✅ Autism-friendly UI on every screen
- ✅ Working feature with no regressions
- ✅ User understands every change made
