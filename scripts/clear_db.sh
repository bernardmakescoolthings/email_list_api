#!/bin/bash

# Stop the containers
docker-compose down

# Remove the PostgreSQL volume to clear all data
docker volume rm email_list_api_postgres_data

# Start the containers again
docker-compose up -d

echo "Database has been cleared and containers restarted." 