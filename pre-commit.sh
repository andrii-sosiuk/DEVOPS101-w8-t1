#!/bin/bash

# Gitleaks version
gitleaks_version=8.18.2

# Path to the user's local binary directory
local_bin="$HOME/.local/bin"

# Function to check if Gitleaks is installed
gitleaks_installed() {
    installed=false
    # Check if gitleaks is available in the system path using command -v
    if command -v gitleaks >/dev/null 2>&1; then
        installed="true"
    fi

    # Check if gitleaks exists in the $HOME/.local/bin directory
    if [ -x "$local_bin/gitleaks" ]; then
        # Add $HOME/.local/bin to PATH if not already in PATH
        case ":$PATH:" in
            *":$local_bin:"*) ;;
            *) export PATH="$local_bin:$PATH" ;;
        esac
        installed="true"
    fi
    if [ "$installed" == "true" ]; then
        return 0
    else
        return 1
    fi
}

# Function to install Gitleaks
install_gitleaks() {

  echo "Detecting Architecture for Gitleaks installation..."
  arch="$(uname -m)"
  case "${arch}" in
      x86_64)     binary_arch=x64;;
      i386)    binary_arch=x32;;
      arm7*)    binary_arch=arm7;;
      arm6*) binary_arch=arm6;;
      *)          echo "Unsupported Architecture: ${arch}" ; exit 1;;
  esac

  echo "Detecting OS for Gitleaks installation..."
  os="$(uname -s)"
  case "${os}" in
      Linux*)     binary_url="https://github.com/gitleaks/gitleaks/releases/download/v${gitleaks_version}/gitleaks_${gitleaks_version}_linux_${binary_arch}.tar.gz";;
      Darwin*)    binary_url="https://github.com/gitleaks/gitleaks/releases/download/v${gitleaks_version}/gitleaks_${gitleaks_version}_darwin_${binary_arch}.tar.gz";;
      CYGWIN*|MINGW32*|MSYS*|MINGW*) binary_url="https://github.com/gitleaks/gitleaks/releases/download/v${gitleaks_version}/gitleaks_${gitleaks_version}_windows_${binary_arch}.zip";;
      *)          echo "Unsupported OS: ${os}" ; exit 1;;
  esac

  echo "Installing Gitleaks..."
  if [[ "$binary_url" == *.zip ]]; then
    curl -L  "${binary_url}" -o /tmp/gitleaks.zip
    if [ ! -d "$local_bin" ]; then
        echo "Creating local bin directoru for current user."
        mkdir -p $local_bin
    fi
    unzip -p /tmp/gitleaks.zip 'gitleaks.exe' > $local_bin/gitleaks.exe
    chmod +x $local_bin/gitleaks.exe
    export PATH="$local_bin:$PATH"
    rm /tmp/gitleaks.zip

  elif [[ "$binary_url" == *.tar.gz ]]; then
    curl -L "${binary_url}" -o /tmp/gitleaks.tgz
    if [ ! -d "$local_bin" ]; then
        echo "Creating local bin directoru for current user."
        mkdir -p $local_bin
    fi
    tar -C $local_bin -xvf /tmp/gitleaks.tgz gitleaks
    chmod +x $local_bin/gitleaks
    export PATH="$local_bin:$PATH"
    rm /tmp/gitleaks.tgz
  fi

}  

# Check if the gitleas check in pre-commit hook is enabled
gl_enabled=$(git config --bool gitleaks.enabled)

if [ "$gl_enabled" != "true" ]; then
    exit 0
fi

# Check if gitleaks is installed, if not, install it
if ! gitleaks_installed; then
  echo "Gitleaks is not installed."
  install_gitleaks
else
  echo "Gitleaks installed."
fi

# Run Gitleaks on staged files only
# Create a list of all staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR)

# Temporary stash unstaged changes to avoid scanning them
git stash -q --keep-index

# Run Gitleaks
echo "Running Gitleaks..."
gitleaks protect -v --staged

# Capture the Gitleaks exit status
STATUS=$?

# Unstash changes
git stash pop -q

if [ $STATUS -ne 0 ]; then
  echo "Gitleaks detected sensitive information in your commit. Commit aborted."
  exit 1
fi

echo "No issues detected."
exit 0
