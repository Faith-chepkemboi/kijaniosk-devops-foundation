# KijaniKiosk Full IaC Pipeline (Week 4)

This project builds the KijaniKiosk staging environment from code. Terraform creates three
Multipass servers (api, payments and logs) from one reusable module. Ansible then configures
them. A script called pipeline.sh runs both in order and writes the Ansible inventory from
Terraform's output, so I never type an IP address by hand.

## What you need before running it
- Terraform, Multipass and Ansible installed (the versions I used are in environment-setup.md)
- MinIO running on localhost:9000 with a bucket called `kijanikiosk-tfstate`
- My SSH key at ~/.ssh/id_ed25519

## How to run it
    ./pipeline.sh

I run it twice to check it is reproducible. On the second run Terraform should report no
changes and Ansible should show changed=0 on all three servers.

## What is in this folder
- terraform/ : the module, the root configuration and the MinIO backend
- ansible/ : the playbook, group_vars, host_vars and templates
- pipeline-run1.log and pipeline-run2.log : the output of both runs
- hardening-decisions.md : the security decisions, written for Nia
- reflection.md : my answers to the three reflection questions
- environment-setup.md : the tools and versions I used
- destroy-output.txt : the clean teardown at the end

## Things to know
- This is the Multipass path only, with MinIO as the state backend.
- The services are placeholders, so the security controls have not been tested against real
  payments traffic. The hardening document explains this and the other gaps.
