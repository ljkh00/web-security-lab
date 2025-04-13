#!/bin/bash
echo "Setting up Day 3: Authentication, Authorization, and Session Management"

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

# Add users with weak passwords for authentication exercises
docker exec -i $CONTAINER_NAME /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "P@ssw0rd!" -d VulnerableApp -Q "
-- Add users with weak passwords
IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'weakuser')
BEGIN
    INSERT INTO Users (Username, Password, Email, FullName, IsAdmin)
    VALUES ('weakuser', '123456', 'weak@example.com', 'Weak Password User', 0);
END

-- Add a user with administrative privileges for privilege escalation exercises
IF NOT EXISTS (SELECT * FROM Users WHERE Username = 'manager')
BEGIN
    INSERT INTO Users (Username, Password, Email, FullName, IsAdmin)
    VALUES ('manager', 'manager2023', 'manager@example.com', 'Department Manager', 0);
END
"

# Start the web application
docker compose up -d web-security-lab

echo "Day 3 environment is ready!"
echo "Access the vulnerable web application at: http://localhost:8080"
echo "Today's focus: Authentication vulnerabilities, session management, and authorization flaws"
echo "Additional test accounts:"
echo "  Weak password: weakuser / 123456"
echo "  Manager (for privilege escalation): manager / manager2023"