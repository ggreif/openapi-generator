# Enum Serialization: The Janus Types Solution

This document describes the Janus Types approach for handling OpenAPI enums and oneOf discriminated unions in the Motoko generator. The solution provides type-safe bidirectional conversion between JSON representations and user-facing Motoko variant types.

**Current Support:**
- ✅ String enums with special characters (`"published!"`, `"in-progress"`)
- ✅ Numeric enums (HTTP status codes, etc.)
- ✅ OneOf discriminated unions (mixed types, inline enums)
- ✅ Nat type restriction for integers with `minimum >= 0`

## Problem Statement

When implementing OpenAPI enum support for the Motoko generator, we encountered a fundamental type system impedance mismatch between OpenAPI's JSON representation and Motoko's Candid-based type system.

### The Challenge

**OpenAPI Enums:**
- Represented as JSON strings: `"published!"`, `"in-progress"`, `"archived-2023"`
- May contain special characters (hyphens, exclamation marks, numbers)

**Motoko User-Facing Variants:**
- Type-safe enums for application code: `#published`, `#in_progress`, `#archived_2023`
- Identifiers must be valid Motoko syntax (underscores, no special chars)

**Current Serialization Flow:**
```
User-facing variant → to_candid → Candid blob → JSON.toText → JSON object
#published          →            variant      →              {"published": null}
```
**Expected:** `"published!"` (OpenAPI string)
**Actual:** `{"published": null}` (Candid variant object)

### Why Current Approaches Fail

#### 1. renameKeys Limitation
`renameKeys` in serde can map field names and variant tag names, but **cannot convert between value types**:
- ✓ Can map: `{"published": null}` → `{"published!": null}` (tag rename)
- ✗ Cannot map: `{"published": null}` → `"published!"` (type conversion)

#### 2. Deserialization Type Mismatch
When deserializing responses:

```motoko
// JSON from API
let json = "{\"status\": \"published!\"}";

// Step 1: JSON → Candid (via serde)
let blob = JSON.fromText(json, ?options);
// Problem: serde sees a JSON string, creates Candid Text value
// Candid blob contains: { status : Text } = { status = "published!" }

// Step 2: Candid → Motoko (via from_candid)
let result : ?GetEnumStatus200Response = from_candid(blob);
// Problem: Expects { status : PostStatus } variant, gets Text
// Result: null (type mismatch)
```

**The Issue:** serde has no way to know that the JSON string `"published!"` should be interpreted as a variant type during Candid encoding.

## Solution: Janus Types (Parallel Type Hierarchies)

**Codename:** "Janus" - named after the Roman god with two faces, representing the dual nature of types in this approach.

**Key Insight:** Generate parallel type hierarchies in each model module - no `serde` changes needed!

**Problem:** Enums need to be variants in Motoko (type-safe) but strings in JSON. Complex types nest these enums.

**Solution:** Each model module contains both Motoko-facing types and JSON-facing types in a sub-module, with conversion functions:

```motoko
// Generated Models/PostStatus.mo
module {
    // User-facing type: type-safe variants for application code
    public type PostStatus = {
        #in_progress;
        #published;
        #archived_2023;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing type: mirrors JSON structure (string enum → Text)
        // Named "JSON" to avoid shadowing the outer PostStatus type
        public type JSON = Text;

        // Convert user-facing type to JSON-facing type
        public func toJSON(status : PostStatus) : JSON =
            switch (status) {
                case (#in_progress) "in-progress";
                case (#published) "published!";
                case (#archived_2023) "archived-2023";
            };

        // Convert JSON-facing type to user-facing type
        public func fromJSON(json : JSON) : ?PostStatus =
            switch (json) {
                case "in-progress" ?#in_progress;
                case "published!" ?#published;
                case "archived-2023" ?#archived_2023;
                case _ null;
            };
    }
}
```

```motoko
// Generated Models/GetEnumStatus200Response.mo
// Import the type and the JSON sub-module (renamed to match the module name)
import { type PostStatus; JSON = PostStatus } "./PostStatus";

module {
    // User-facing type: what application code uses
    public type GetEnumStatus200Response = {
        status : PostStatus;
    };

    // JSON sub-module
    public module JSON {
        // JSON-facing type: what serde will serialize (mirrors JSON structure)
        // Named "JSON" to avoid shadowing the outer GetEnumStatus200Response type
        public type JSON = {
            status : PostStatus.JSON;  // This is Text (from PostStatus's JSON sub-module)
        };

        // Convert user-facing type to JSON-facing type
        public func toJSON(response : GetEnumStatus200Response) : JSON = {
            status = PostStatus.toJSON(response.status);
        };

        // Convert JSON-facing type to user-facing type
        public func fromJSON(json : JSON) : ?GetEnumStatus200Response {
            let ?status = PostStatus.fromJSON(json.status) else return null;
            ?{ status }
        };
    }
}
```

