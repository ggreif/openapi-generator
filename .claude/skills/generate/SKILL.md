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

2. **Generate Motoko samples**:
   ```bash
   bin/generate-samples.sh bin/configs/motoko-petstore-new.yaml
   # or
   bin/generate-samples.sh bin/configs/motoko-petstore-nodfx.yaml
   ```

3. **Typecheck generated files with moc**:
   Always use these options when typechecking:
   ```bash
   moc --check --package core /Users/ggreif/motoko-core/src <file.mo>
   ```

   Example for checking all API files:
   ```bash
   cd samples/client/petstore/motoko
   for file in Apis/*.mo; do
     echo "Checking $file..."
     moc --check --package core /Users/ggreif/motoko-core/src "$file"
   done
   ```

## Motoko Core Library Reference

The Motoko core library is located at `/Users/ggreif/motoko-core/src` and contains:
- Pure data structures: `pure/Map.mo`, `pure/List.mo`, etc.
- Standard types and utilities: `Text.mo`, `Error.mo`, `Iter.mo`, etc.

You can read these files to understand the API and type signatures.

## Current Generator Features

- **Map types**: Uses destructuring type imports `import { type Map } "mo:core/pure/Map"`
  - Generates `Map<K, V>` instead of `Map.Map<K, V>`
- **Array types**: Uses Motoko array syntax `[T]`
- **Model imports**: Uses destructuring `import { type ModelName } "./ModelName"`
- **DFX mode**: Optional `useDfx` flag for IC imports

## Common Issues

1. **Import errors**: If you see "package 'core' not defined", you forgot the `--package core /Users/ggreif/motoko-core/src` flag
2. **Type errors**: Often indicate issues in the generator logic, not the generated code
3. **Missing imports**: Check that parameterized types like `Map<K,V>` are filtered from model imports

When invoked, help the user with:
- Generating samples from OpenAPI specs
- Typechecking generated Motoko code
- Debugging generator issues
- Understanding Motoko core library types
