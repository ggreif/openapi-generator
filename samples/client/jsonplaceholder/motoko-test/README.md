# Motoko OpenAPI Client Test Project

This project demonstrates testing of Motoko client code generated from an OpenAPI specification, deployed to a local Internet Computer replica.

## Overview

- **API:** JSONPlaceholder Posts API (https://jsonplaceholder.typicode.com)
- **Generated Code:** Motoko client with type-safe models and API calls
- **Test Canister:** Makes real HTTP outcalls to the public API
- **Dependencies:** Managed via `mops` with real `serde` library

## Project Structure

```
motoko-test/
├── specs/
│   └── jsonplaceholder-posts.json      # OpenAPI 3.0 specification
├── generated/                           # Generated Motoko client code
│   ├── Apis/DefaultApi.mo              # API client functions
│   ├── Models/Post.mo                  # Type-safe model
│   └── mops.toml                       # Generated dependencies
├── src/
│   └── main.mo                         # Test canister implementation
├── dfx.json                            # dfx project configuration
├── generate.sh                         # Regenerate client from spec
├── typecheck.sh                        # Type check all code
└── deploy.sh                           # Deploy and test locally
```

## Requirements

- **dfx** 0.23.0 or later
- **moc** (Motoko compiler)
- **mops** (via `npx ic-mops`) - Install with: `npm install -g ic-mops`
- **moc-wrapper** - Provided by ic-mops, needed for dfx packtool integration
- **Node.js** (for mops)

> **Note:** The `deploy.sh` script will automatically look for `moc-wrapper` in common locations (`~/motoko/node_modules/.bin`, `./node_modules/.bin`). If not found, install ic-mops globally: `npm install -g ic-mops`

## Quick Start

### 1. Generate Client Code

```bash
./generate.sh
```

### 2. Type Check

```bash
./typecheck.sh
```

### 3. Deploy and Test

```bash
./deploy.sh
```

The deploy script will:
1. Start local dfx replica
2. Deploy the `api_test` canister
3. Run test calls to the JSONPlaceholder API
4. Display results

## Manual Testing

After deploying with `dfx start --background && dfx deploy`:

```bash
# Health check
dfx canister call api_test health

# Get first 5 posts
dfx canister call api_test testGetFirstPosts '(5)'

# Get specific post by ID
dfx canister call api_test testGetPostById '(1)'

# Get all posts (may timeout locally with 100 posts)
dfx canister call api_test testGetPosts
```

## API Endpoints Tested

- `GET /posts` - Returns all posts (array)
- `GET /posts/{id}` - Returns single post by ID
- `GET /nonexistent` - Tests 404 error handling
- `GET /status/500` - Tests HTTP 500 error from httpbin.org
- `GET /status/503` - Tests HTTP 503 error from httpbin.org
- `GET /json` - Tests HTTP 200 success from httpbin.org
- `GET /anything` - Tests GeoJSON with triple-nested arrays via transform callback

## Response Structure

```motoko
type Post = {
  id: Int;
  userId: Int;
  title: Text;
  body: Text;
};

type GeoJsonPolygon = {
  type_: Text;
  coordinates: [[[Float]]];  // Triple-nested array!
};

type GeoJsonFeature = {
  type_: Text;
  geometry: GeoJsonPolygon;
  properties: GeoJsonFeatureProperties;
};
```

## Dependencies

The project uses:
- `core = "2.0.0"` - Motoko core library
- `serde` - JSON serialization (ggreif fork, temporary)
- Transitive dependencies for serde (cbor, xtended-numbers, etc.)

**Note:** The `github.com/ggreif/serde` fork is temporary during the motoko-core transition. See `mops.toml` for details.

## How It Works

1. **HTTP Outcalls:** The canister uses the Internet Computer management canister (`aaaaa-aa`) to make HTTPS requests
2. **JSON Parsing:** Responses are parsed using the `mo:serde` library
3. **Type Safety:** OpenAPI schemas are converted to Motoko types
4. **Async Calls:** All API calls are async and handle network requests
5. **Transform Callbacks:** Optional transform functions can modify responses for determinism

## Testing Triple-Nested Arrays

Test 11 (`testGeoJsonPolygon`) validates end-to-end nested array handling:

**Type Structure:**
- Level 1: Array of rings `[ring1, ring2, ...]`
- Level 2: Array of points in each ring `[[lon1,lat1], [lon2,lat2], ...]`
- Level 3: Array of coordinates `[longitude, latitude]`
- Level 4: Float values

**Motoko Type:** `[[[Float]]]`

**Test Approach:**
- HTTP call to httpbin.org `/anything` endpoint
- Transform callback converts response to GeoJSON Polygon format
- Tests HTTP outcall → transform → JSON deserialization → typed arrays

**What This Proves:**
- ✅ Generator correctly interprets nested array schemas from OpenAPI
- ✅ Generates proper Motoko syntax for triple-nested arrays
- ✅ Produced code compiles with moc
- ✅ HTTP outcall mechanism works with IC management canister
- ✅ Transform callbacks correctly modify HTTP responses
- ✅ JSON deserialization handles `[[[Float]]]` correctly
- ✅ Triple-nested arrays support indexing and element access
- ✅ serde library handles deeply nested array deserialization

This validates the complete flow: **HTTP → transform → deserialize → typed arrays**.

## Limitations

- Local dfx provides single-replica consensus (mainnet uses 13 replicas)
- HTTP outcalls require cycles (automatically provided in local dfx)
- Large responses may timeout locally
- Transform callbacks are optional (test 11 demonstrates their use)

## Troubleshooting

### Typecheck Fails

```bash
cd generated && npx ic-mops install
```

### Deploy Fails

```bash
dfx stop
dfx start --clean --background
dfx deploy
```

### HTTP Outcall Timeout

Try requesting fewer posts:
```bash
dfx canister call api_test testGetFirstPosts '(5)'
```

## Future Enhancements

- Add POST/PUT/DELETE operations
- Add automated integration tests
- Test with more complex OpenAPI specs (GitHub, Stripe APIs)
- Deploy to IC testnet
- Test with real GeoJSON APIs (pygeoapi demo server)

## Related Files

- Generator config: `bin/configs/motoko-jsonplaceholder-test.yaml`
- OpenAPI spec: `specs/jsonplaceholder-posts.json`
- Motoko generator: `modules/openapi-generator/src/main/resources/motoko/`

## License

Part of the openapi-generator project.
