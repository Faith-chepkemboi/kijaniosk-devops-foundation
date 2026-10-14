# Fault Injection Log

One fault at a time, each reverted and confirmed green before the next.
Note: Jenkins prints "Failed in branch ..." for skipped parallel branches. They did not run.

| # | Stage faulted | Fault introduced | Observed behaviour | Design rationale |
|---|---|---|---|---|
| 1 | Lint | Syntax error appended to `src/index.js` (build #6) | Lint red (`Parsing error: Unexpected token ;`). Build, Verify (Test and Security Audit), Archive, Publish skipped. Post: failure, changed, cleanWs ran. Nothing published. | Lint is the cheapest check, so malformed code is rejected in seconds before any slower stage spends time on it. |
| 2 | Build | Nonexistent npm script `build-does-not-exist` (build #8) | Lint passed. Build red (`Missing script`). Verify, Archive, Publish skipped. Post: failure, changed, cleanWs ran. | Tests and publishing need a working build output, so running them on a broken build would give false results. |
| 3 | Test (Verify) | Failing assertion added to `test/index.test.js` (build #10) | Lint and Build passed. Test red (3 of 4 passed); Security Audit ran to completion and passed; JUnit recorded. Archive, Publish skipped. | The audit still finishes so a developer sees every failure at once, while Archive and Publish stay blocked so untested code never ships. |
| 4 | Archive | Artifact path set to `nonexistent-dir/**` (build #12) | Lint, Build, Verify passed. Archive red (`No artifacts found`). Publish skipped. Post ran. | Publishing happens only after the build output is safely archived, so nothing unrecorded reaches the registry. |
| 5 | Publish | Wrong credential ID `wrong-id` (build #15) | Lint, Build, Verify, Archive passed. Publish red (`Could not find credentials entry`). Post ran. Artifact in Jenkins, none in Nexus. | Publish is last, so a failure leaves a tested, archived build in Jenkins while Nexus holds no half-published version. |

All faults were reverted and the pipeline returned to green after each (final restore: build #17).
Note: build #16 was a repeat run of the same Publish fault (same commit, same wrong-id error), before the revert in build #17.
Note: build #18 failed at Publish with E401 after the Nexus password was rotated but before the Jenkins credential was updated. Build #19 (same commit) passed once the credential matched.
