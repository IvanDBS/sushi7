#!/bin/bash

# Set server details
SERVER="root@128.140.61.131"
DEPLOY_PATH="/opt/sushi7"

# Create necessary directories
ssh -i ~/.ssh/hetzner_key $SERVER "mkdir -p $DEPLOY_PATH"

# Copy application files
scp -i ~/.ssh/hetzner_key \
    .env.production \
    docker-compose.yml \
    Dockerfile \
    Gemfile \
    Gemfile.lock \
    config.ru \
    sushi7_backup.sql \
    $SERVER:$DEPLOY_PATH/

# Copy directories
scp -i ~/.ssh/hetzner_key -r \
    config \
    lib \
    db \
    $SERVER:$DEPLOY_PATH/

# Set up environment file
ssh -i ~/.ssh/hetzner_key $SERVER "cd $DEPLOY_PATH && mv .env.production .env"

# Start the application
ssh -i ~/.ssh/hetzner_key $SERVER "cd $DEPLOY_PATH && docker compose up -d"

echo "Deployment completed! Check the logs with:"
echo "ssh -i ~/.ssh/hetzner_key $SERVER 'cd $DEPLOY_PATH && docker compose logs -f'" 