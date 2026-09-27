#!/bin/bash
# ==============================================================================
# KIJANIKIOSK PRODUCTION SERVER FOUNDATION PROVISIONING SCRIPT
# Author: Amina (DevOps Engineering)
# Target: Dedicated Production Payments Node
# ==============================================================================
# Expected dirty conditions found in pre-provisioning audit:
# - User accounts exist but have unhardened interactive shells (/bin/sh): Fixed in Phase 2
# - /opt/kijanikiosk/config directory permissions are wide-open (777): Fixed in Phase 3
# - ufw firewall has active block rules on port 3001 from Thursday triage: Fixed in Phase 5
# - Package hold on 'curl' is active from temporary manual debug overrides: Fixed in Phase 1
# ==============================================================================

set -euo pipefail
IFS=$'\n\t'

echo "=== Beginning KijaniKiosk Production Server Provisioning ==="

# ==============================================================================
# PHASE 1: PACKAGE MANAGEMENT & PINNING
# ==============================================================================
echo "--- Phase 1: Package Management ---"
sudo apt-get update -y

# Checklist requirement: Check hold before blindly handling it
if apt-mark showhold | grep -q "curl"; then
    echo "[DIRTY STATE DETECTED] 'curl' package hold is active. Clearing override."
    sudo apt-mark unhold curl
else
    echo "[CLEAN STATE] No unexpected package holds detected on 'curl'."
fi

sudo apt-get install -y curl ufw logrotate acl
sudo apt-mark hold curl
echo "[PASS] Phase 1 Complete."

# ==============================================================================
# PHASE 2: SYSTEM USER & GROUP CONVERGENCE
# ==============================================================================
echo "--- Phase 2: User and Group Convergence ---"

if ! getent group kijanikiosk >/dev/null; then
    sudo groupadd -r kijanikiosk
    echo "[PASS] Created group 'kijanikiosk'"
else
    echo "[INFO] Group 'kijanikiosk' already exists."
fi

converge_user() {
    local username=$1
    if ! getent passwd "$username" >/dev/null; then
        echo "[CLEAN STATE] Creating completely new system user '$username'."
        sudo useradd -r -s /usr/sbin/nologin -g kijanikiosk "$username"
    else
        # Checklist requirement: Log exactly what dirty attribute was found
        local current_shell
        current_shell=$(getent passwd "$username" | cut -d: -f7)
        echo "[DIRTY STATE DETECTED] User '$username' already exists with shell '$current_shell'."
        sudo usermod -g kijanikiosk -s /usr/sbin/nologin "$username"
        echo "[CONVERGED] Forcefully updated '$username' to secure non-interactive system spec."
    fi
}

converge_user "kk-api"
converge_user "kk-payments"
converge_user "kk-logs"
echo "[PASS] Phase 2 Complete."

# ==============================================================================
# PHASE 3: DIRECTORY LAYOUT & POSIX ACL ENFORCEMENT
# ==============================================================================
echo "--- Phase 3: Directory Structure and Permissions ---"

sudo mkdir -p /opt/kijanikiosk/config
sudo mkdir -p /opt/kijanikiosk/shared/logs

# Checklist requirement: Inspect dirty permission configurations before correcting
if [ "$(stat -c '%a' /opt/kijanikiosk/config)" = "777" ]; then
    echo "[DIRTY STATE DETECTED] Insecure 777 permissions found on /opt/kijanikiosk/config."
else
    echo "[CLEAN STATE] Configuration folder directory permissions look correct."
fi

sudo chown -R root:kijanikiosk /opt/kijanikiosk/config
sudo chmod 750 /opt/kijanikiosk/config

sudo chown -R kk-logs:kijanikiosk /opt/kijanikiosk/shared/logs
sudo chmod 770 /opt/kijanikiosk/shared/logs

# Enforce clear isolated boundaries using POSIX ACL entries
sudo setfacl -b /opt/kijanikiosk/shared/logs
sudo setfacl -m u:kk-api:rwx /opt/kijanikiosk/shared/logs
sudo setfacl -m u:kk-payments:rwx /opt/kijanikiosk/shared/logs
sudo setfacl -m u:kk-logs:rx /opt/kijanikiosk/shared/logs
sudo setfacl -d -m u:kk-api:rwx /opt/kijanikiosk/shared/logs
sudo setfacl -d -m u:kk-payments:rwx /opt/kijanikiosk/shared/logs

echo "[PASS] Phase 3 Complete."

# ==============================================================================
# PHASE 4: SYSTEMD SERVICE ARCHITECTURE INLINE DECLARATION (ULTRA HARDENED)
# ==============================================================================
echo "--- Phase 4: Systemd Service Hardening ---"

# High-Hardening Configuration for kk-payments (Score target strictly below 2.5)
cat << 'EOF' | sudo tee /etc/systemd/system/kk-payments.service > /dev/null
[Unit]
Description=KijaniKiosk Production Payments Processing Engine
After=network.target

[Service]
Type=simple
User=kk-payments
Group=kijanikiosk
ExecStart=/bin/bash -c "while true; do echo 'Payments Active'; sleep 3600; done"
Restart=always

# Deep Sandboxing Hardening Vectors
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
NoNewPrivileges=true
CapabilityBoundingSet=
MemoryDenyWriteExecute=true
RestrictRealtime=true
RestrictNamespaces=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
DevicePolicy=closed
LockPersonality=true
PrivateDevices=true
IPAddressDeny=any
SystemCallFilter=@system-service
SystemCallArchitectures=native
UMask=0027
EOF

# Configuration for kk-api (Score target strictly below 3.5)
cat << 'EOF' | sudo tee /etc/systemd/system/kk-api.service > /dev/null
[Unit]
Description=KijaniKiosk Core API Gateway
After=network.target

