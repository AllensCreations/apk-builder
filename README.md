HOW TO USE APK BUILDER

This tool automatically injects Gradle support and a GitHub Actions auto-release workflow into any of your GitHub repositories.

STEPS TO RUN:

1. Open Termux on your phone.
2. Copy and paste this exact command, then press Enter:

   bash -c "$(curl -sL https://raw.githubusercontent.com/AllensCreations/apk-builder/main/setup.sh)"

3. Follow the on-screen prompts:
   - It will install required tools (git, curl, gh, jq) automatically.
   - It will ask you to log into your GitHub account if you are not already logged in.
   - It will display a list of your repositories. Select the number matching the repository you want to upgrade.

4. Once finished, the script will automatically push the new Gradle configuration and workflow to your chosen repository.

WHAT HAPPENS NEXT:
- Every time you push a commit to that repository, GitHub Actions will automatically build your app and publish a new APK file to your GitHub Releases page.
