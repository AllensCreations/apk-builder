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

echo "Select a target repository to inject Gradle and Workflow tester:"
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

echo "----------------------------------------"
echo "Running Pre-Flight Tester on Target Repo..."
echo "----------------------------------------"

MISSING_ITEMS=0

# Check for app/ directory structure
if [ ! -d "app" ]; then
    echo "[!] Missing 'app' directory detected. Creating structure..."
    mkdir -p app/src/main/res/values
    MISSING_ITEMS=$((MISSING_ITEMS + 1))
fi

# Check for main build.gradle files
if [ ! -f "build.gradle" ] && [ ! -f "build.gradle.kts" ]; then
    echo "[!] Missing root build.gradle detected. Fixing..."
    cp ../central_builder/template/build.gradle ./build.gradle
    MISSING_ITEMS=$((MISSING_ITEMS + 1))
fi

if [ ! -f "app/build.gradle" ]; then
    echo "[!] Missing app/build.gradle detected. Fixing..."
    mkdir -p app
    cp ../central_builder/template/app/build.gradle ./app/build.gradle
    MISSING_ITEMS=$((MISSING_ITEMS + 1))
fi

# Check for settings.gradle
if [ ! -f "settings.gradle" ]; then
    echo "[!] Missing settings.gradle detected. Fixing..."
    cp ../central_builder/template/settings.gradle ./settings.gradle
    MISSING_ITEMS=$((MISSING_ITEMS + 1))
fi

# Check for GitHub Workflow folder
if [ ! -d ".github/workflows" ]; then
    echo "[!] Missing workflows directory detected. Creating..."
    mkdir -p .github/workflows
    MISSING_ITEMS=$((MISSING_ITEMS + 1))
fi

echo "Pre-Flight check complete. Resolved missing items: $MISSING_ITEMS"
echo "----------------------------------------"

echo "Injecting workflows and template files from central builder..."
cp -R ../central_builder/template/.github/workflows/* .github/workflows/

if [ -f "gradlew" ]; then
    chmod +x gradlew
fi

git add .
git status
git commit -m "Pre-flight check: Auto-resolved missing configurations and added CI workflow"

BRANCH=$(git branch --show-current)
git push origin "$BRANCH"

echo "Successfully validated and synchronized $repo!"

cd /
rm -rf "$WORK_DIR"
