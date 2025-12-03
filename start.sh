#!/bin/bash

set -e

echo "🚀 Starting Legal Integrity Analytics..."

# Check if SSL certificates exist
if [ ! -f "nginx/ssl/fullchain.pem" ]; then
    echo "❌ SSL certificates không tồn tại!"
    echo "Chạy: bash install.sh để cài đặt đầy tiên"
    exit 1
fi

# Create directories if not exist
mkdir -p Data
mkdir -p secrets
mkdir -p wwwroot

# Build and start containers
docker-compose up -d --build

echo ""
echo "✅ Application started!"
echo "🌐 Website: https://legalintegrityanalytics.com"
echo ""
echo "📝 Xem logs:"
echo "   docker-compose logs -f web"
echo "   docker-compose logs -f nginx"
echo ""
echo "🛑 Dừng:"
echo "   docker-compose down"
