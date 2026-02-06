# Motoko Import Idiom for Parallel Type Hierarchies

## The Pattern

When working with Motoko modules that have parallel type hierarchies (a user-facing type and a JSON sub-module with JSON-facing types and conversion functions), use this import idiom:

```motoko
import { type PostStatus; JSON = PostStatus } "./PostStatus";
```

## What This Does

This import statement does two things:

1. **Imports the type**: `type PostStatus` imports the user-facing variant type (e.g., `#published`, `#in_progress`)
2. **Imports and renames the JSON sub-module**: `JSON = PostStatus` imports the `JSON` sub-module from the PostStatus module and renames it locally to `PostStatus`

The idiom is: **`JSON ~> PostStatus`** (JSON sub-module becomes PostStatus locally)

## Why This Works

Motoko has separate namespaces for types and modules, so you can have:
- `PostStatus` as the type
- `PostStatus` as the module (which is actually the renamed JSON sub-module)

## Usage After Import

After this import, you have access to:

```motoko
// 1. The user-facing variant type
let status : PostStatus = #published;

// 2. The JSON-facing Motoko type (from the JSON sub-module)
let jsonStatus : PostStatus.JSON = "published!";  // This is Text

// 3. Conversion function: user-facing → JSON-facing
let converted : PostStatus.JSON = PostStatus.toJSON(status);

// 4. Conversion function: JSON-facing → user-facing
let parsed : ?PostStatus = PostStatus.fromJSON(jsonStatus);
```

## Multiple Imports

When importing multiple models with JSON sub-modules, each gets its own renamed module:

```motoko
import { type PostStatus; JSON = PostStatus } "./PostStatus";
import { type Color; JSON = Color } "./Color";
import { type Priority; JSON = Priority } "./Priority";

// Each JSON sub-module is renamed to match its type:
let status = PostStatus.toJSON(#published);      // Returns PostStatus.JSON (Text)
let color = Color.toJSON(#blue_green);           // Returns Color.JSON (Text)
let priority = Priority.toJSON(#high);           // Returns Priority.JSON (Text)
```

## Module Structure

This import pattern works with modules structured like:

```motoko
// Models/PostStatus.mo
module {
    // user-facing type: type-safe variants
    public type PostStatus = {
        #in_progress;
        #published;
        #archived_2023;
    };

    // JSON sub-module: JSON-facing types and conversions
    public module JSON {
        // JSON-facing Motoko type (mirrors JSON structure)
        // Named "JSON" to avoid shadowing the outer PostStatus type
        public type JSON = Text;

        // Convert user-facing → JSON-facing
        public func toJSON(status : PostStatus) : JSON {
            switch (status) {
                case (#in_progress) "in-progress";
                case (#published) "published!";
                case (#archived_2023) "archived-2023";
            }
        };

        // Convert JSON-facing → user-facing
        public func fromJSON(json : JSON) : ?PostStatus {
            switch (json) {
                case "in-progress" ?#in_progress;
                case "published!" ?#published;
                case "archived-2023" ?#archived_2023;
                case _ null;
            }
        };
    }
}
```

## Why Name the JSON-Facing Type "JSON"?

Within the JSON sub-module, the JSON-facing type is always named `JSON` (not the same as the model name) to **avoid shadowing**:

```motoko
public module JSON {
    public type JSON = Text;  // ✅ Named "JSON" - no shadowing

    public func toJSON(status : PostStatus) : JSON {
        // PostStatus refers to outer variant type (unshadowed)
        // JSON refers to this module's Text type
        switch (status) { ... }
    }
}
```

If we named it the same as the model:
```motoko
public module JSON {
    public type PostStatus = Text;  // ❌ Shadows outer PostStatus!

    public func toJSON(status : PostStatus) : PostStatus {
        // Both PostStatus references are now Text, not the variant!
        // This breaks the function signature
    }
}
```

## Common Mistakes to Avoid

❌ **Don't use different names for import**: `import { type PostStatus; JSON = PS }` creates naming inconsistency

❌ **Don't think JSON becomes the type**: The `JSON = PostStatus` syntax renames the JSON sub-module to PostStatus, not the other way around

❌ **Don't access as `JSON.something`**: After renaming, use `PostStatus.JSON`, `PostStatus.toJSON()`, not `JSON.JSON` or `JSON.toJSON()`

❌ **Don't shadow types in JSON module**: Always use `public type JSON = ...` within the JSON sub-module, not the model name

## Context

This pattern is used in OpenAPI-generated Motoko clients where:
- Models have type-safe user-facing variants for application code
- Models have JSON-facing types (Text, Nat, etc.) that mirror JSON structure
- Conversion functions bridge between the two representations
- No runtime type introspection or serde modifications needed

## When NOT to Use This Pattern

1. **For primitive types**: Don't use this for built-in types like `Text`, `Nat`, `Bool`, etc.
2. **For types without JSON sub-modules**: Only use when the imported module has a `JSON` sub-module
3. **For non-Janus types**: This pattern is specific to Janus Types - don't use for regular imports

## IMPORTANT: Never Create Model Files for Primitives

**Primitive types should NEVER have corresponding `.mo` model files:**

```motoko
// ❌ WRONG - Never create Any.mo, Text.mo, Int.mo, etc.
// These are built-in Motoko types and don't need model files

// ❌ WRONG - Never import primitives as if they were models
import { type Any; JSON = Any } "./Any";  // DON'T DO THIS!

// ✅ CORRECT - Use primitives directly
let value : Any = ...;  // Just use the type directly
```

**Primitive types that should NOT have model files:**
- `Any` - generic any type (used for `object` in OpenAPI)
- `Text` - strings
- `Nat`, `Int` - numbers
- `Float` - floating point
- `Bool` - booleans
- `Blob` - binary data
- `Principal` - IC principals
- `Null` - null type

**Why this matters:**
1. Primitive types don't need JSON conversion (they're already JSON-compatible)
2. Creating `Any.mo` would shadow the built-in `Any` type
3. The generator detects primitives and skips `.JSON` conversion automatically
4. Attempting to import non-existent model files causes compilation errors

**Detection in generator:**
The OpenAPI generator's `isPrimitiveOrMappedType()` method detects these types and:
- Skips creating model files for them
- Avoids `.JSON` type references (uses `?Any` not `?Any.JSON`)
- Uses direct serialization (no `toJSON`/`fromJSON` calls)

**Example: Correct handling of primitives in generated code**

```motoko
// API response with primitive type
public func getJson(config : Config__) : async* Any {
    // ...
    from_candid(_) : ?Any |>  // ✅ Direct ?Any, not ?Any.JSON
    (switch (_) {
        case (?result) result;  // ✅ No fromJSON call needed
        case null throw Error.reject("Failed to deserialize");
    })
}
```
