---
name: generate
description: Generate and typecheck Motoko samples from OpenAPI specs
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash
---

# Generate Motoko Samples

This skill helps generate Motoko client code from OpenAPI specifications and verify it typechecks correctly.

## Policy: Don't Check In Generated `.mo` Files

**IMPORTANT**: Generated `.mo` files should NOT be committed to the repository yet. They are still under development and the generator is being refined.

## Generation Workflow

1. **Build the generator** (if needed):
   ```bash
   mvn clean install -DskipTests
   ```

   **IMPORTANT**: Always rebuild after modifying templates (`.mustache` files) or generator code. A stale `openapi-generator-cli.jar` in `modules/openapi-generator-cli/target/` will cause generated code to not reflect your changes.

2. **Generate Motoko samples**:
   ```bash
   bin/generate-samples.sh bin/configs/motoko-petstore-new.yaml
   # or
   bin/generate-samples.sh bin/configs/motoko-petstore-nodfx.yaml
   ```

3. **Typecheck generated files**:

   **Primary method** - Use `mops` to manage dependencies and typecheck:
   ```bash
   cd samples/client/<spec-name>/motoko

   # Install dependencies (first time or after mops.toml changes)
   npx ic-mops install

   # Get package flags from mops and typecheck all files
   PACKAGE_FLAGS=$(npx ic-mops sources)
   for file in Models/*.mo Apis/*.mo; do
     echo "Checking $file..."
     moc --check $PACKAGE_FLAGS "$file"
   done
   ```

   Or use the convenience script if available: `./typecheck.sh`

   This approach uses the real `serde` library with all dependencies managed by mops.

   **Alternative** - Quick typechecking with vendored stub (from repo root):
   ```bash
   moc --check \
     --package core /Users/ggreif/motoko-core/src \
     --package serde vendor/serde/src \
     <file.mo>
   ```

   **Note about warnings**: Generated API files will show warnings about unused identifiers (parameters like `response`, `status`, etc. in stub implementations). These warnings are expected and should be ignored - they're parameters in the generated API stubs that aren't used yet.

## Motoko Core Library Reference

The Motoko core library is located at `/Users/ggreif/motoko-core/src` and contains:
- Pure data structures: `pure/Map.mo`, `pure/List.mo`, etc.
- Standard types and utilities: `Text.mo`, `Error.mo`, `Iter.mo`, etc.

You can read these files to understand the API and type signatures.

## Dependency Management

**Mops configuration** (create `mops.toml` in the generated samples directory):
```toml
[package]
name = "<package-name>"
version = "1.0.0"

[dependencies]
core = "2.0.0"
serde = "https://github.com/ggreif/serde#<commit-hash>"
```

This configuration uses:
- `core` published version for pure data structures and standard types
- `serde` from GitHub for JSON serialization (mops auto-resolves its transitive dependencies)

**Vendored Serde Stub** (`vendor/serde/src/`):
- Minimal typecheck-only stub for quick validation
- Only provides type signatures, not functional
- Useful for fast typechecking without dependency resolution
- For full typechecking with real `serde`, use mops as described above

## Current Generator Features

- **Map types**: Uses destructuring type imports `import { type Map } "mo:core/pure/Map"`
  - Generates `Map<K, V>` instead of `Map.Map<K, V>`
- **Array types**: Uses Motoko array syntax `[T]`
- **Model imports**: Uses destructuring `import { type ModelName } "./ModelName"`
- **DFX mode**: Optional `useDfx` flag for IC imports

## Common Issues

1. **Import errors**: If you see "package 'core' not defined", you either:
   - Forgot the `--package core /Users/ggreif/motoko-core/src` flag (when using manual moc)
   - Haven't run `npx ic-mops install` (when using mops)
2. **Type errors**: Often indicate issues in the generator logic, not the generated code
3. **Missing imports**: Check that parameterized types like `Map<K,V>` are filtered from model imports
4. **Unexpected generated code**: If generated files don't match template changes, the generator CLI JAR is likely stale. Rebuild with `mvn clean install -DskipTests` to update `modules/openapi-generator-cli/target/openapi-generator-cli.jar` with recent template modifications.
5. **Dependency conflicts**: When using the real `serde` library manually, you may hit transitive dependency version conflicts. Use `mops` to automatically resolve all dependencies correctly.

When invoked, help the user with:
- Generating samples from OpenAPI specs
- Typechecking generated Motoko code
- Debugging generator issues
- Understanding Motoko core library types
