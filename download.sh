#!/bin/bash

# Default values
USE_BOX32="FALSE"
OUTPUT_NAME="box64"
TARGET_TAG=""

# --- Help Menu Function ---
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

A zero-dependency script to download the latest or a specific pre-compiled 
Box64 binary matching your system's architecture (ARM64 or RISC-V).

Options:
  -b, --box32      Download the box32-enabled variant (ARM64 & RISC-V)
  -o, --output     Specify custom output filename (Default: box64)
  -v, --version    Specify a specific version tag to download (e.g., v0.4.2)
  -l, --list       Print all available version tags on GitHub and exit
  -h, --help       Show this help message and exit

Examples:
  ./$(basename "$0")
  ./$(basename "$0") --box32
  ./$(basename "$0") --list
  ./$(basename "$0") -v v0.4.2 -b
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
                echo "Error: Argument for $1 is missing (Expected version tag like v0.4.2)" >&2
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

# 2. Establish which version tag to use using custom extraction logic
if [ -z "$TARGET_TAG" ]; then
    TARGET_TAG=$(curl -s https://github.com/alipex/box64-builds/tags | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -n 1)
    if [ -z "$TARGET_TAG" ]; then
        echo "Error: Failed to fetch the latest Box64 release tag from GitHub." >&2
        exit 1
    fi
    echo "Latest Box64 release found: $TARGET_TAG"
else
    if [[ ! "$TARGET_TAG" =~ ^v ]]; then
        TARGET_TAG="v$TARGET_TAG"
    fi
    echo "Targeting specified release: $TARGET_TAG"
fi

# Extract the raw version number (stripping out the 'v')
VERSION_NUM=$(echo "$TARGET_TAG" | sed 's/^v//')

# 3. Formulate the correct filename layout (Allows box32 builds on both ARM64 and RISC-V)
if [ "$USE_BOX32" = "true" ]; then
    FILENAME="box64-${VERSION_NUM}-${SYSTEM_ARCH}-dynarec-box32"
else
    FILENAME="box64-${VERSION_NUM}-${SYSTEM_ARCH}-dynarec"
fi

URL="https://github.com/alipex/box64-builds/releases/download/${TARGET_TAG}/${FILENAME}"

# 4. Download using curl and set executable flags cleanly
echo "Downloading from: $URL"
curl -o "./$OUTPUT_NAME" -sSL "$URL"

if [ $? -eq 0 ] && [ -s "./$OUTPUT_NAME" ]; then
    chmod +x "./$OUTPUT_NAME"
    echo "Successfully downloaded and configured './$OUTPUT_NAME'."
else
    echo "Error: Download failed or binary is empty. Check if version ($TARGET_TAG) or combination exists." >&2
    rm -f "./$OUTPUT_NAME" # Clear corrupt empty files if curl failed quietly
    exit 1
fi