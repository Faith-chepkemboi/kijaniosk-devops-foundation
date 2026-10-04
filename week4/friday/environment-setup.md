# Environment Setup

Path used: **Multipass primary path** with a local MinIO remote backend (endpoint http://localhost:9000).

| Tool | Version |
|------|---------|
| Terraform | v1.16.4 |
| Multipass | 1.16.4 |
| Ansible | ansible [core 2.20.1] |
| MinIO | minio version DEVELOPMENT.GOGET (commit-id=DEVELOPMENT.GOGET) (native binary, data in ./minio-data) |
| Host OS (control machine) | Ubuntu 26.04.1 LTS |
| Guest OS (all three servers) | Ubuntu 22.04 LTS, created by Multipass |

## Notes
- State backend: MinIO bucket `kijanikiosk-tfstate`, S3-compatible, run locally as a native binary.
- MinIO was installed from source with `go install`, so it reports a development build string instead of a release number.
- The S3 backend on MinIO has no native state locking. This is documented as a known limitation in hardening-decisions.md.
- Run the pipeline with `./pipeline.sh` (defaults to the Multipass path).
