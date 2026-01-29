#!/bin/bash
# Regenerate Motoko client from Spotify OpenAPI spec

cd "$(dirname "$0")"
cd ../../..  # Go to repo root

echo "Generating Motoko client from Spotify OpenAPI spec..."
./bin/generate-samples.sh bin/configs/motoko-spotify.yaml

echo "Client generation complete!"
echo "Generated files in: samples/client/spotify/motoko/generated/"