**Import Pattern for Model Files:**
```motoko
// Import type and JSON sub-module (idiom: JSON ~> PostStatus)
import { type PostStatus; JSON = PostStatus } "./PostStatus";

// Now you can use:
// - PostStatus (the user-facing variant type: #published)
// - PostStatus.JSON (the JSON-facing type: Text, from JSON sub-module)
// - PostStatus.toJSON(status) (convert user-facing → JSON-facing, from JSON sub-module)
// - PostStatus.fromJSON(jsonStatus) (convert JSON-facing → user-facing)

// With multiple models, rename each JSON sub-module:
import { type PostStatus; JSON = PostStatus } "./PostStatus";
import { type Color; JSON = Color } "./Color";
// Access as: PostStatus.JSON and Color.JSON for JSON-facing types
```

**Import Pattern for API Code:**
```motoko
// API code uses the same import idiom - no naming conflict!
import { JSON } "mo:serde";
import { type GetEnumStatus200Response; JSON = GetEnumStatus200Response } "../Models/GetEnumStatus200Response";

// Now you can use:
// - GetEnumStatus200Response (the user-facing type for application code)
// - GetEnumStatus200Response.JSON (the JSON-facing type)
// - GetEnumStatus200Response.fromJSON() (convert JSON-facing type → user-facing type)
// - JSON.fromText() (from serde, parses JSON text → Candid blob)
```

**Usage in API code:**

```motoko
import { JSON } "mo:serde";
import { type GetEnumStatus200Response; JSON = GetEnumStatus200Response } "../Models/GetEnumStatus200Response";

public func getEnumStatus() : async GetEnumStatus200Response {
    let response = await http_request(...);
    let responseText = Text.decodeUtf8(response.body);

    // Step 1: Parse JSON text to Candid blob (serde)
    let #ok(blob) = JSON.fromText(responseText, null);

    // Step 2: Validate and unpack Candid to JSON-facing Motoko type
    // Type annotation tells from_candid what structure to expect
    let ?jsonResponse : ?GetEnumStatus200Response.JSON
        = from_candid(blob)
        else throw Error.reject("Failed to deserialize JSON");
    // jsonResponse is now: { status = "published!" } (Motoko Text value)

    // Step 3: Convert JSON-facing type to user-facing type
    // This is pure Motoko type conversion (no serde involved)
    switch (GetEnumStatus200Response.fromJSON(jsonResponse)) {
        case (?userResponse) userResponse;
        // userResponse is now: { status = #published } (user-facing variant)
        case null throw Error.reject("Failed to convert between types");
    }
}
```

**Why This Works Without Serde Modifications:**

The key is **separation of concerns** - model files handle type conversions, API code handles JSON/Candid:

**In Model Files:**
- Define two types: user-facing (`#published`) and JSON-facing (`"published!"`)
- Provide conversion functions between these types
- No JSON or serde involvement at all

**In API Code:**
1. `JSON.fromText` (from serde) parses JSON `{"status": "published!"}` into Candid blob
2. `from_candid` with type annotation `: ?GetEnumStatus200Response.JSON` validates the blob as `record { status : text }`
3. Result is a JSON-facing value: `{ status = "published!" }`
4. `GetEnumStatus200Response.fromJSON()` converts to user-facing value: `{ status = #published }`

The JSON-facing type mirrors JSON structure so serde produces correct output, but it's still just Motoko!

**Benefits:**
- ✅ **Works with existing tooling**: Standard moc compiler and serde library
- ✅ **Clean organization**: JSON types in sub-modules, clear separation of concerns
- ✅ **Type safety**: All conversions are explicit and type-checked at compile time
- ✅ **Composable**: Types naturally compose (nested enums, arrays, optionals all work)
- ✅ **User-friendly**: Application code works with idiomatic Motoko variants
- ✅ **Implementable immediately**: No waiting for compiler or library changes

**Generator Strategy:**
1. For each enum type, generate both variant type and appropriate JSON-facing type
2. For each model with enums, generate both record types
3. Generate conversion functions that traverse the structure
4. API code deserializes to JSON-facing types, then converts
5. **Simplified renameKeys usage**: Only for field names with hyphens/reserved words, NOT for enum variants

