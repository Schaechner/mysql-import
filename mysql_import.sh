#!/bin/bash

# Check MySQL connection
if mysql -V >/dev/null 2>&1; then
    echo "MySQL client is installed."
else
    echo "MySQL client is not installed. Please install MySQL client and try again."
    exit 1
fi

# Prompt for MySQL root password
read -sp 'Enter MySQL root password: ' MYSQL_ROOT_PASSWORD
echo

# Test MySQL connection
if mysql -u root -p$MYSQL_ROOT_PASSWORD -e ";" >/dev/null 2>&1; then
    echo -e "\033[0;32mConnection to MySQL server successful.\033[0m"
else
    echo -e "\033[0;31mFailed to connect to MySQL server. Please check your credentials and try again.\033[0m"
    exit 1
fi

# Prompt for SQL files (without .sql extension)
echo "Enter the names of the SQL files to import (without .sql extension), separated by spaces:"
read -a SQL_FILES

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Variable to track if there was any error
ERROR_OCCURRED=false

# Loop through each SQL file
for FILE_BASE in "${SQL_FILES[@]}"; do
    SQL_FILE="${FILE_BASE}.sql"  # Add .sql extension
    DB_NAME="${FILE_BASE}"  # Use the base name as the database name

    # Check if database exists
    DB_EXISTS=$(mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$DB_NAME'" --skip-column-names)
    if [ -z "$DB_EXISTS" ]; then
        echo "Creating database $DB_NAME..."
        if mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE $DB_NAME"; then
            echo "Database $DB_NAME created successfully."
        else
            echo -e "${RED}Error: Failed to create database $DB_NAME.${NC}"
            ERROR_OCCURRED=true
            continue
        fi
    fi

    echo "Importing $SQL_FILE into database $DB_NAME..."
    if mysql -u root -p$MYSQL_ROOT_PASSWORD $DB_NAME < $SQL_FILE; then
        echo "Import of $SQL_FILE into database $DB_NAME was successful."
    else
        echo -e "${RED}Error: Failed to import $SQL_FILE into database $DB_NAME.${NC}"
        ERROR_OCCURRED=true
    fi
done

# Final message
if [ "$ERROR_OCCURRED" = true ]; then
    echo -e "${RED}The process was not completed successfully due to an error.${NC}"
else
    echo -e "${GREEN}✔ All SQL files have been imported into their respective databases.${NC}"
fi

echo ""
echo "Copyright Schächner 2024"
