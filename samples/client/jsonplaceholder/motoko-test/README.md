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
- **mops** (via `npx ic-mops`)
- **Node.js** (for mops)

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

## Response Structure

```motoko
type Post = {
  id: Int;
  userId: Int;
  title: Text;
  body: Text;
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

## Limitations

- Local dfx provides single-replica consensus (mainnet uses 13 replicas)
- HTTP outcalls require cycles (automatically provided in local dfx)
- Large responses may timeout locally
- Transform functions not yet implemented (for deterministic responses)

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
- Implement transform functions for consensus
- Add automated integration tests
- Test error handling (404, 500 responses)
- Deploy to IC testnet

## Related Files

- Generator config: `bin/configs/motoko-jsonplaceholder-test.yaml`
- OpenAPI spec: `specs/jsonplaceholder-posts.json`
- Motoko generator: `modules/openapi-generator/src/main/resources/motoko/`

## License

Part of the openapi-generator project.
