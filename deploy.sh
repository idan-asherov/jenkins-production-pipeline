#!/bin/bash
set -e

echo "=== Starting Blue-Green Deployment ==="

# Create network if it doesn't exist
docker network create bg-network 2>/dev/null || true

# Check which environment is currently running
if docker ps -q -f name=blue-api | grep -q .; then
    CURRENT="blue"
    NEW="green"
else
    CURRENT="green"
    NEW="blue"
fi

echo "Active environment is $CURRENT. Deploying $NEW..."
export COMPOSE_PROJECT_NAME=$NEW

# Build the NEW environment using docker-compose
echo "Building Docker images for $NEW with build number: $BUILD_NUMBER and commit: $GIT_COMMIT_SHORT"
docker-compose build --no-cache

# Start the NEW environment in background
docker-compose up -d

echo "Waiting for $NEW to spin up (10 seconds)..."
sleep 10

# Ensure Nginx router container is running safely
if ! docker ps -q -f name=nginx-router | grep -q .; then
    echo "Starting initial Nginx router..."
    docker rm -f nginx-router 2>/dev/null || true
    touch nginx.conf
    cat << 'CONF' > nginx.conf
events {}
http {
    server {
        listen 80;
        location / { return 503 '{"error": "Starting up..."}'; }
    }
}
CONF
    docker run -d --name nginx-router -p 8000:80 --network bg-network -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf nginx:alpine
fi

# Run Health Check against the newly spun up API container
echo "Running health check on $NEW api service..."
HEALTH_CHECK=$(docker exec nginx-router curl -s -o /dev/null -w "%{http_code}" http://${NEW}-api-1:3000/health || echo "failed")

if [ "$HEALTH_CHECK" != "200" ]; then
    echo "❌ Health check failed for $NEW (Status: $HEALTH_CHECK). Rolling back!"
    docker-compose -p $NEW down
    exit 1
fi

echo "✅ Health check passed! Switching traffic to $NEW..."
cat << CONF > nginx.conf
events {}
http {
    server {
        listen 80;
        location / {
            proxy_pass http://${NEW}-api-1:3000;
        }
    }
}
CONF

# Swap traffic with Zero Downtime
docker cp nginx.conf nginx-router:/etc/nginx/nginx.conf
docker exec nginx-router nginx -s reload

# Tear down the old environment safely
if [ "$CURRENT" != "$NEW" ] && docker ps -q -f name=${CURRENT}-api | grep -q .; then
    echo "Tearing down old environment ($CURRENT)..."
    docker-compose -p $CURRENT down || true
fi

echo "🚀 Blue-Green Deployment completed successfully!"