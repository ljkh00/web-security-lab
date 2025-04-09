#!/bin/bash
echo "Setting up Day 6: Secure Development Lifecycle and Best Practices"

# Reset volumes for final day
docker compose down
docker volume rm web-security-lab_sqldata || true

# Start with fresh setup
docker compose up -d db

# Wait for database to be ready
echo "Waiting for database to initialize..."
sleep 15

# Start all services
docker compose up -d

# Import a complete configuration with all vulnerabilities
echo "Importing comprehensive vulnerable configuration..."
docker exec -i web-security-lab-db /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "P@ssw0rd!" -d VulnerableApp -C -N -t 30 -b -e -i /docker-entrypoint-initdb.d/final-day-data.sql

echo "Day 6 environment is ready!"
echo "Access the vulnerable web application at: http://localhost:8080"
echo "Today's focus: Secure development lifecycle and implementing security best practices"

echo "This environment contains all previously introduced vulnerabilities for comprehensive hardening"
