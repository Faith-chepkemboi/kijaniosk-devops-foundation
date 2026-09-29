## Git Workflow - Repository Strategy

## Branch Structure
This repository uses a 3-tier branching model:

1.  `main`: Production-ready code. Protected branch. Only receives merges from `develop` after review and testing. Represents deployable state.
2.  `develop`: Integration branch. All feature branches merge here first. Used for testing combined features.
3.  `feature/*`: Feature branches (e.g., `feature/starter-kit-files`). Created from `develop` for isolated work. Each deliverable/task has its own feature branch.

## Workflow Steps

1.  Checkout `develop`: `git checkout develop` and pull latest: `git pull`
2.  Create feature branch: `git checkout -b feature/starter-kit-files`
3.  Work and commit: `git add .` and `git commit -m "feat: ..."`
4.  Push feature: `git push -u origin feature/starter-kit-files`
5.  Open PR: `feature/*` -> `develop` for code review
6.  After testing in `develop`, open PR: `develop` -> `main` for release

## Branch Protection Rules
- `main` cannot be pushed directly, only via Pull Request from `develop`
- `develop` requires PR review before merge
- Feature branches deleted after merge to keep history clean

## Why This Model?
- Isolates unstable work in `feature/*`
- `develop` acts as staging for integration tests
- `main` always remains stable and deployable

#