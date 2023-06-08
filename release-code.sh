#!/bin/bash

set -e

# Read current version from package.json
CURRENT_VERSION=$(jq -r '.version' package.json)

# Prompt Platform for Release
read -p "Enter your preferred technology (Java/React/Android/iOS/Flutter): " TECHNOLOGY
# Prompt user for the new version
read -p "Enter the new version: " NEW_VERSION

git checkout develop
git pull origin develop

# Update version in package.json
if [ "$TECHNOLOGY" = "Java" ]; then
    echo "You selected Java."
    mvn versions:set -DnewVersion="$NEW_VERSION"
elif [ "$TECHNOLOGY" = "React" ]; then
    echo "You selected React."
    jq --arg newVersion "$NEW_VERSION" '.version = $newVersion' package.json > tmp.json && mv tmp.json package.json
elif [ "$TECHNOLOGY" = "Android" ]; then
    echo "You selected Android."
    sed -i "s/versionName .*/versionName \"$NEW_VERSION\"/g" app/build.gradle
elif [ "$TECHNOLOGY" = "iOS" ]; then
    echo "You selected iOS."
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEW_VERSION" Info.plist
elif [ "$TECHNOLOGY" = "Flutter" ]; then
    echo "You selected Flutter."
    sed -i '' "s/version: .*/version: $NEW_VERSION/g" pubspec.yaml
else
    echo "Invalid technology selection."
fi

git branch release/$NEW_VERSION

# Commit and tag the release
git add package.json
git commit -m "Update version to $NEW_VERSION"

# Merge to main branch
git checkout main
git merge --no-ff "release/$NEW_VERSION" -m "Merge release $NEW_VERSION to main"
git tag "$NEW_VERSION"
git push origin main
git push origin "$NEW_VERSION"
git push origin release/$NEW_VERSION

# Merge to develop branch
git checkout develop
git merge --no-ff "release/$NEW_VERSION" -m "Merge release $NEW_VERSION to develop"
git push origin develop

# Clean up the release branch
git branch -D "release/$NEW_VERSION"
# git push origin --delete "release/$NEW_VERSION"

echo "Release $NEW_VERSION successfully created and merged!"
