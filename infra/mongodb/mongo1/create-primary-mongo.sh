#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"

echo "[create-primary-mongo]Creating staynest-mongo-1..."

echo "[create-primary-mongo] Starting Docker Services..."
docker compose up -d
sleep 10

echo "[create-primary-mongo] Initiating Replica Set..."
bash rs-initiate.sh
sleep 5

echo "[create-primary-mongo] Creating App User..."
bash app-user-create.sh

echo "[create-primary-mongo] staynest-mongo-1 started successfully"

sleep 2