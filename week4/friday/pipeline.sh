#!/bin/bash
# Usage: ./pipeline.sh
# Builds the three Multipass servers with Terraform, writes the Ansible
# inventory from Terraform's output, then configures the servers with Ansible.
# Supports the Multipass path only. IPs come from Terraform's outputs, which
# read them back from Multipass through the data source.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$ROOT/terraform"
ANSIBLE_DIR="$ROOT/ansible"

# MinIO lab credentials, used only if not already set in the environment
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-minioadmin}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-minioadmin}"
export ANSIBLE_NOCOLOR=1

step() { echo; echo "=== $1 ==="; }
trap 'echo "PIPELINE FAILED near line $LINENO" >&2' ERR

step "0. Check that MinIO is reachable"
curl -fsS http://localhost:9000/minio/health/live > /dev/null \
  || { echo "MinIO is not reachable on localhost:9000" >&2; exit 1; }

step "1. Terraform apply"
cd "$TF_DIR"
terraform init -input=false -no-color
terraform apply -auto-approve -input=false -no-color

step "2. Write the Ansible inventory from Terraform output"
terraform output -json server_ips | python3 -c '
import sys, json
ips = json.load(sys.stdin)
if len(ips) != 3 or not all(ips.values()):
    sys.exit("expected three IPs, got: %s" % ips)
print("[kijanikiosk]")
for role, ip in ips.items():
    print("%s ansible_host=%s" % (role, ip))
' > "$ANSIBLE_DIR/inventory.ini"
cat "$ANSIBLE_DIR/inventory.ini"

step "3. Ansible"
cd "$ANSIBLE_DIR"
ansible kijanikiosk -m ping
ansible-playbook kijanikiosk.yml

step "4. Terraform plan, expecting zero changes"
cd "$TF_DIR"
rc=0
terraform plan -detailed-exitcode -input=false -no-color || rc=$?
if [ "$rc" -ne 0 ]; then
  echo "Terraform plan found changes or failed (exit code $rc)" >&2
  exit 1
fi

echo
echo "PIPELINE OK"
