#!/bin/bash

# Login to Docker registry
docker login -u "$DOCKER_USER" -p "$DOCKER_PASSWORD"

# Array of PHP versions
versions=(8.0.30 8.1.29 8.2.20 8.3.8)

# Iterate through each version
for version in "${versions[@]}"; do
    # Extract major and minor version for image tag
    major_minor=$(echo "$version" | cut -d '.' -f1,2 | tr -d '.')

    # Define repository name
    REPOSITORY="${REPO}:php$major_minor"

    # Build and push image without xdebug
    docker build . --file php.Dockerfile \
        --build-arg PHP_VERSION="$version" \
        --build-arg NODE_VERSION=20 \
        --build-arg WITH_XDEBUG=false \
        --no-cache \
        --tag "$REPOSITORY" \
        --push

    # Build and push image with xdebug
    docker build . --file php.Dockerfile \
        --build-arg PHP_VERSION="$version" \
        --build-arg NODE_VERSION=20 \
        --build-arg WITH_XDEBUG=true \
        --no-cache \
        --tag "$REPOSITORY"-xdebug \
        --push
done
