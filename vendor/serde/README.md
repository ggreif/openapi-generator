# Vendored Serde Stub

This is a **minimal typecheck-only stub** of the [serde](https://github.com/NatLabs/serde) library for Motoko.

## Purpose

This stub is used for typechecking generated Motoko client code during development. It provides only the type signatures needed by the OpenAPI generator - it is **NOT** a functional implementation.

## What's Included

- `JSON.fromText()` - Type signature for parsing JSON to Candid blobs
- `JSON.toText()` - Type signature for converting Candid blobs to JSON

## Usage

For typechecking generated code:

```bash
moc --check \
  --package core /path/to/motoko-core/src \
  --package serde vendor/serde/src \
  path/to/GeneratedApi.mo
```

## For Production Use

Generated code that actually needs to run should use the real [serde library](https://github.com/NatLabs/serde) via mops:

```toml
[dependencies]
serde = "3.4.0"
```

## License

This stub follows the same MIT license as the original serde library.
