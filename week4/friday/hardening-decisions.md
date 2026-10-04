# Hardening Decisions: KijaniKiosk Staging Environment

Nia, this note explains how the staging environment is protected, in words you can repeat to the board. The environment is three servers: one for the core application, one for payments and one for logging. They are created from a written specification and rebuilt identically every time. Every control below was deployed and checked, not merely planned.

## How the environment is built

A first tool creates the three servers and records exactly what exists. A second tool then configures each one from the same written instructions. We ran the whole sequence twice. The second run reported zero changes, which shows the result is reproducible and nobody has to remember manual steps.

## Controls

| Control | What it does | Risk mitigated |
|---|---|---|
| Shared record of infrastructure | Stores the record of what we built in one central place instead of on one laptop | A lost or out-of-date record leading to wrong changes |
| Change locking | Refuses a second change while one is running; we tested this and the second attempt was rejected | Two engineers corrupting the record at the same time |
| Key-only remote login | Each server accepts only our approved cryptographic key, installed when the server is created; password login is off by the server image default, not by our own configuration | Password guessing against the servers |
| Default-deny firewall | Blocks all incoming traffic except remote login and the one port each server needs | Reaching services that were never meant to be public |
| Separate service accounts | Each service runs as its own user that cannot log in interactively | One compromised service taking over the others |
| Read-only system for payments | The payments service cannot change operating system files | Tampering with the system to hide or persist an attack |
| No gaining extra powers | The service starts with no special privileges and cannot acquire any | An attacker escalating to full control of the server |
| Private workspace | Gives the service its own temporary space and hides user home folders | Reading or leaving behind other people's data |
| Restricted system requests | Limits what the service may ask the core of the operating system to do, and forbids memory that is both writable and executable | Injected malicious code running |
| Kernel and device protection | Blocks changes to core system settings, loadable components and hardware devices | Attacks on the underlying machine |
| Network traffic deny | The payments service is blocked from network traffic unless explicitly allowed | Stolen data being sent out |
| Restrictive file permissions | New files created by the service are unreadable by other accounts | Accidental exposure of payment data |
| Persistent, limited logs | Keeps logs across restarts, caps their size and keeps seven days | Losing evidence, or logs filling the disk |

## The payments security score

The operating system includes a tool that grades how exposed a service is, from 0 (best) to 10 (worst). Our payments service scores **1.9**, rated OK, against a target of below 2.5. It also starts correctly and can read its own settings file, which confirms the hardening does not break the service. The two remaining deductions, 0.1 each, are for allowing local connections between programs and for full visibility of some system information. Both are minor and we chose not to chase them. The full output is saved alongside this document.

## What we decided about locking

The shared record sits on a storage service running on one laptop. The lock works, but it relies on that single service behaving correctly. A production system would use a managed, replicated store built for this, such as the database service on Amazon, the built-in locking on Google Cloud, or a vendor-neutral coordination service.

## What the current posture does not protect against

This is a staging environment, and it is not production-ready. We want you to know the limits.

First, the services are placeholders. They print a message every hour, so none of the controls has been tested against real payment traffic. When the real payments application arrives, the blanket network deny will block it until we add a specific allowance, and that change must be reviewed.

Second, the servers are only as safe as our own laptop. Anyone holding the approved key, or access to the storage service, can change or destroy everything. There is no separate approval step, no key rotation, and the storage service uses default credentials that must never be used beyond a local test. The firewall also accepts remote login from any address on the internet, not only from our office, so the key is the only barrier.

Third, we have no monitoring or alerting. Logs are kept, but nobody is told when something suspicious happens. We also have no encrypted backups and no tested recovery plan.

Fourth, the servers are not automatically patched. Several updates were waiting when we logged in, and a weakness in a standard component would stay open until we applied them.

Finally, there is no protection against a trusted insider, a stolen laptop, or an attack on the supply chain of the software we install. These risks need separate decisions before real customer money flows through this environment.
