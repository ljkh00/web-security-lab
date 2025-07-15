#!/bin/bash
echo "Setting up Day 2: Input Validation and Preventing Injection Attacks"

# Stop services but preserve volumes
docker compose down

# Start the database first
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

# Add a product with SQL injection payload
docker exec -i $CONTAINER_NAME /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "P@ssw0rd!" -d VulnerableApp -Q "
INSERT INTO Products (Name, Description, Price, Category, ImageUrl)
VALUES ('Malicious Product', 'This product has a description with an SQL injection payload: '' OR 1=1 --', 19.99, 'Hacking', '/images/malicious.jpg');
"

# Start the web application
docker compose up -d web-security-lab

echo "Day 2 environment is ready!"
echo "Access the vulnerable web application at: http://localhost:8080"
echo "Today's focus: SQL Injection in Products search and Command Injection in Admin panel"
echo "Try searching for products with: ' OR 1=1 --"