#!/bin/bash

set -e

echo "=========================================================="
echo "🚀 Legal Integrity Analytics - Ubuntu Native Installation"
echo "=========================================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}❌ Không chạy script này với sudo/root!${NC}"
    echo "Chạy: bash install-ubuntu.sh"
    exit 1
fi

# Configuration
DOMAIN="legalintegrityanalytics.com"
EMAIL="admin@${DOMAIN}"
APP_DIR="/var/www/legalapp"
APP_USER="www-data"

echo -e "${YELLOW}📋 Cấu hình:${NC}"
echo "   Domain: ${DOMAIN}"
echo "   Email: ${EMAIL}"
echo "   App Directory: ${APP_DIR}"
echo ""

# 1. Update system
echo -e "${GREEN}[1/10] Cập nhật hệ thống...${NC}"
sudo apt update && sudo apt upgrade -y

# 2. Install .NET 8 Runtime
echo -e "${GREEN}[2/10] Cài đặt .NET 8 Runtime...${NC}"
if ! command -v dotnet &> /dev/null; then
    wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    sudo apt update
    sudo apt install -y aspnetcore-runtime-8.0
else
    echo -e "${YELLOW}.NET already installed${NC}"
fi

# 3. Install PostgreSQL
echo -e "${GREEN}[3/10] Cài đặt PostgreSQL...${NC}"
if ! command -v psql &> /dev/null; then
    sudo apt install -y postgresql postgresql-contrib
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
else
    echo -e "${YELLOW}PostgreSQL already installed${NC}"
fi

# 4. Setup PostgreSQL database
echo -e "${GREEN}[4/10] Cấu hình PostgreSQL database...${NC}"
sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname = 'MobileOasis_V1'" | grep -q 1 || \
sudo -u postgres psql <<EOF
CREATE DATABASE "MobileOasis_V1";
CREATE USER postgres WITH PASSWORD 'Binh@123';
GRANT ALL PRIVILEGES ON DATABASE "MobileOasis_V1" TO postgres;
ALTER DATABASE "MobileOasis_V1" OWNER TO postgres;
EOF

# 5. Install Nginx
echo -e "${GREEN}[5/10] Cài đặt Nginx...${NC}"
if ! command -v nginx &> /dev/null; then
    sudo apt install -y nginx
else
    echo -e "${YELLOW}Nginx already installed${NC}"
fi

# 6. Install Certbot
echo -e "${GREEN}[6/10] Cài đặt Certbot...${NC}"
if ! command -v certbot &> /dev/null; then
    sudo apt install -y certbot python3-certbot-nginx
else
    echo -e "${YELLOW}Certbot already installed${NC}"
fi

# 7. Setup firewall
echo -e "${GREEN}[7/10] Cấu hình firewall...${NC}"
sudo ufw --force enable
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 5432/tcp
sudo ufw --force reload

# 8. Create app directory and copy files
echo -e "${GREEN}[8/10] Setup application...${NC}"
sudo mkdir -p ${APP_DIR}
sudo cp -r . ${APP_DIR}/
sudo chown -R ${APP_USER}:${APP_USER} ${APP_DIR}

# Create necessary directories
sudo mkdir -p ${APP_DIR}/Data
sudo mkdir -p ${APP_DIR}/secrets
sudo mkdir -p ${APP_DIR}/wwwroot
sudo chown -R ${APP_USER}:${APP_USER} ${APP_DIR}