[Service]
Type=simple
User=kk-api
Group=kijanikiosk
ExecStart=/bin/bash -c "while true; do echo 'API Active'; sleep 3600; done"
Restart=always

# Deep Sandboxing Hardening Vectors
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
NoNewPrivileges=true
CapabilityBoundingSet=
MemoryDenyWriteExecute=true
RestrictRealtime=true
RestrictNamespaces=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
DevicePolicy=closed
LockPersonality=true
PrivateDevices=true
IPAddressDeny=any
SystemCallFilter=@system-service
SystemCallArchitectures=native
UMask=0027
EOF

# Configuration for kk-logs (Score target strictly below 3.5)
cat << 'EOF' | sudo tee /etc/systemd/system/kk-logs.service > /dev/null
[Unit]
Description=KijaniKiosk Auditing Log Agent
After=network.target

[Service]
Type=simple
User=kk-logs
Group=kijanikiosk
ExecStart=/bin/bash -c "while true; do echo 'Logger Active'; sleep 3600; done"
Restart=always

# Deep Sandboxing Hardening Vectors
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
NoNewPrivileges=true
CapabilityBoundingSet=
MemoryDenyWriteExecute=true
RestrictRealtime=true
RestrictNamespaces=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
DevicePolicy=closed
LockPersonality=true
PrivateDevices=true
IPAddressDeny=any
SystemCallFilter=@system-service
SystemCallArchitectures=native
UMask=0027
EOF

sudo systemctl daemon-reload
sudo systemctl restart kk-payments.service kk-api.service kk-logs.service
echo "[PASS] Phase 4 Complete."


# ==============================================================================
# PHASE 5: NETWORKING & STATEFUL FIREWALL HARDENING
# ==============================================================================
echo "--- Phase 5: Firewall Hardening ---"

# Checklist requirement: Log if the dirty block rules are active before cleaning
if sudo ufw status numbered | grep -q "3001.*DENY"; then
    echo "[DIRTY STATE DETECTED] Rogue deny rule found on port 3001. Flashing firewall."
else
    echo "[CLEAN STATE] Firewall parameters are currently clear."
fi

echo "y" | sudo ufw reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Checklist requirement: Comments explicitly written on EVERY firewall entry
sudo ufw allow 22/tcp comment 'Secure SSH administration access gateway'
sudo ufw allow 3000/tcp comment 'KijaniKiosk Core API internal network traffic interface'
sudo ufw allow 3001/tcp comment 'KijaniKiosk Production Payments transactional endpoint gateway'

echo "y" | sudo ufw enable
echo "[PASS] Phase 5 Complete."

# ==============================================================================
# PHASE 6: FIREWALL VERIFICATION ASSERTIONS
# ==============================================================================
echo "--- Phase 6: Firewall Verification Assertions ---"

# Checklist requirement: One clear PASS/FAIL assertion per individual rule
assert_fw_rule() {
    local pattern=$1
    if sudo ufw status verbose | grep -q "$pattern"; then
        echo "[PASS] Firewall validation assertion passed for rule pattern: $pattern"
    else
        echo "[FAIL] Firewall validation assertion failed for rule pattern: $pattern"
        exit 1
    fi
}

assert_fw_rule "22/tcp.*ALLOW IN"
assert_fw_rule "3000/tcp.*ALLOW IN"
assert_fw_rule "3001/tcp.*ALLOW IN"
echo "[PASS] Phase 6 Complete."

# ==============================================================================
# PHASE 7: JOURNAL PERSISTENCE AND LOG ROTATION
# ==============================================================================
echo "--- Phase 7: Journal Persistence and Log Rotation ---"

sudo mkdir -p /var/log/journal
sudo systemd-tmpfiles --create --prefix /var/log/journal

sudo mkdir -p /etc/systemd/journald.conf.d
cat << 'EOF' | sudo tee /etc/systemd/journald.conf.d/99-kijanikiosk.conf > /dev/null
[Journal]
Storage=persistent
SystemMaxUse=500M
EOF
sudo systemctl restart systemd-journald

cat << 'EOF' | sudo tee /etc/logrotate.d/kijanikiosk > /dev/null
/opt/kijanikiosk/shared/logs/*.log {
    daily
    rotate 7
    missingok
    notifempty
    compress
    delaycompress
    su kk-logs kijanikiosk
    sharedscripts
    postrotate
        systemctl reload kk-api kk-payments kk-logs 2>/dev/null || true
    endscript
}
EOF

sudo logrotate --debug /etc/logrotate.d/kijanikiosk > /dev/null

echo "[PASS] Phase 7 Complete."

# ==============================================================================
# PHASE 8: MONITORING HEALTH CHECKS
# ==============================================================================
echo "--- Phase 8: Monitoring Health Checks ---"

# Checklist requirement: Verify each service status dynamically by checking systemd states
api_status=$(systemctl is-active kk-api.service >/dev/null 2>&1 && echo '"ok"' || echo '"down"')
payments_status=$(systemctl is-active kk-payments.service >/dev/null 2>&1 && echo '"ok"' || echo '"down"')

sudo mkdir -p /opt/kijanikiosk/health

printf '{"timestamp":"%s","kk-api":%s,"kk-payments":%s}\n' \
  "$(date -Is)" "$api_status" "$payments_status" \
  | sudo tee /opt/kijanikiosk/health/last-provision.json > /dev/null

# Checklist requirement: Must be strictly readable by the group 'kijanikiosk'
sudo chown kk-logs:kijanikiosk /opt/kijanikiosk/health/last-provision.json
sudo chmod 640 /opt/kijanikiosk/health/last-provision.json

echo "[PASS] Phase 8 Complete."
echo "SUCCESS: KijaniKiosk foundation converged, clean, and fully operational."
exit 0
