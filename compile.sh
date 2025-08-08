#!/bin/bash

# SAMP Server Compilation Script
# This script helps compile the gamemode

echo "SAMP Server Compilation Script"
echo "=============================="

# Check if pawncc exists
if ! command -v pawncc &> /dev/null; then
    echo "Error: pawncc compiler not found!"
    echo "Please install the PAWN compiler or add it to your PATH"
    exit 1
fi

# Create accounts directory if it doesn't exist
if [ ! -d "accounts" ]; then
    echo "Creating accounts directory..."
    mkdir accounts
fi

# Compile the gamemode
echo "Compiling gamemode.pwn..."
pawncc gamemode.pwn -o gamemode.amx

if [ $? -eq 0 ]; then
    echo "Compilation successful! gamemode.amx created."
    echo ""
    echo "Setup complete! You can now start your server."
    echo "Don't forget to:"
    echo "1. Change the RCON password in server.cfg"
    echo "2. Install required includes (zcmd, sscanf2) if not present"
    echo "3. Set the first admin by editing their account file"
else
    echo "Compilation failed! Check for errors above."
    exit 1
fi