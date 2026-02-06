#!/bin/bash
# Typecheck generated code and main canister using dfx

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

echo "Installing dependencies..."
npx ic-mops install

echo ""
echo "Type checking with dfx build..."

# Start dfx if not running (needed for type checking with ic: imports)
if ! dfx ping &> /dev/null; then
  echo "Starting dfx replica (needed for ic: imports)..."
  dfx start --background
  STARTED_DFX=true
else
  STARTED_DFX=false
fi

# Use dfx build --check to typecheck (it knows about management canister IDL)
if dfx build --check 2>&1; then
  echo ""
  echo "✓ Type checking passed"
  EXIT_CODE=0
else
  echo ""
  echo "✗ Type checking failed"
  EXIT_CODE=1
fi

# Stop dfx if we started it
if [ "$STARTED_DFX" = true ]; then
  echo ""
  echo "Stopping dfx replica..."
  dfx stop
fi

exit $EXIT_CODE
