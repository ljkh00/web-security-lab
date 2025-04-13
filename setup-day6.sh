#!/bin/bash
echo "Setting up Day 6: Secure Development Lifecycle and Best Practices"

# Reset volumes for final day
docker compose down
docker volume rm web-security-lab_sqldata || true

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

# Start all services
docker compose up -d

# Import a complete configuration with all vulnerabilities
if [ -f "./vulnerable-app/database/init-scripts/final-day-data.sql" ]; then
    echo "Importing comprehensive vulnerable configuration..."
    docker cp "./vulnerable-app/database/init-scripts/final-day-data.sql" $CONTAINER_NAME:/tmp/final-day-data.sql
    docker exec -i $CONTAINER_NAME /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "P@ssw0rd!" -d VulnerableApp -C -N -t 30 -b -e -i /tmp/final-day-data.sql
else
    echo "Final day data SQL file not found. Using basic configuration."
fi

echo "Day 6 environment is ready!"
echo "Access the vulnerable web application at: http://localhost:8080"
echo "Today's focus: Secure development lifecycle and implementing security best practices"
echo "This environment contains all previously introduced vulnerabilities for comprehensive hardening"