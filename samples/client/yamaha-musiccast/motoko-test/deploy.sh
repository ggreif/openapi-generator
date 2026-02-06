#!/bin/bash
# Deploy to local dfx and test Yamaha MusicCast API

cd "$(dirname "$0")"

DFX_MOC_PATH=/Users/ggreif/motoko/bin/moc

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

echo
echo "Deploying yamaha_test canister..."
if ! dfx deploy yamaha_test; then
    echo "Error: dfx deploy failed"
    exit 1
fi

echo
echo "Adding cycles to canister for HTTP outcalls..."
# First, fund the wallet canister with ICP (which gets converted to cycles)
WALLET_ID=$(dfx identity get-wallet)
dfx ledger fabricate-cycles --canister "$WALLET_ID" --amount 10
# Then deposit cycles from wallet to the yamaha_test canister
dfx canister deposit-cycles 100_000_000_000_000 yamaha_test

echo
echo "============================="
echo "Running Yamaha test sequence..."
echo "============================="
echo
dfx canister call yamaha_test testYamahaSequence

echo
echo "============================="
echo "Test complete!"
echo "============================="
