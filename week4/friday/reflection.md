# Reflection

## 1. When two requirements conflicted

The conflict I'm most aware of is between the security score and the payments service actually working. The shared hardening list includes IPAddressDeny=any, which blocks all network traffic for the service. That rule helps the score get down to 1.9. But the firewall also opens port 3001 for payments traffic, and once a real application listens on that port, the two settings will fight each other. Right now the service is just a placeholder loop that prints a line every hour, so it starts fine and scores well, and the problem stays hidden. I didn't weaken the rule to make the problem go away, because a score I got by loosening things would mean less. I wrote the gap into the hardening document instead. The fix is a narrow allowance for the payments port, set through the Ansible variables and reviewed before it goes in.

Challenge D was a smaller conflict. The environment file lives under /opt/kijanikiosk/config, and the service reads it fine. When I tested it by reading the file as kk-payments, I realised that test only proves the file permissions are right. It doesn't prove the sandbox lets the service through, because systemd loads the environment file itself before the sandbox is applied. The service being active is the better evidence that it works.

Two other things surprised me. The brief assumes MinIO has no state locking, but my backend sets use_lockfile = true. My first test was invalid, because terraform console never took the lock. The second test worked: while a destroy sat waiting for confirmation, a second plan was refused with a 412 PreconditionFailed error. I also had MinIO stop partway through the session, and terraform plan failed with connection refused. The state was still safe because it sat in a data folder on disk, and once I restarted MinIO from the right folder, the plan showed no changes. I learned from that to treat the state server as a dependency I have to keep running, and to always start it from the same folder.

## 2. One sentence, rewritten for Tendo

For Nia, I wrote: "The firewall also accepts remote login from any address on the internet, not only from our office, so the key is the only barrier."

For Tendo, I would write: "UFW allows 22/tcp from anywhere on IPv4 and IPv6. Auth is public-key only, with password login off and root login key-only, but that comes from the Ubuntu image defaults and isn't set in our Ansible."

The Nia version tells a board what it means: if one key is stolen, someone gets in. The Tendo version drops that. What it adds is the exact exposure, and it shows that the safe SSH settings come from the image and not from our code. An engineer reading it knows two things to do next: write those settings into Ansible, and restrict port 22 to known source addresses.

## 3. The most fragile handoff

I think it's the step from Terraform's output into the Ansible inventory and then the first SSH connection. It assumes the addresses Terraform reports are reachable from the machine running Ansible, that the servers have finished booting, that the key Terraform installed is the one Ansible uses, and that the login user is the same on every server. The addresses are not stable, which I saw first-hand: the api server was .178 before I tore everything down and .215 after I rebuilt it. On a real network this could break in several ways. Servers might boot slowly, there might be a jump host in front of them, addresses might only be reachable over a private network, or a different image might use a different default user.

To make it solid I would need to know how the servers are reached (directly or through a bastion), which user and key the image provides, whether addresses are fixed or assigned at random, and how long a server takes to become ready. With that I would add an explicit wait for SSH, use a dynamic inventory source instead of a generated file, and keep the key and user in one shared variable.
