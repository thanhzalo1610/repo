# Legal Integrity Analytics - Production Setup

## 🚀 Cài đặt tự động (Khuyến nghị)

Chỉ cần chạy 1 lệnh duy nhất:

```bash
bash install.sh
```

Script sẽ tự động:
- ✅ Cài đặt Docker & Docker Compose
- ✅ Cài đặt Certbot
- ✅ Cấu hình firewall (UFW)
- ✅ Lấy SSL certificate từ Let's Encrypt
- ✅ Tự động gia hạn SSL
- ✅ Build và chạy ứng dụng
- ✅ Cấu hình Nginx reverse proxy

## 📋 Yêu cầu

- Ubuntu Server 18.04+ (hoặc Debian)
- Domain đã trỏ về IP server: `legalintegrityanalytics.com`
- Port 80, 443 mở (firewall sẽ tự động cấu hình)

## 🌐 Truy cập

Sau khi cài đặt xong:
- **Website:** https://legalintegrityanalytics.com
- **Chặn truy cập:** localhost, IP trực tiếp

## 🔧 Quản lý

### Xem logs
```bash
docker-compose logs -f web      # Application logs
docker-compose logs -f nginx    # Nginx logs
docker-compose logs -f postgres # Database logs
```

### Restart services
```bash
docker-compose restart web
docker-compose restart nginx
```

### Stop/Start
```bash
docker-compose down
docker-compose up -d
```

### Rebuild
```bash
docker-compose up -d --build
```

## 🔐 Bảo mật

### ⚠️ QUAN TRỌNG - Làm ngay sau khi cài đặt:

1. **Đổi password PostgreSQL:**
```bash
nano docker-compose.yml
# Tìm và đổi: POSTGRES_PASSWORD=Binh@123
```

2. **Đổi JWT keys:**
```bash
nano appsettings.production.json
# Tạo key mới: openssl rand -base64 32
```

3. **Đổi Security keys:**
```bash
nano appsettings.production.json
# Đổi: Security.ClientDataKey
```

4. **Tạo JWT RSA keys:**
```bash
# Private key
openssl genrsa -out secrets/jwt_rsa_priv.pem 2048

# Public key
openssl rsa -in secrets/jwt_rsa_priv.pem -pubout -out secrets/jwt_rsa_pub.pem

# Set permissions
chmod 600 secrets/jwt_rsa_priv.pem
chmod 644 secrets/jwt_rsa_pub.pem
```

## 💾 Backup Database

### Backup thủ công
```bash
docker exec legal-postgres pg_dump -U postgres MobileOasis_V1 > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Restore
```bash
cat backup.sql | docker exec -i legal-postgres psql -U postgres -d MobileOasis_V1
```

### Backup tự động (cron)
```bash
# Thêm vào crontab
crontab -e

# Backup mỗi ngày lúc 2h sáng
0 2 * * * cd /path/to/app && docker exec legal-postgres pg_dump -U postgres MobileOasis_V1 > backups/backup_$(date +\%Y\%m\%d).sql
```

## 🔄 Gia hạn SSL

SSL tự động gia hạn qua cron job. Kiểm tra:
```bash
sudo certbot renew --dry-run
```

Gia hạn thủ công:
```bash
sudo certbot renew
cp /etc/letsencrypt/live/legalintegrityanalytics.com/*.pem nginx/ssl/
docker-compose restart nginx
```

## 🐛 Troubleshooting

### Website không truy cập được
```bash
# Kiểm tra containers
docker-compose ps

# Kiểm tra logs
docker-compose logs nginx
docker-compose logs web

# Kiểm tra firewall
sudo ufw status

# Kiểm tra DNS
nslookup legalintegrityanalytics.com
```

### SSL certificate lỗi
```bash
# Xóa và lấy lại
sudo certbot delete --cert-name legalintegrityanalytics.com
bash install.sh
```

### Database connection error
```bash
# Kiểm tra PostgreSQL
docker exec legal-postgres pg_isready -U postgres

# Restart database
docker-compose restart postgres

# Xem logs
docker-compose logs postgres
```

### Reset toàn bộ (⚠️ MẤT DATA)
```bash
docker-compose down -v
rm -rf Data/*
docker-compose up -d --build
```

## 📊 Monitoring

### Kiểm tra resource usage
```bash
docker stats
```

### Kiểm tra disk space
```bash
df -h
docker system df
```

### Dọn dẹp Docker
```bash
# Xóa images không dùng
docker image prune -a

# Xóa volumes không dùng
docker volume prune

# Xóa tất cả không dùng
docker system prune -a --volumes
```

## 🔗 Thông tin kết nối

### Từ bên ngoài
- Website: https://legalintegrityanalytics.com
- Chặn: localhost, IP

### Từ server (debug)
- Web container: http://localhost (internal)
- PostgreSQL: postgres:5432 (internal network)

### Database credentials
- Host: postgres (trong Docker network)
- Database: MobileOasis_V1
- Username: postgres
- Password: (xem trong docker-compose.yml)

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra logs: `docker-compose logs -f`
2. Kiểm tra containers: `docker-compose ps`
3. Kiểm tra firewall: `sudo ufw status`
4. Kiểm tra DNS: `nslookup legalintegrityanalytics.com`
