#!/bin/bash
# Delete.sh - A script to delete all files and folders in the current directory
read -p "Are you sure you want to delete all files and folders in the current directory? [y/N]: " confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
    echo "Operation cancelled."
    exit 1
fi

for item in * .*; do
    if [[ "$item" != "." && "$item" != ".." ]]; then
        rm -rf "$item"
        echo "Deleted: $item"
    fi
done

echo "All files and folders have been deleted."
