#!/bin/bash
# Regenerate Motoko client from OpenAPI spec

cd "$(dirname "$0")"
cd ../../..  # Go to repo root

echo "Generating Motoko client from OpenAPI spec..."
./bin/generate-samples.sh bin/configs/motoko-jsonplaceholder-test.yaml

echo "Client generation complete!"
echo "Generated files in: samples/client/jsonplaceholder/motoko-test/generated/"
