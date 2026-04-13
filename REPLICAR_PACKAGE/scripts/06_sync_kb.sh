#!/bin/bash
# 06_sync_kb.sh — Sync canonical KB to ~/.hermes/
# Source: /mnt/c/CindyAgent/KB/hermes/*
# Target: ~/.hermes/

set -e

SOURCE_KB="/mnt/c/CindyAgent/KB/hermes"
TARGET_DIR="$HOME/.hermes"
ACTIVATE_SCRIPT="$SOURCE_KB/activate_cindy_runtime.py"

echo "=== Sync KB Canonical ==="
echo "Source: $SOURCE_KB"
echo "Target: $TARGET_DIR"

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Copy all KB files
echo "Copying KB files..."
cp -r "$SOURCE_KB"/* "$TARGET_DIR/" 2>/dev/null || true

# Copy activate_cindy_runtime.py to target root
if [ -f "$ACTIVATE_SCRIPT" ]; then
    cp "$ACTIVATE_SCRIPT" "$TARGET_DIR/"
    echo "Copied activate_cindy_runtime.py"
else
    echo "WARNING: $ACTIVATE_SCRIPT not found"
fi

# Verify files exist after copy
echo ""
echo "=== Verification ==="
if [ -d "$TARGET_DIR" ]; then
    echo "✓ Target directory exists: $TARGET_DIR"
else
    echo "✗ Target directory missing!"
    exit 1
fi

# Check critical files
for file in "SOUL.md" "USER.md" "MEMORY.md" "activate_cindy_runtime.py"; do
    if [ -f "$TARGET_DIR/$file" ]; then
        echo "✓ Found: $file"
    else
        echo "✗ Missing: $file"
    fi
done

echo ""
echo "=== KB Sync Complete ==="
