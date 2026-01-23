#!/bin/bash

# Authenticate with Docker registry
docker login -u "$DOCKER_USER" -p "$DOCKER_PASSWORD"

# PHP versions to build images for
versions=(8.0.30 8.1.34 8.2.30 8.3.30 8.4.17 8.5.2)

for version in "${versions[@]}"; do
    # Extract major.minor (e.g., 8.3.30 -> 8.3) and format tag (e.g., php83)
    major_minor=${version%.*}
    tag="${REPO}:php${major_minor/./}"

    # Build two variants: standard and with xdebug
    for xdebug in false true; do
        suffix=$([[ $xdebug == true ]] && echo "-xdebug" || echo "")
        docker build . -f php.Dockerfile \
            --build-arg PHP_VERSION="$version" \
            --build-arg NODE_VERSION=20 \
            --build-arg WITH_XDEBUG="$xdebug" \
            --no-cache \
            --tag "$tag$suffix" \
            --push
    done
done