**Important Note on renameKeys:**
With parallel type hierarchies, `renameKeys` is simplified to **only handle field name escaping**:
- ❌ **NOT for enum variants**: Mapping like `#published` ↔ `"published!"` is done in pure Motoko through `toJSON/fromJSON` functions
- ✅ **Only for field names**: Mapping like `content-type` ↔ `content_type` or `try` ↔ `try_`
- **Separation of concerns**: Model files handle enum value conversions, serde's renameKeys handles field name escaping

**Handling Different Enum Types:**

1. **String Enums** (most common):
   ```motoko
   // OpenAPI: enum: ["in-progress", "published!", "archived-2023"]
   public type PostStatus = { #in_progress; #published; #archived_2023 };
   public module JSON {
       public type JSON = Text;
       // toJSON/fromJSON switch on string values
   }
   ```

2. **Numeric Enums** (HTTP status codes, etc.):
   ```motoko
   // OpenAPI: enum: [200, 404, 500]
   public type HTTPStatus = { #_200_; #_404_; #_500_ };
   public module JSON {
       public type JSON = Int;  // JSON-facing: actual numbers (use Int for OpenAPI integer type)
       public func toJSON(status : HTTPStatus) : JSON =
           switch (status) {
               case (#_200_) 200;
               case (#_404_) 404;
               case (#_500_) 500;
           };
       public func fromJSON(json : JSON) : ?HTTPStatus =
           // Since Nat is a subtype of Int, we can directly match Int values against Nat patterns
           // Negative values naturally fall through to the default case
           switch (json) {
               case 200 ?#_200_;
               case 404 ?#_404_;
               case 500 ?#_500_;
               case _ null;
           };
   }
   ```

3. **OneOf Types** (discriminated unions):
   ```motoko
   // OpenAPI: oneOf with multiple schemas or inline enums
   // Example: { oneOf: [{ type: "integer", minimum: 0 }, { enum: ["up", "down"] }] }
   public type VolumeParameter = {
       #nat : Nat;      // Integer with minimum >= 0
       #up;             // Inline enum expanded to unit variants
       #down;
   };
   public module JSON {
       // Both Motoko-facing and JSON-facing use variants
       // Supports mixed types: Nat (from minimum >= 0), strings, etc.
       public type JSON = {
           #nat : Int;  // JSON sends Int, Motoko converts to Nat
           #up;
           #down;
       };
       public func toJSON(param : VolumeParameter) : JSON =
           switch (param) {
               case (#nat(n)) #nat(n);  // Nat is subtype of Int
               case (#up) #up;
               case (#down) #down;
           };
       public func fromJSON(json : JSON) : ?VolumeParameter {
           switch (json) {
               case (#nat(i)) if (i >= 0) ?#nat(Int.abs(i)) else null;
               case (#up) ?#up;
               case (#down) ?#down;
           }
       };
   }
   ```

   **OneOf Implementation Details:**
   - Inline enums are expanded into multiple unit variants
   - Integer types with `minimum >= 0` become `Nat` variants
   - Supports mixed types (integers, strings, objects)
   - JSON-facing type uses variants (not Text/Int like simple enums)

4. **Arrays of Enums**:
   ```motoko
   // OpenAPI: items: { $ref: '#/components/schemas/PostStatus' }
   import { type PostStatus; PS = PostStatus } "./PostStatus";

   public type StatusList = {
       statuses : [PostStatus];
   };
   public module JSON {
       public type JSON = {
           statuses : [PS.JSON];  // [Text]
       };
       public func fromJSON(json : JSON) : ?StatusList {
           // Map conversion function over array
           let ?statuses = convertArray(json.statuses, PS.fromJSON);
           ?{ statuses }
       };
   }
   ```

5. **Optional Fields** (OpenAPI `required: false`):
   ```motoko
   // These map to Motoko ?T as before - no special handling needed
   public type User = {
       name : Text;
       email : ?Text;  // optional in OpenAPI
   };
   // JSON-facing type is identical (serde handles ?T naturally)
   ```

**Type System Compatibility:**

- **JSON → Candid**: All JSON types (object, array, string, number, boolean, null) map naturally to Candid types
- **Candid → Motoko**: All non-esoteric Candid types fit into Motoko's type system
- **Type Annotation Validation**: `from_candid` with type annotation validates structure
- **Transformation Layer**: `module JSON` provides flexible transformation between representations

**Why Janus Types Work:**

