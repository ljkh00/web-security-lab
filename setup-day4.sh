#!/bin/bash
echo "Setting up Day 4: ASP.NET Security and Secure Communication"

# Stop services but preserve volumes
docker compose down

# Start the database
docker compose up -d db

# Wait for database to be ready
echo "Waiting for database to initialize..."
sleep 10

# Start the web application
docker compose up -d web-security-lab

# Generate a self-signed certificate for HTTPS exercises
echo "Generating self-signed certificate for HTTPS exercises..."
docker exec -i web-security-lab_web-security-lab_1 openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" \
    -keyout /app/server.key -out /app/server.cert

echo "Day 4 environment is ready!"
echo "Access the vulnerable web application at: http://localhost:8080"
echo "Today's focus: ASP.NET security features, HTTPS setup, and security headers"

echo "Certificate files have been generated in the application container for HTTPS exercises"
