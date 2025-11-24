#!/bin/bash

# ============================================
# Squid Installer for Ubuntu
# Because why type 10 commands when you can
# run one suspicious shell script instead?
# ============================================
echo "‼️ You are running the unsafe version, and this will allow anyone to access your computer!"
# --- 1. Must be root -------------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "❌ ERROR: Run as root, you magnificent disaster."
    echo "   Try: sudo $0"
    exit 1
fi

echo "🔧 Running as root. Good job."

# --- 2. Update package list -------------------------------
echo "📦 Updating apt (because Ubuntu forgets stuff every 3 seconds)…"
apt update -y

# --- 3. Install Squid if needed ---------------------------
if ! command -v squid >/dev/null 2>&1; then
    echo "🦑 Squid not found. Summoning the Eldritch Proxy Beast…"
    apt install -y squid
else
    echo "🦑 Squid already installed. Calm your tentacles."
fi

# --- 4. Configure Squid -----------------------------------
echo "📁 Backing up original squid.conf (just in case you explode something)…"
cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

echo "📜 Writing new squid.conf…"

cat >/etc/squid/squid.conf << 'EOF'

http_port 3128
acl allowed src 0.0.0.0/0 # You asked for it
http_access allow allowed
http_access deny all

# Logs
access_log /var/log/squid/access.log
cache_log /var/log/squid/cache.log
EOF

echo "✔ squid.conf updated."

# --- 5. Enable + start Squid -------------------------------
echo "🚀 Starting Squid service…"
systemctl restart squid

echo "🔌 Enabling Squid on boot…"
systemctl enable squid

# --- 6. Check if Squid is alive ----------------------------
echo "🩺 Health check:"
if systemctl is-active --quiet squid; then
    echo "✅ Squid is ALIVE and wriggling on port 3128!"
else
    echo "💀 ERROR: Squid failed to start. Check logs:"
    echo "   /var/log/squid/cache.log"
    exit 1
fi

# --- 7. Logging info ----------------------------------------
echo "📜 Logs located at:"
echo "   /var/log/squid/access.log"
echo "   /var/log/squid/cache.log"

# --- 8. Final output ----------------------------------------
echo ""
echo "🎉 DONE!"
echo "Your proxy server is now active."
echo "Use it responsibly, or like a true menace. I'm not judging."
echo "Actually, other people will misuse it anyways."
