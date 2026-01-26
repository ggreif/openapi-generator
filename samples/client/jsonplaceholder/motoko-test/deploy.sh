#!/bin/bash
# Deploy to local dfx and test

cd "$(dirname "$0")"

# Add moc-wrapper to PATH
export PATH="/Users/ggreif/motoko/node_modules/.bin:$PATH"

echo "Starting local dfx replica..."
dfx start --clean --background

echo ""
echo "Deploying api_test canister..."
dfx deploy api_test

echo ""
echo "=== Running Tests ==="

# Test health check
echo ""
echo "1. Testing health check..."
dfx canister call api_test health

# Test GET all posts (limited to avoid timeout)
echo ""
echo "2. Testing GET first 5 posts..."
dfx canister call api_test testGetFirstPosts '(5)'

# Test GET single post
echo ""
echo "3. Testing GET /posts/1..."
dfx canister call api_test testGetPostById '(1)'

echo ""
echo "=== Tests Complete ==="
echo ""
echo "To stop dfx: dfx stop"
echo "To view logs: dfx canister logs api_test"