# Generate JWT keys if not exist
if [ ! -f "${APP_DIR}/secrets/jwt_rsa_priv.pem" ]; then
    echo -e "${YELLOW}🔐 Generating JWT RSA keys...${NC}"
    sudo openssl genrsa -out ${APP_DIR}/secrets/jwt_rsa_priv.pem 2048
    sudo openssl rsa -in ${APP_DIR}/secrets/jwt_rsa_priv.pem -pubout -out ${APP_DIR}/secrets/jwt_rsa_pub.pem
    sudo chmod 600 ${APP_DIR}/secrets/jwt_rsa_priv.pem
    sudo chmod 644 ${APP_DIR}/secrets/jwt_rsa_pub.pem
    sudo chown ${APP_USER}:${APP_USER} ${APP_DIR}/secrets/*.pem
    echo -e "${GREEN}✓ JWT keys generated:${NC}"
    echo -e "   - ${APP_DIR}/secrets/jwt_rsa_priv.pem"
    echo -e "   - ${APP_DIR}/secrets/jwt_rsa_pub.pem"
else
    echo -e "${GREEN}✓ JWT keys already exist, skipping...${NC}"
fi

# 9. Create systemd service
echo -e "${GREEN}[9/10] Tạo systemd service...${NC}"
sudo tee /etc/systemd/system/legalapp.service > /dev/null <<EOF
[Unit]
Description=Legal Integrity Analytics Web Application
After=network.target postgresql.service

[Service]
Type=notify
WorkingDirectory=${APP_DIR}
ExecStart=/usr/bin/dotnet ${APP_DIR}/Cms.Legal.Web.dll
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=legalapp
User=${APP_USER}
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false
Environment=ASPNETCORE_URLS=http://localhost:5000

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
sudo systemctl daemon-reload
sudo systemctl enable legalapp
sudo systemctl start legalapp

# 10. Configure Nginx
echo -e "${GREEN}[10/10] Cấu hình Nginx...${NC}"

# Get SSL certificate
if [ ! -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]; then
    echo -e "${YELLOW}Lấy SSL certificate từ Let's Encrypt...${NC}"
    sudo certbot certonly --nginx \
        --agree-tos \
        --email ${EMAIL} \
        --non-interactive \
        -d ${DOMAIN} \
        -d www.${DOMAIN}
fi

# Create Nginx config
sudo tee /etc/nginx/sites-available/legalapp > /dev/null <<'NGINXCONF'
# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name legalintegrityanalytics.com www.legalintegrityanalytics.com;
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS Server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name legalintegrityanalytics.com www.legalintegrityanalytics.com;

    ssl_certificate /etc/letsencrypt/live/legalintegrityanalytics.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/legalintegrityanalytics.com/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    client_max_body_size 100M;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_buffering off;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://localhost:5000;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}

# Block access by IP or other domains
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    listen 443 ssl http2 default_server;
    listen [::]:443 ssl http2 default_server;
    server_name _;
    
    ssl_certificate /etc/letsencrypt/live/legalintegrityanalytics.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/legalintegrityanalytics.com/privkey.pem;
    
    return 444;
}
NGINXCONF

# Enable site
sudo ln -sf /etc/nginx/sites-available/legalapp /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
sudo nginx -t
sudo systemctl restart nginx

# Setup auto-renewal for SSL
echo "0 0 * * * root certbot renew --quiet --post-hook 'systemctl reload nginx'" | sudo tee -a /etc/crontab > /dev/null

echo ""
echo "=========================================================="
echo -e "${GREEN}✅ CÀI ĐẶT HOÀN TẤT!${NC}"
echo "=========================================================="
echo ""
echo -e "${GREEN}🌐 Website:${NC} https://${DOMAIN}"
echo ""
echo -e "${YELLOW}📝 Quản lý service:${NC}"
echo "   Xem status:      sudo systemctl status legalapp"
echo "   Xem logs:        sudo journalctl -u legalapp -f"
echo "   Restart:         sudo systemctl restart legalapp"
echo "   Stop:            sudo systemctl stop legalapp"
echo "   Start:           sudo systemctl start legalapp"
echo ""
echo -e "${YELLOW}📝 Quản lý Nginx:${NC}"
echo "   Restart:         sudo systemctl restart nginx"
echo "   Xem logs:        sudo tail -f /var/log/nginx/error.log"
echo "   Test config:     sudo nginx -t"
echo ""
echo -e "${YELLOW}📝 Database:${NC}"
echo "   Connect:         sudo -u postgres psql -d MobileOasis_V1"
echo "   Backup:          sudo -u postgres pg_dump MobileOasis_V1 > backup.sql"
echo ""
echo -e "${YELLOW}⚠️  LƯU Ý BẢO MẬT:${NC}"
echo "   1. Đổi password PostgreSQL"
echo "   2. Đổi JWT keys trong appsettings.production.json"
echo "   3. Backup database định kỳ"
echo ""
echo -e "${GREEN}🎉 Truy cập: https://${DOMAIN}${NC}"
echo ""
