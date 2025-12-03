#!/bin/bash

set -e

echo "=================================================="
echo "🚀 Legal Integrity Analytics - Auto Installation"
echo "=================================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}❌ Không chạy script này với sudo/root!${NC}"
    echo "Chạy: bash install.sh"
    exit 1
fi

# Domain configuration
DOMAIN="legalintegrityanalytics.com"
EMAIL="admin@${DOMAIN}"

echo -e "${YELLOW}📋 Cấu hình:${NC}"
echo "   Domain: ${DOMAIN}"
echo "   Email: ${EMAIL}"
echo ""

# Function to check command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Update system
echo -e "${GREEN}[1/8] Cập nhật hệ thống...${NC}"
sudo apt update && sudo apt upgrade -y

# 2. Install Docker
if ! command_exists docker; then
    echo -e "${GREEN}[2/8] Cài đặt Docker...${NC}"
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo usermod -aG docker $USER
    echo -e "${YELLOW}⚠️  Đã thêm user vào docker group. Cần logout/login hoặc chạy: newgrp docker${NC}"
else
    echo -e "${GREEN}[2/8] Docker đã được cài đặt ✓${NC}"
fi

# 3. Install Docker Compose (standalone)
if ! command_exists docker-compose; then
    echo -e "${GREEN}[3/8] Cài đặt Docker Compose...${NC}"
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo -e "${GREEN}[3/8] Docker Compose đã được cài đặt ✓${NC}"
fi

# 4. Install Certbot
if ! command_exists certbot; then
    echo -e "${GREEN}[4/8] Cài đặt Certbot...${NC}"
    sudo apt install -y certbot
else
    echo -e "${GREEN}[4/8] Certbot đã được cài đặt ✓${NC}"
fi

# 5. Setup firewall
echo -e "${GREEN}[5/8] Cấu hình firewall...${NC}"
sudo ufw --force enable
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force reload

# 6. Create directories
echo -e "${GREEN}[6/8] Tạo thư mục cần thiết...${NC}"
mkdir -p Data
mkdir -p secrets
mkdir -p wwwroot
mkdir -p nginx/ssl

# 7. Get SSL certificate
echo -e "${GREEN}[7/8] Lấy SSL certificate...${NC}"
if [ ! -f "nginx/ssl/fullchain.pem" ]; then
    echo -e "${YELLOW}Đang lấy SSL certificate từ Let's Encrypt...${NC}"
    sudo certbot certonly --standalone \
        --preferred-challenges http \
        --agree-tos \
        --email ${EMAIL} \
        --non-interactive \
        -d ${DOMAIN} \
        -d www.${DOMAIN}
    
    # Copy certificates
    sudo cp /etc/letsencrypt/live/${DOMAIN}/fullchain.pem nginx/ssl/
    sudo cp /etc/letsencrypt/live/${DOMAIN}/privkey.pem nginx/ssl/
    sudo chown $USER:$USER nginx/ssl/*.pem
    sudo chmod 644 nginx/ssl/*.pem
    
    # Setup auto-renewal
    echo "0 0 * * * root certbot renew --quiet --deploy-hook 'cp /etc/letsencrypt/live/${DOMAIN}/*.pem $(pwd)/nginx/ssl/ && docker-compose restart nginx'" | sudo tee -a /etc/crontab > /dev/null
    
    echo -e "${GREEN}✓ SSL certificate đã được cài đặt${NC}"
else
    echo -e "${YELLOW}SSL certificate đã tồn tại, bỏ qua...${NC}"
fi

# 8. Start application
echo -e "${GREEN}[8/8] Khởi động ứng dụng...${NC}"
docker-compose down 2>/dev/null || true
docker-compose up -d --build

echo ""
echo "=================================================="
echo -e "${GREEN}✅ CÀI ĐẶT HOÀN TẤT!${NC}"
echo "=================================================="
echo ""
echo -e "${GREEN}🌐 Website:${NC} https://${DOMAIN}"
echo ""
echo -e "${YELLOW}📝 Lệnh hữu ích:${NC}"
echo "   Xem logs:        docker-compose logs -f web"
echo "   Restart:         docker-compose restart"
echo "   Stop:            docker-compose down"
echo "   Rebuild:         docker-compose up -d --build"
echo ""
echo -e "${YELLOW}⚠️  LƯU Ý BẢO MẬT:${NC}"
echo "   1. Đổi password PostgreSQL trong docker-compose.yml"
echo "   2. Đổi JWT keys trong appsettings.production.json"
echo "   3. Backup database định kỳ"
echo ""
echo -e "${GREEN}🎉 Truy cập: https://${DOMAIN}${NC}"
echo ""
