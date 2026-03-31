# Git Workflow

## Branches

- `main`: production-ready releases only
- `dev`: integration branch for validated features
- `feature/<scope>`: one branch per feature or refactor
- `fix/<scope>`: one branch per bug fix

## Local Setup

```powershell
cd C:\Users\User\Desktop\AUDY\testrun1
git init
git branch -M main
git checkout -b dev
git checkout -b feature/frontend-functional-state
```

## Connect Remote

```powershell
git remote add origin https://github.com/<your-user>/<your-repo>.git
git remote -v
```

## Daily Workflow

```powershell
git checkout dev
git pull origin dev
git checkout -b feature/<short-scope>
```

## Before Commit

```powershell
dart format lib test
flutter test
git status
git diff --stat
```

## Commit Style

- `feat: add frontend state controller for learning flows`
- `feat: connect dashboard and activity screens to local state`
- `test: cover dashboard navigation flow`
- `docs: add git workflow guide`

## Commit Commands

```powershell
git add lib test docs .gitignore
git commit -m "feat: connect UI screens to local functional state"
```

## Push Branch

```powershell
git push -u origin feature/<short-scope>
```

## Merge Sequence

```powershell
git checkout dev
git merge --no-ff feature/<short-scope>
git push origin dev
```

## Release Sequence

```powershell
git checkout main
git merge --no-ff dev
git push origin main
```

## Rules

- Keep commits atomic: one concern per commit.
- Run tests before every merge.
- Never commit secrets or local environment files.
- Prefer short-lived feature branches.
