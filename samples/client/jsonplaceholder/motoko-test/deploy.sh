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
echo "Adding cycles to canister for HTTP outcalls..."
# First, fund the wallet canister with ICP (which gets converted to cycles)
WALLET_ID=$(dfx identity get-wallet)
dfx ledger fabricate-cycles --canister "$WALLET_ID" --amount 10
# Then deposit cycles from wallet to the api_test canister
dfx canister deposit-cycles 100_000_000_000_000 api_test

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
dfx canister call api_test testGetPostById '("1")'

# Test nonexistent endpoint (expects 404 error)
echo ""
echo "4. Testing GET /nonexistent (expects 404 error)..."
dfx canister call api_test testNonexistentEndpoint

# Test high ID number
echo ""
echo "5. Testing GET /posts/999999 (high ID number)..."
dfx canister call api_test testGetPostByHighId

# Test negative ID number
echo ""
echo "6. Testing GET /posts/-1 (negative ID)..."
dfx canister call api_test testGetPostByNegativeId

# Test string ID
echo ""
echo "7. Testing GET /posts/deadbeef (string ID)..."
dfx canister call api_test testGetPostByStringId

# Test HTTP 500 error from httpbin.org
echo ""
echo "8. Testing GET https://httpbin.org/status/500 (expects 500 error)..."
dfx canister call api_test testGetStatus500

# Test HTTP 503 error from httpbin.org
echo ""
echo "9. Testing GET https://httpbin.org/status/503 (expects 503 error)..."
dfx canister call api_test testGetStatus503

# Test HTTP 200 from httpbin.org (control test)
echo ""
echo "10. Testing GET https://httpbin.org/status/200 (expects success)..."
dfx canister call api_test testGetStatus200

echo ""
echo "=== Tests Complete ==="
echo ""
echo "To stop dfx: dfx stop"
echo "To view logs: dfx canister logs api_test"
