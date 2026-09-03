#!/data/data/com.termux/files/usr/bin/bash

echo "Installing required packages (git, curl, gh, jq)..."
pkg update -y && pkg install -y git curl gh jq

if ! gh auth status &>/dev/null; then
    echo "GitHub authentication required."
    gh auth login
fi

echo "Fetching your repositories..."
repos=$(gh repo list --limit 100 --json nameWithOwner | jq -r '.[].nameWithOwner')

if [ -z "$repos" ]; then
    echo "No repositories found or failed to fetch."
    exit 1
fi

echo "Select a target repository to inject Gradle and Auto-Release workflow:"
select repo in $repos "Cancel"; do
    if [ "$repo" = "Cancel" ] || [ -z "$repo" ]; then
        echo "Exiting."
        exit 0
    elif [ -n "$repo" ]; then
        echo "Target repository: $repo"
        break
    fi
done

WORK_DIR=$(mktemp -d)
cd "$WORK_DIR" || exit 1

echo "Cloning AllensCreations/apk-builder..."
gh repo clone AllensCreations/apk-builder central_builder

echo "Cloning target repository ($repo)..."
gh repo clone "$repo" target_repo
cd target_repo || exit 1

if [ -z "$(git config --global user.name)" ]; then
    git config user.name "APK Builder Bot"
    git config user.email "bot@apkbuilder.local"
fi

echo "Injecting remote template files and workflow..."
mkdir -p .github/workflows
cp -R ../central_builder/template/* ./
cp -R ../central_builder/template/.github/workflows/* .github/workflows/

if [ -f "gradlew" ]; then
    chmod +x gradlew
fi

git add .
git commit -m "Add remote Gradle files and automated GitHub Release workflow"

BRANCH=$(git branch --show-current)
git push origin "$BRANCH"

echo "Successfully pushed Gradle setup and workflows to $repo!"

cd /
rm -rf "$WORK_DIR"
