#!/bin/bash
# Deploy to local dfx and test

cd "$(dirname "$0")"

# Check for moc-wrapper and add to PATH if needed
if ! command -v moc-wrapper &> /dev/null; then
  # Try common locations for moc-wrapper
  COMMON_PATHS=(
    "$HOME/motoko/node_modules/.bin"
    "./node_modules/.bin"
    "../node_modules/.bin"
  )

  MOC_WRAPPER_FOUND=false
  for path in "${COMMON_PATHS[@]}"; do
    if [ -x "$path/moc-wrapper" ]; then
      export PATH="$path:$PATH"
      MOC_WRAPPER_FOUND=true
      break
    fi
  done

  if [ "$MOC_WRAPPER_FOUND" = false ]; then
    echo "Error: moc-wrapper not found in PATH"
    echo "Please install it with: npm install -g ic-mops"
    echo "Or ensure it's available in your PATH"
    exit 1
  fi
fi

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
