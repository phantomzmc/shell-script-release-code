#!/bin/bash

set -e

# Read current version from package.json
CURRENT_VERSION=$(jq -r '.version' package.json)

# Prompt user for the new version
read -p "Enter the new version: " NEW_VERSION

# Update version in package.json
jq --arg newVersion "$NEW_VERSION" '.version = $newVersion' package.json > tmp.json && mv tmp.json package.json

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "Current branch: $CURRENT_BRANCH"

# Commit and tag the release
git add package.json
git commit -m "Bump version to $NEW_VERSION"
# git tag "$NEW_VERSION"


# Merge to main branch
git checkout main
# git merge --no-ff "release/$NEW_VERSION" -m "Merge release $NEW_VERSION to main"
git merge --no-ff "$CURRENT_BRANCH" -m "Merge release $CURRENT_BRANCH to main"
git tag "$NEW_VERSION"
git push origin main
git push origin "$NEW_VERSION"

# Merge to develop branch
git checkout develop
# git merge --no-ff "release/$NEW_VERSION" -m "Merge release $NEW_VERSION to develop"
git merge --no-ff "$CURRENT_BRANCH" -m "Merge release $CURRENT_BRANCH to develop"
git push origin develop

# Clean up the release branch
# git branch -D "release/$NEW_VERSION"
# git push origin --delete "release/$NEW_VERSION"

echo "Release $NEW_VERSION successfully created and merged!"
