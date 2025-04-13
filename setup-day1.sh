#!/bin/bash
echo "Setting up Day 1: Introduction to Web Application Security and OWASP Top 10"

# Reset environment completely
docker compose down
docker volume rm web-security-lab_sqldata || true
docker volume rm web-security-lab_security-reports || true

# Start with fresh setup
docker compose up -d db

# Wait for database to be ready
echo "Waiting for SQL Server to start..."
sleep 15

# Initialize the database
echo "Initializing database..."
INIT_SQL_PATH="./vulnerable-app/database/init-scripts/init.sql"

# Copy the SQL file to container
CONTAINER_NAME=$(docker compose ps -q db)
if [ -z "$CONTAINER_NAME" ]; then
    echo "Database container not found. Make sure it's running."
    exit 1
fi

docker cp "$INIT_SQL_PATH" $CONTAINER_NAME:/tmp/init.sql

# Execute the SQL script
docker exec -i $CONTAINER_NAME /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "P@ssw0rd!" -C -N -t 30 -b -e -i /tmp/init.sql

# Verify database was created
echo "Verifying database was created..."
docker exec -i $CONTAINER_NAME /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "P@ssw0rd!" -C -Q "SELECT name FROM sys.databases WHERE name = 'VulnerableApp'"

# Start the web application with basic vulnerabilities
docker compose up -d web-security-lab

# Print access information
echo "Day 1 environment is ready!"
echo "Access the vulnerable web application at: http://localhost:8080"
echo "Login credentials:"
echo "  Regular user: john / password123"
echo "  Admin user: admin / admin123"
echo "Today's focus: OWASP Top 10 vulnerabilities identification"