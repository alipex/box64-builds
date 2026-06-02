#!/bin/bash

# Default values
USE_BOX32="false"
OUTPUT_NAME="box64"
TARGET_TAG=""

# --- Help Menu Function ---
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

A zero-dependency script to download the latest or a specific pre-compiled 
Box64 binary matching your system's architecture (ARM64 or RISC-V).

Options:
  --box32          Download the box32-enabled variant
  -o, --output     Specify custom output filename (Default: box64)
  -v, --version    Specify a specific version tag to download (e.g., v0.3.0)
  -l, --list       Print all available version tags on GitHub and exit
  -h, --help       Show this help message and exit

Examples:
  ./$(basename "$0")
  ./$(basename "$0") --box32
  ./$(basename "$0") --list
  ./$(basename "$0") -v v0.3.0 -b
EOF
}

# --- Parse Arguments ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--box32)
            USE_BOX32="true"
            shift
            ;;
        -l|--list)
            echo "Fetching available versions from alipex/box64-builds..."
            curl -s https://github.com/alipex/box64-builds/tags | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | sort -rV
            exit 0
            ;;
        -v|--version)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                TARGET_TAG="$2"
                shift 2
            else
                echo "Error: Argument for $1 is missing (Expected version tag like v0.3.0)" >&2
                exit 1
            fi
            ;;
        -o|--output)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                OUTPUT_NAME="$2"
                shift 2
            else
                echo "Error: Argument for $1 is missing" >&2
                exit 1
            fi
            ;;
        *)
            echo "Error: Unknown option $1" >&2
            show_help
            exit 1
            ;;
    esac
done

# 1. Automatically determine system architecture
ARCH=$(uname -m)
case "$ARCH" in
    aarch64|arm64)
        SYSTEM_ARCH="aarch64"
        ;;
    riscv64)
        SYSTEM_ARCH="rv64gc"
        ;;
    x86_64)
        echo "System is natively x86_64. Box64 emulation is not required here."
        exit 0
        ;;
    *)
        echo "Error: Unsupported architecture ($ARCH). This script supports ARM64 and RISC-V." >&2
        exit 1
        ;;
esac

echo "Detected architecture: $SYSTEM_ARCH"

# 2. Establish which version tag to use
if [ -z "$TARGET_TAG" ]; then
    # Default behavior: Fetch the latest tag from GitHub
    TARGET_TAG=$(curl -s https://github.com/alipex/box64-builds/tags | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n 1)
    if [ -z "$TARGET_TAG" ]; then
        echo "Error: Failed to fetch the latest Box64 release tag from GitHub." >&2
        exit 1
    fi
    echo "Latest Box64 release found: $TARGET_TAG"
else
    # Normalize input: make sure it starts with 'v' just in case user types '0.3.0' instead of 'v0.3.0'
    if [[ ! "$TARGET_TAG" =~ ^v ]]; then
        TARGET_TAG="v$TARGET_TAG"
    fi
    echo "Targeting specified release: $TARGET_TAG"
fi

# Strip 'v' prefix for the asset filename template
VERSION_NUM=$(echo "$TARGET_TAG" | sed 's/^v//')

# 3. Formulate the correct filename based on architecture and box32 parameters
if [ "$USE_BOX32" = "true" ]; then
    FILENAME="box64-${VERSION_NUM}-${SYSTEM_ARCH}-dynarec-box32"
else
    FILENAME="box64-${VERSION_NUM}-${SYSTEM_ARCH}-dynarec"
fi

URL="https://github.com/alipex/box64-builds/releases/download/${TARGET_TAG}/${FILENAME}"

# 4. Download and make executable
echo "Downloading from: $URL"
wget -q --show-progress -O "$OUTPUT_NAME" "$URL"

if [ $? -eq 0 ]; then
    chmod +x "./$OUTPUT_NAME"
    echo "Successfully downloaded and configured './$OUTPUT_NAME'!"
else
    echo "Error: Download failed. Check if the version ($TARGET_TAG) or parameter combination exists." >&2
    exit 1
fi