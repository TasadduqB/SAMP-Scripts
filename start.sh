#!/bin/bash

# SAMP Server Startup Script
# This script starts the SA-MP server with proper configuration

SERVER_NAME="Complete SAMP Server"
echo "Starting $SERVER_NAME..."
echo "========================"

# Check if server files exist
if [ ! -f "gamemode.amx" ]; then
    echo "Error: gamemode.amx not found!"
    echo "Please compile the gamemode first using ./compile.sh"
    exit 1
fi

if [ ! -f "server.cfg" ]; then
    echo "Error: server.cfg not found!"
    exit 1
fi

# Create necessary directories
mkdir -p accounts
mkdir -p logs
mkdir -p scriptfiles

# Check for SA-MP server binary
if [ -f "samp03svr" ]; then
    SERVER_BINARY="./samp03svr"
elif [ -f "samp-server.exe" ]; then
    SERVER_BINARY="./samp-server.exe"
else
    echo "Error: SA-MP server binary not found!"
    echo "Please download the SA-MP server package and place the binary in this directory"
    echo "Linux: samp03svr"
    echo "Windows: samp-server.exe"
    exit 1
fi

echo "Server binary found: $SERVER_BINARY"
echo "Starting server..."
echo ""

# Start the server
$SERVER_BINARY

echo ""
echo "Server has stopped."