- ✅ **No new primitives**: Works with existing moc compiler
- ✅ **No serde changes**: Uses existing JSON serialization as-is
- ✅ **Explicit conversions**: Type-safe, generated conversion functions
- ✅ **Natural composability**: Types compose naturally (nested enums work)
- ✅ **Implementable immediately**: No compiler or library changes needed

## Benefits of Janus Types

### 1. Natural OpenAPI Mapping
- String enums in OpenAPI specs map cleanly to Motoko variants
- Generated conversion functions handle the mapping
- Clean, type-safe code with no runtime surprises

### 2. Solves Both Directions
- **Deserialization:** JSON strings → JSON-facing types → user-facing variants
- **Serialization:** User-facing variants → JSON-facing types → JSON strings
- Bidirectional with explicit, type-checked conversions

### 3. Leverages Existing Patterns
- Uses standard Motoko module system
- `renameKeys` handles field name escaping only
- Standard serde JSON serialization
- No special compiler or library features needed

### 4. Future Extensions
The same Janus pattern can handle other type conversions:

#### Option Type Encoding (`?T`)
The Janus pattern can be extended to handle optional field encoding choices:

**Array-based encoding (for complex types):**
```motoko
// JSON-facing type uses arrays for optionals
public module JSON {
    public type JSON = {
        name : Text;
        email : [Text];  // Empty array or singleton for ?Text
    };

    public func toJSON(profile : UserProfile) : JSON {
        {
            name = profile.name;
            email = switch (profile.email) {
                case (?e) [e];
                case null [];
            };
        }
    };
}
```

**Null-based encoding (when unambiguous):**
```motoko
// JSON-facing type uses null directly (standard serde behavior)
public module JSON {
    public type JSON = {
        name : Text;
        email : ?Text;  // Direct null encoding
    };
    // toJSON is identity, no conversion needed
}
```

**Future possibilities:**
- Optional fields with default values
- Numeric type coercion (Int ↔ Float)
- Date/time string formats (ISO8601 ↔ Int timestamps)
- Custom type mappings for domain-specific types

## Summary

The **Janus Types** approach elegantly solves the OpenAPI enum challenge:

- **Two-faced types:** Each model has both user-facing (variants) and JSON-facing (Text/Int) representations
- **Explicit conversions:** Generated `toJSON/fromJSON` functions provide type-safe bridging
- **No magic:** All conversions are visible and type-checked at generation time
- **Works today:** Uses existing moc compiler and serde library
- **Extensible:** Pattern applies to other type conversion needs (optionals, timestamps, etc.)
- **OneOf support:** OpenAPI `oneOf` schemas generate as discriminated unions with mixed variant types

This approach bridges the impedance mismatch between OpenAPI's JSON representation and Motoko's type system while maintaining full type safety and requiring no compiler or library changes.

## URL Parameter Serialization with toText()

### Problem

OneOf types used in URL query parameters and path parameters cannot use the standard JSON serialization:
- JSON serialization produces JSON objects or requires Candid conversion
- URL parameters need plain text strings: `volume=42` or `status=published`
- Need variant-aware text conversion for mixed oneOf types (combining integers, enums, and objects)

### Solution: toText() Helper Function

For oneOf types, the generator automatically creates a `toText()` function in the JSON sub-module that converts each variant to its URL-safe text representation. This function handles the different variant types appropriately:

**Generated Pattern:**
```motoko
module {
    public type VolumeParameter = {
        #one_of_0 : Nat;                      // Integer variant
        #VolumeParameterOneOf : VolumeParameterOneOf;  // Enum variant
    };

    public module JSON {
        // URL parameter serialization
        public func toText(value : VolumeParameter) : Text =
            switch (value) {
                case (#one_of_0(v)) Int.toText(v);
                case (#VolumeParameterOneOf(v)) VolumeParameterOneOf.toJSON(v);
            };

        // JSON body serialization (existing)
        public func toJSON(value : VolumeParameter) : JSON = ...
        public func fromJSON(json : JSON) : ?VolumeParameter = ...
    }
}
```

### Variant Type Conversion Rules

Each variant type in a oneOf discriminated union requires specific text conversion logic:

| Variant Type | Conversion Logic | Example Input | Example Output |
|--------------|-----------------|---------------|----------------|
| **Numeric (Nat/Int)** | `Int.toText(v)` | `#one_of_0(42)` | `"42"` |
| **Enum Model** | `{Type}.toJSON(v)` | `#VolumeParameterOneOf(#up)` | `"up"` |
| **Object/Record** | `debug_show(v)` | `#MixedOneOfOneOf({custom="foo"})` | `"{custom = \"foo\"}"` |
| **Unit Variant** | String literal | `#up` | `"up"` |

