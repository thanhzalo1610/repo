#!/bin/bash

echo "🔐 Generating JWT RSA Keys..."

# Create secrets directory if not exists
mkdir -p secrets

# Generate private key
openssl genrsa -out secrets/jwt_rsa_priv.pem 2048

# Generate public key from private key
openssl rsa -in secrets/jwt_rsa_priv.pem -pubout -out secrets/jwt_rsa_pub.pem

# Set proper permissions
chmod 600 secrets/jwt_rsa_priv.pem
chmod 644 secrets/jwt_rsa_pub.pem

echo "✅ JWT RSA keys generated successfully!"
echo "   Private key: secrets/jwt_rsa_priv.pem"
echo "   Public key:  secrets/jwt_rsa_pub.pem"
