# KijaniKiosk Production Infrastructure Hardening Architecture Spec
**Author:** Amina (DevOps Engineering)  
**Audience:** Technical Leadership & Corporate Board of Directors  

## 1. Engineering Philosophy and Strategic Rationale
Manual infrastructure configurations leave behind undocumented vulnerabilities and operational mismatches ("dirty states"). To establish an immutable foundation for the upcoming production migration of the `kk-payments` engine, we have constructed an automated, stateful, and entirely idempotent configuration template. 

By treating security posture as a deterministic set of conditions rather than a series of manual adjustments, we guarantee that the host server self-corrects back to baseline regardless of existing configurations or unauthorized local changes.

---

## 2. Hardening Vectors Matrix

| Subsystem Vector | Implemented State Configuration | Defensive Engineering Rationale |
| :--- | :--- | :--- |
| **Identity & Access Management** | Accounts `kk-api`, `kk-payments`, `kk-logs` set to `/usr/sbin/nologin` with a shared base system group wrapper (`kijanikiosk`). | Prevents attackers from initiating an interactive command terminal shell drop if the top-layer application software contains remote code execution vulnerabilities. |
| **Directory Boundary Layout** | Root path `/opt/kijanikiosk/config` restricted to `750` under `root:kijanikiosk`. Log path limited to `770` with fine-grained POSIX access control lists. | Corrects loose permissions from troubleshooting sessions. Isolates runtime environments so `kk-payments` and `kk-api` cannot access each other's configurations or modify global logging records. |
| **Process Sandbox Layer** | Full Systemd service isolating matrices including `ProtectSystem=strict`, `ProtectHome=true`, and `NoNewPrivileges=true`. | Blocks runtime workloads from executing dangerous actions, reading core operating system paths, or escalating privilege thresholds via local host system exploits. |
| **Stateful Boundary Inspection** | Total atomic purge (`ufw reset`) followed by strict default deny incoming parameters. Explicit whitelists for ports 22, 3000, and 3001. | Clears out temporary rules left over from past incidents. Ensures that our payments service interface is open and accessible while dropping all unauthorized ingress vectors. |
| **Resource Exhaustion Shield** | Systemd log configuration maps persistent system logs with a absolute hard cap threshold limited to `500M`. | Prevents bad loops or debugging floods from entirely exhausting storage disks, avoiding systemic node failures. |

---

## 3. Deep-Dive Architectural Defense Review

### A. Non-Interactive Process Demotion
Many baseline system designs mistakenly initialize third-party software under highly privileged standard root or generic system accounts that retain default shell profiles like `/bin/sh`. In our production hardening strategy, each service operates within its own dedicated container-like workspace. 

The `kk-payments` framework is run by a user account that cannot log in or run system commands directly. This significantly limits what a malicious file can execute on the system if a vulnerability is exploited.

### B. POSIX Access Control List (ACL) Design Pattern
Traditional Linux file configurations allow folder permissions to be managed across three simple tiers: Owner, Group, and Public. In modern microservices environments, this model is too simple. The logs folder must be accessible to multiple services (`kk-api` and `kk-payments` need to write logs, while `kk-logs` needs to read them), but these services should not be able to read or modify each other's backend files. 

By implementing explicit POSIX ACLs (`setfacl`), we apply granular permissions that let our components collaborate safely while maintaining strict boundaries between them.

---

## 4. Honest Gaps & Future Roadmaps

While the current infrastructure meets strict compliance gates, a realistic security review requires calling out our current limitations:

1. **Inline Configuration Secrets:** Application service parameters are currently written as plain text inline variables inside our configuration engine. For true production environments, these keys should be handled using secure runtime injection patterns from an external secrets store like HashiCorp Vault.
2. **Local Logging Vulnerability:** System logs are stored locally on the server file structure. If an attacker gains root access, they could potentially clear these files to erase their tracks. Our next iteration should automatically ship logs off-site to a remote SIEM cluster or secure object storage node.
3. **Static Image Infrastructure:** The host depends on live packages fetched during deployment. To make deployments completely predictable, we should shift to a pre-baked immutable system image strategy (such as Packer or Docker base templates) to ensure zero package changes over time.