**Rationale:**
- **Numeric types**: Use standard Motoko text conversion
- **Enum models**: Reuse existing `toJSON()` which already returns Text with proper escaping
- **Complex objects**: Use `debug_show()` for readable serialization
- **Unit variants**: Use the original enum value as a string literal

### API Usage Pattern

The API template automatically detects oneOf types and uses the appropriate serialization method:

**Query Parameters with oneOf:**
```motoko
// Generated API code automatically uses toText() for oneOf parameters
public func setVolume(config : Config__, volume : VolumeParameter, zone : Text) : async* SetVolume200Response {
    let url = baseUrl # "/set-volume"
        # "?" # "volume=" # VolumeParameter.toText(volume)  // Uses toText()
        # "&" # "zone=" # zone;
    // ... rest of implementation
}
```

**Path Parameters with oneOf:**
```motoko
// Path parameters also use toText() when the parameter type is oneOf
let url = baseUrl # "/items/{id}"
    |> Text.replace(_, #text "{id}", ItemId.toText(itemId));  // Uses toText()
```

**Simple Enums (non-oneOf):**
```motoko
// Simple enums continue to use toJSON() which also returns Text
public func getStatus(config : Config__, status : PostStatus) : async* Response {
    let url = baseUrl # "/get-status"
        # "?" # "status=" # PostStatus.toJSON(status);  // Uses toJSON()
    // ...
}
```

### Implementation Details

**Java Code Generation:**

1. **In `MotokoClientCodegen.fromModel()`** (lines 429-509):
   - Add type classification flags to each oneOf variant:
     - `isNumericType`: true for Int/Nat types
     - `isEnumType`: true for enum model references
     - `isObjectType`: true for complex record types
   - These flags guide template logic for generating the correct conversion

2. **In `MotokoClientCodegen.postProcessOperationsWithModels()`** (lines 1093-1119):
   - Check each operation parameter's dataType against all models
   - If parameter type matches a oneOf model (has `x-is-oneof` vendor extension), mark the parameter with `x-is-oneof-type` vendor extension
   - This flag tells the API template to use `.toText()` instead of `.toJSON()`

**Template Logic:**

1. **In `model.mustache`** (oneOf section, lines 62-103):
   - Generate `toText()` function before `toJSON()` in the JSON sub-module
   - Use type classification flags to emit the correct conversion for each variant
   - Handle unit variants (inline enums) with string literals from `enumValue`

2. **In `api.mustache`** (lines 85-86):
   - Check for `x-is-oneof-type` vendor extension first
   - If present, use `{Type}.toText()` for URL serialization
   - Otherwise, fall back to existing logic (`toJSON()` for enums, `Int.toText()` for integers, etc.)

### Benefits

1. **Type Safety**: Compile-time verification of variant conversions through Motoko's type checker
2. **Correctness**: Proper URL encoding for all variant types, matching OpenAPI semantics
3. **Consistency**: Unified approach across all oneOf types regardless of variant composition
4. **Extensibility**: Easy to add new conversion patterns for additional Motoko types
5. **Separation of Concerns**: URL serialization (`toText()`) is distinct from JSON body serialization (`toJSON()`)

### Examples from Test Suite

Real-world examples from the enum-test client demonstrate the pattern:

**VolumeParameter (Integer + Enum):**
```motoko
// samples/client/enum-test/generated/Models/VolumeParameter.mo (lines 19-23)
public func toText(value : VolumeParameter) : Text =
    switch (value) {
        case (#one_of_0(v)) Int.toText(v);  // Nat variant → Int.toText
        case (#VolumeParameterOneOf(v)) VolumeParameterOneOf.toJSON(v);  // Enum → .toJSON
    };
```

**MixedOneOf (Integer + Enum + Object):**
```motoko
// samples/client/enum-test/generated/Models/MixedOneOf.mo (lines 22-27)
public func toText(value : MixedOneOf) : Text =
    switch (value) {
        case (#one_of_0(v)) Int.toText(v);  // Int variant
        case (#SimpleColorEnum(v)) SimpleColorEnum.toJSON(v);  // Enum variant
        case (#MixedOneOfOneOf(v)) debug_show(v);  // Object variant
    };
```

