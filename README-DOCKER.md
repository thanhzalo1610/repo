# Hướng dẫn chạy trên Ubuntu Server với Docker

## Yêu cầu
- Ubuntu Server (18.04 trở lên)
- Docker và Docker Compose đã cài đặt

## Cài đặt Docker trên Ubuntu (nếu chưa có)

```bash
# Update package index
sudo apt update

# Install dependencies
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

## Chạy ứng dụng

### Cách 1: Sử dụng script tự động
```bash
chmod +x start.sh
./start.sh
```

### Cách 2: Chạy thủ công
```bash
# Tạo thư mục cần thiết
mkdir -p Data secrets wwwroot

# Build và start
docker-compose up -d --build

# Xem logs
docker-compose logs -f web
```

## Các lệnh hữu ích

```bash
# Xem trạng thái containers
docker-compose ps

# Xem logs
docker-compose logs -f web          # Web app logs
docker-compose logs -f postgres     # Database logs

# Restart services
docker-compose restart web
docker-compose restart postgres

# Stop tất cả
docker-compose down

# Stop và xóa volumes (cẩn thận - mất data!)
docker-compose down -v

# Vào container để debug
docker exec -it legal-web-app bash
docker exec -it legal-postgres psql -U postgres -d MobileOasis_V1
```

## Cấu hình

### Database
- Host: postgres (trong Docker network) hoặc localhost:5432 (từ host machine)
- Database: MobileOasis_V1
- Username: postgres
- Password: Binh@123

### Web Application
- URL: http://localhost:8080
- Environment: Production

## Troubleshooting

### Container không start được
```bash
# Xem logs chi tiết
docker-compose logs web

# Kiểm tra port đã bị chiếm chưa
sudo netstat -tulpn | grep 8080
sudo netstat -tulpn | grep 5432
```

### Database connection error
```bash
# Kiểm tra PostgreSQL đã sẵn sàng chưa
docker exec legal-postgres pg_isready -U postgres

# Vào database để kiểm tra
docker exec -it legal-postgres psql -U postgres -d MobileOasis_V1
```

### Reset database
```bash
docker-compose down
docker volume rm $(docker volume ls -q | grep postgres-data)
docker-compose up -d
```

## Bảo mật

**⚠️ QUAN TRỌNG:** Trước khi deploy production:

1. Đổi password PostgreSQL trong `docker-compose.yml`
2. Đổi JWT keys trong `appsettings.production.json`
3. Đổi Security.ClientDataKey
4. Bảo vệ thư mục `secrets/`
5. Cấu hình firewall:
```bash
sudo ufw allow 8080/tcp
sudo ufw enable
```

## Backup Database

```bash
# Backup
docker exec legal-postgres pg_dump -U postgres MobileOasis_V1 > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore
cat backup.sql | docker exec -i legal-postgres psql -U postgres -d MobileOasis_V1
```
