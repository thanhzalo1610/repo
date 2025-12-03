# Legal Integrity Analytics

ASP.NET Core 8 Web Application chạy trên Ubuntu Server với domain `legalintegrityanalytics.com`

## 🚀 Cài đặt tự động

Trên Ubuntu Server, chỉ cần chạy 1 lệnh:

```bash
bash install-ubuntu.sh
```

Script sẽ tự động:
- ✅ Cài đặt .NET 8 Runtime
- ✅ Cài đặt PostgreSQL
- ✅ Cài đặt Nginx
- ✅ Cài đặt Certbot (SSL)
- ✅ Cấu hình firewall
- ✅ Lấy SSL certificate từ Let's Encrypt
- ✅ Tạo systemd service
- ✅ Generate JWT RSA keys
- ✅ Cấu hình Nginx reverse proxy
- ✅ Tự động gia hạn SSL

## 📋 Yêu cầu

- Ubuntu Server 18.04+ (hoặc Debian)
- Domain đã trỏ về IP server: `legalintegrityanalytics.com`
- Port 80, 443 mở

## 🌐 Truy cập

Sau khi cài đặt:
- **Website:** https://legalintegrityanalytics.com
- **Chặn:** localhost, IP trực tiếp

## 🔧 Quản lý

### Sử dụng script quản lý (khuyến nghị)
```bash
bash manage.sh
```

### Quản lý thủ công

**Application:**
```bash
# Xem status
sudo systemctl status legalapp

# Xem logs
sudo journalctl -u legalapp -f

# Restart
sudo systemctl restart legalapp

# Stop/Start
sudo systemctl stop legalapp
sudo systemctl start legalapp
```

**Nginx:**
```bash
# Restart
sudo systemctl restart nginx

# Test config
sudo nginx -t

# Xem logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

**Database:**
```bash
# Connect
sudo -u postgres psql -d MobileOasis_V1

# Backup
sudo -u postgres pg_dump MobileOasis_V1 > backup_$(date +%Y%m%d).sql

# Restore
sudo -u postgres psql -d MobileOasis_V1 < backup.sql
```

## 📁 Cấu trúc

```
/var/www/legalapp/          # Application directory
├── Cms.Legal.Web.dll       # Main application
├── appsettings.json        # Configuration
├── appsettings.production.json
├── Data/                   # Application data
├── secrets/                # JWT keys
│   ├── jwt_rsa_priv.pem
│   └── jwt_rsa_pub.pem
└── wwwroot/                # Static files
```

## 🔐 Bảo mật

### ⚠️ QUAN TRỌNG - Làm ngay sau khi cài đặt:

1. **Đổi password PostgreSQL:**
```bash
sudo -u postgres psql
ALTER USER postgres WITH PASSWORD 'new_password';
\q

# Update appsettings.production.json
sudo nano /var/www/legalapp/appsettings.production.json
```

2. **Đổi JWT keys:**
```bash
# Generate new key
openssl rand -base64 32

# Update appsettings.production.json
sudo nano /var/www/legalapp/appsettings.production.json
```

3. **Regenerate JWT RSA keys:**
```bash
cd /var/www/legalapp
sudo openssl genrsa -out secrets/jwt_rsa_priv.pem 2048
sudo openssl rsa -in secrets/jwt_rsa_priv.pem -pubout -out secrets/jwt_rsa_pub.pem
sudo chmod 600 secrets/jwt_rsa_priv.pem
sudo chmod 644 secrets/jwt_rsa_pub.pem
sudo chown www-data:www-data secrets/*.pem
sudo systemctl restart legalapp
```

## 🔄 Update Application

```bash
cd /path/to/repo
git pull origin main
bash manage.sh
# Chọn option 8 (Update application)
```

## 💾 Backup tự động

Thêm vào crontab:
```bash
crontab -e

# Backup mỗi ngày lúc 2h sáng
0 2 * * * cd /var/www/legalapp && sudo -u postgres pg_dump MobileOasis_V1 > /backups/backup_$(date +\%Y\%m\%d).sql
```

## 🐛 Troubleshooting

### Website không truy cập được
```bash
# Kiểm tra service
sudo systemctl status legalapp
sudo systemctl status nginx

# Xem logs
sudo journalctl -u legalapp -f
sudo tail -f /var/log/nginx/error.log

# Kiểm tra firewall
sudo ufw status

# Kiểm tra DNS
nslookup legalintegrityanalytics.com
```

### Application không start
```bash
# Xem logs chi tiết
sudo journalctl -u legalapp -n 100 --no-pager

# Kiểm tra .NET runtime
dotnet --info

# Kiểm tra permissions
ls -la /var/www/legalapp
```

### Database connection error
```bash
# Kiểm tra PostgreSQL
sudo systemctl status postgresql

# Test connection
sudo -u postgres psql -d MobileOasis_V1

# Xem logs
sudo tail -f /var/log/postgresql/postgresql-*.log
```

### SSL certificate lỗi
```bash
# Gia hạn thủ công
sudo certbot renew

# Xem thông tin cert
sudo certbot certificates

# Lấy lại cert
sudo certbot delete --cert-name legalintegrityanalytics.com
sudo certbot certonly --nginx -d legalintegrityanalytics.com -d www.legalintegrityanalytics.com
```

## 📊 Monitoring

```bash
# CPU/Memory usage
htop

# Disk usage
df -h

# Application logs
sudo journalctl -u legalapp --since "1 hour ago"

# Nginx access logs
sudo tail -f /var/log/nginx/access.log
```

## 🔗 Thông tin

- **Application:** /var/www/legalapp
- **Service:** legalapp.service
- **Nginx config:** /etc/nginx/sites-available/legalapp
- **SSL certs:** /etc/letsencrypt/live/legalintegrityanalytics.com/
- **Database:** MobileOasis_V1
- **Port:** 5000 (internal), 80/443 (external)