**API Usage:**
```motoko
// samples/client/enum-test/generated/Apis/DefaultApi.mo (line 75)
let url = baseUrl # "/set-volume"
    # "?" # "volume=" # VolumeParameter.toText(volume)  // Automatic toText() usage
    # "&" # "zone=" # zone;
```

### Comparison: toText() vs toJSON()

| Feature | toText() (oneOf) | toJSON() (simple enums) |
|---------|-----------------|------------------------|
| **Purpose** | URL parameter serialization | JSON body serialization |
| **Input** | OneOf variant with mixed types | Simple enum variant |
| **Output** | Plain Text string | Text (for string enums) or Int (for numeric enums) |
| **Used by** | Path/query parameter handling in API template | Both URL parameters and JSON body serialization |
| **Type handling** | Variant-specific logic (Int.toText, .toJSON, debug_show) | Uniform mapping to JSON values |
| **When generated** | For oneOf types only | For all enum types |

**Note:** Simple enum types can use `toJSON()` for both URL parameters and JSON body serialization because the result is always Text. OneOf types need `toText()` specifically for URL parameters because they may contain non-text types that require conversion.

## Historical Context: Initial Implementation Attempt

**Note:** This section describes the initial implementation attempt using `renameKeys` only. See "Solution: Janus Types (Parallel Type Hierarchies)" above for the working approach.

The Motoko OpenAPI generator initially implemented basic enum support using `renameKeys`:
- ✓ Enums generate as Motoko variant types
- ✓ Identifier sanitization for special characters
- ✓ `renameKeys` mappings for bidirectional name conversion (attempted for both field names and enum variants)
- ✓ Code compiles and type-checks

However, runtime JSON serialization failed due to the type conversion issue described above:
- ✗ JSON string → Motoko variant (deserialization fails at `from_candid`)
- ✗ Motoko variant → JSON string (serialization emits variant object)
- ✗ `renameKeys` alone cannot convert between value types (Text vs variant)

See git notes on commit `abb7b6e00d6` for detailed debugging information and test results.

## Test Cases Demonstrating the Issue

### Test 1: GeoJSON Triple-Nested Arrays
**Spec:** `[[[Float]]]` coordinates in GeoJSON Polygon geometry
**JSON:** `{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-122.4194,37.7749],...]]}},"properties":{"name":null}}`
**Status:** ✗ `from_candid` returns null
**Reason:** Type schema mismatch - serde can't infer deeply nested array structure

### Test 2: Enum Return Type
**Spec:** `PostStatus` enum with values `["in-progress", "published!", "archived-2023"]`
**JSON:** `{"status": "published!"}` (OpenAPI string format)
**Attempted:** `{"status": {"published": null}}` (Candid variant format)
**Status:** ✗ Both formats fail at `from_candid`
**Reason:** String format creates Text type in Candid blob, variant format doesn't match expected structure

## Investigation Findings

### Transform Callbacks Work
- ✓ Transform callbacks are executed (confirmed via debug output)
- ✓ JSON structures are generated correctly
- ✓ `JSON.fromText` succeeds (no parse errors)
- ✓ `renameKeys` is configured correctly in `allDecodeMappings`

### Failure Point
- ✗ Failure occurs at `from_candid` deserialization step
- ✗ `from_candid` returns `null` indicating type mismatch
- ✗ Candid blob structure doesn't match expected Motoko type

### Root Cause
**Type Conversion Gap:** serde's `JSON.fromText` creates Candid blob based on JSON structure alone, without knowledge of the target Motoko type. This causes:
1. JSON strings → Candid Text (not variants)
2. Deeply nested JSON arrays → incorrect Candid array nesting

**Solution:** The Janus Types approach sidesteps this issue by using JSON-facing Motoko types (Text, Int) that naturally match the JSON structure, then explicitly converting to variant types in application code.

## Related Work and Test Files

### Serde Source References
- **Variant encoding:** `/Users/ggreif/serde/src/Candid/Blob/Encoder.mo:473`
- **Variant decoding:** `/Users/ggreif/serde/src/Candid/Blob/Decoder.mo:892`
- **Options definition:** `/Users/ggreif/serde/src/Candid/Types.mo:113`
- **renameKeys examples:** `/Users/ggreif/serde/tests/JSON.Test.mo:139`

### Test Files
- **Transform callbacks:** `samples/client/jsonplaceholder/motoko-test/src/main.mo`
- **Debug API code:** `samples/client/jsonplaceholder/motoko-test/generated/Apis/DefaultApi.mo`
- **Enum mappings:** `samples/client/jsonplaceholder/motoko-test/generated/EnumMappings.mo`
