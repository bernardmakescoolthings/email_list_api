#!/bin/bash

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker and Docker Compose
sudo apt-get install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Create .env file
cat > .env << EOL
POSTGRES_USER=emailapp
POSTGRES_PASSWORD=emailapp123
POSTGRES_DB=emaildb
DATABASE_URL=postgresql://emailapp:emailapp123@db:5432/emaildb
DB_HOST=db
DB_PORT=5432
DB_NAME=emaildb
DB_USER=emailapp
DB_PASSWORD=emailapp123
EOL

# Start the application
docker-compose up -d --build

# Create backup script
cat > backup_db.sh << EOL
#!/bin/bash
BACKUP_DIR="backups"
mkdir -p \$BACKUP_DIR
docker-compose exec -T db pg_dump -U emailapp emaildb > \$BACKUP_DIR/backup_\$(date +%Y%m%d_%H%M%S).sql
find \$BACKUP_DIR -type f -mtime +7 -delete
EOL

chmod +x backup_db.sh

# Add daily backup to crontab
(crontab -l 2>/dev/null; echo "0 0 * * * $(pwd)/backup_db.sh") | crontab - 