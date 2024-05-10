# Pre-Commit Hook for Git which checks for sensitive data

This pre-commit hook checks for sensitive data in commits, utilizing the [Gitleaks project](https://github.com/gitleaks/gitleaks) as the detection mechanism.

The script performs the check only if the `gitleaks.enabled` key is set to `true` in the Git configuration (see the "Installation" and "Usage" sections). If Gitleaks is not already installed on the system, the script will automatically install it. By default, the Gitleaks binary will be located at `$HOME/.locals/bin/gitleaks`.
Skript works well on Windows, Linux and Darwin OSs.

Note: This script does not provide an uninstallation process. If necessary, remove Gitleaks manually.

## Installation

1. To install the hook, copy `pre-commit.sh` to your repository’s `.git/hooks` directory as `pre-commit`:
    ```bash
    cp ./pre-commit.sh your_repo_path/.git/hooks/pre-commit
    ```
2. Enable the Gitleaks check with the following command:
    ```bash
    git config gitleaks.enabled true
    ```

## Usage

1. Follow the installation steps if you haven't done so already.
2. Ensure `gitleaks.enabled` is set in the Git configuration with:
    ```bash
    git config gitleaks.enabled true
    ```
3. Proceed with your usual commit workflow:
    ```bash
    git add files
    git commit -m "My commit"
    ```
   You will see Gitleaks run:
    ```
    Gitleaks installed.
    Running Gitleaks...

        ○
        │╲
        │ ○
        ○ ░
        ░    gitleaks

    12:52PM INF 0 commits scanned.
    12:52PM INF scan completed in 45.1ms
    12:52PM INF no leaks found
    No stash entries found.
    No issues detected.
    On branch develop
    ```

4. If you need to temporarily disable the check, you can set `gitleaks.enabled` to `false` in the Git configuration with:
    ```bash
    git config gitleaks.enabled false
    ```
