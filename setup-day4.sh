#!/bin/bash
echo "Setting up Day 4: ASP.NET Security and Secure Communication"

# Stop services but preserve volumes
docker compose down

# Start the database
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

# Start the web application
docker compose up -d web-security-lab

# Generate a self-signed certificate for HTTPS exercises
echo "Generating self-signed certificate for HTTPS exercises..."
WEB_CONTAINER_NAME=$(docker compose ps -q web-security-lab)
docker exec -i $WEB_CONTAINER_NAME openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" \
    -keyout /app/server.key -out /app/server.cert

echo "Day 4 environment is ready!"
echo "Access the vulnerable web application at: http://localhost:8080"
echo "Today's focus: ASP.NET security features, HTTPS setup, and security headers"
echo "Certificate files have been generated in the application container for HTTPS exercises"