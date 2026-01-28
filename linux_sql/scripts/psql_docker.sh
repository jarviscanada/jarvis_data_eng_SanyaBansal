#!/bin/sh

# =========================
# psql_docker.sh
# Manage PostgreSQL Docker container
# =========================

# Constants
CONTAINER_NAME="jrvs-psql"
VOLUME_NAME="pgdata"
IMAGE_NAME="postgres:9.6-alpine"

# Capture CLI arguments
cmd=$1
db_username=$2
db_password=$3

# Ensure Docker is running
sudo systemctl status docker >/dev/null 2>&1 || sudo systemctl start docker

# Check if container exists
docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1
container_status=$?

case "$cmd" in
  create)
    # Check if container already exists
    if [ $container_status -eq 0 ]; then
      echo "Error: Container already exists"
      exit 1
    fi

    # Validate arguments
    if [ $# -ne 3 ]; then
      echo "Error: create requires db_username and db_password"
      exit 1
    fi

    # Create Docker volume (idempotent)
    docker volume create "$VOLUME_NAME"

    # Create and run PostgreSQL container
    docker run --name "$CONTAINER_NAME" \
      -e POSTGRES_USER="$db_username" \
      -e POSTGRES_PASSWORD="$db_password" \
      -d \
      -v "$VOLUME_NAME":/var/lib/postgresql/data \
      -p 5432:5432 \
      "$IMAGE_NAME"

    exit $?
    ;;

  start)
    # Check if container exists
    if [ $container_status -ne 0 ]; then
      echo "Error: Container does not exist"
      exit 1
    fi

    docker container start "$CONTAINER_NAME"
    exit $?
    ;;

  stop)
    # Check if container exists
    if [ $container_status -ne 0 ]; then
      echo "Error: Container does not exist"
      exit 1
    fi

    docker container stop "$CONTAINER_NAME"
    exit $?
    ;;

  *)
    echo "Illegal command"
    echo "Usage: ./psql_docker.sh create|start|stop [db_username] [db_password]"
    exit 1
    ;;
esac 
