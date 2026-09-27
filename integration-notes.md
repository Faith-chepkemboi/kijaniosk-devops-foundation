# KijaniKiosk Infrastructure Integration Challenges Report

### Challenge 1: Resolving Existing Service Account UID / Mismatched Attribute Configuration
* **Challenge:** Pre-existing system accounts created manually during earlier labs contained loose parameters, including active interactive login access (`/bin/sh`).
* **Resolution:** The provisioning engine handles this using structural `getent passwd` validation filters. Instead of blindly executing user actions that would fail if an account already exists, it targets the accounts and runs an idempotent `usermod` adjustment to lock them down to a non-interactive shell (`/usr/sbin/nologin`).

### Challenge 2: Reversing Configuration Permissions Over-Exposure (777 Drift Restoration)
* **Challenge:** Emergency remediation efforts left production paths wide open with dangerous `777` permissions, allowing any local user to modify system configurations.
* **Resolution:** The provisioning engine enforces explicit file ownership via a top-down reset. It applies a structured group configuration (`root:kijanikiosk`), resets permissions to a safe baseline (`750` and `770`), and layers on POSIX ACLs to ensure least-privilege isolation.

### Challenge 3: Firewall Rules Conflict Resolution and Atomic Cleansing
* **Challenge:** Leftover firewall rules from previous troubleshooting sessions blocked port `3001`, which would have completely taken down the new payments service deployment.
* **Resolution:** Instead of trying to parse and edit messy rules line-by-line, the script uses an atomic flush pattern (`ufw reset`). It wipes out all old custom parameters and builds a clean, explicitly commented whitelist layout from scratch.

### Challenge 4: Logrotate Execution Isolation and Security Constraints
* **Challenge:** The `logrotate` tool will refuse to process directories that have unsafe write configurations, causing automated management scripts to fail.
* **Resolution:** We solved this by using the explicit `su kk-logs kijanikiosk` directive inside the logrotate configuration file. This instructs the logrotate daemon to securely drop its root privileges and manage log configurations under a lower-privileged group framework.
