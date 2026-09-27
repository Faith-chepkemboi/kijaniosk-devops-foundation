# DevOps Delivery Notes - The Three Ways

This project implements DevOps principles based on The Three Ways: Flow, Feedback, and Continuous Learning.

### 1. Flow (Left to Right Flow of Work)
Flow is about fast and smooth delivery from Dev to Ops.

The workflow:
- **Branching Strategy:** We use `feature/*` -> `develop` -> `main`. This prevents bottlenecks. Developers work in parallel in feature branches without blocking main.

- **Small Batches:** We commit small deliverables (one md file per commit) instead of one large commit. This makes flow faster and review easier.

- **Version Control:** Everything in GitHub. No manual file sharing. Code flows automatically via Pull Requests.
- **Automation Ready:** `develop` branch can be set for future CI/CD pipeline to test automatically before merging to `main`.

### 2. Feedback 
Feedback is about getting quick information to fix problems early.

How it appears in our workflow:
- **Pull Requests:** When we push `feature/*` to `develop`, team reviews code. If there is a mistake reviewer catches it before it reaches `main`.
- **Git Status Checks:** `git status`, `git log` gives immediate feedback if files are missing or not committed.
-
- **Branch Protection:** `main` is protected. You cannot push directly, you must get feedback via PR approval.

### 3. Learning (Continuous Experimentation and Learning)
Learning is about continuous improvement and sharing knowledge.

How it appears in our workflow:
- **Documentation Culture:** Files like `cloudservice-model.md` and `networkArchitecture.md` capture WHY we made decisions, not just WHAT. Future team members learn from this.
- **Blameless Post-Mortem:** If a PR breaks `develop`, we document it in delivery notes and improve workflow, not blame person.

- **Shared Repository:** All knowledge (git-workflow, reasoning) is in repo, not in one person's laptop. Team learns together.

### Summary
- Flow = Feature branches enable fast parallel work.
- Feedback = PR reviews and protected branches catch errors early.
- Learning = Documentation in starter-kit ensures knowledge is shared and improved.