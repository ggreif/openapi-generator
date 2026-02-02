# Motoko Enum Implementation Plan

## Overview

Implement proper OpenAPI enum support in the Motoko generator using Motoko variant types with runtime serialization/deserialization via serde's `renameKeys` option.

---

## Key Discovery: serde renameKeys for Variant Mapping

The serde library's `Options.renameKeys` field works for **both record keys AND variant tags**!

### How It Works

```motoko
// Decoding: JSON → Motoko
let options = {
    Candid.defaultOptions with
    renameKeys = [("blue-green", "blue_green")]
};
let #ok(blob) = JSON.fromText("{\"color\": \"blue-green\"}", ?options);
let value : { color: ColorEnum } = from_candid(blob);
// Result: { color = #blue_green }

// Encoding: Motoko → JSON
let options = {
    Candid.defaultOptions with
    renameKeys = [("blue_green", "blue-green")]
};
let blob = to_candid({ color = #blue_green });
let #ok(jsonText) = JSON.toText(blob, [], ?options);
// Result: "{\"color\": \"blue-green\"}"
```

### Source Code References

- **Encoding**: `/Users/ggreif/serde/src/Candid/Blob/Encoder.mo:473`
  - `let variant_key = get_renamed_key(renaming_map, variant.0);`
- **Decoding**: `/Users/ggreif/serde/src/Candid/Blob/Decoder.mo:892`
  - `#Variant(get_renamed_key(renaming_map, variant_key), value);`
- **Options Definition**: `/Users/ggreif/serde/src/Candid/Types.mo:113`
  - `renameKeys : [(Text, Text)];`

---

## Current Status

### ✅ Already Working

- Enum type definitions generated as variant types (e.g., `PostStatus.mo`)
- Models using enum types compile correctly with moc
- Type-safe pattern matching available
- Exhaustiveness checking works

### ❌ Missing

- Runtime serialization/deserialization with correct enum value mapping
- Generator doesn't pass `renameKeys` options during API calls
- No handling of special characters (hyphens, spaces, etc.) in enum values
- No proper handling of numeric enums (currently wraps as `#_100_`, `#_200_`)
- **Bidirectional mapping for escaped identifiers**: When Motoko identifiers need escaping, we need separate encode/decode mappings. This applies to:
  - **Enum variants**: `#blue_green` ↔ `"blue-green"` (special chars), `#_200_` ↔ `"200"` (numeric)
  - **Record/object fields**: `content_type` ↔ `"content-type"` (hyphens), `try_` ↔ `"try"` (reserved words)
  - Both use the same renameKeys mechanism for proper JSON round-tripping

---

## Implementation Plan

### Phase 1: Generator Changes

#### 1.1 Collect Enum Mappings (Java Side)

**File**: `MotokoClientCodegen.java`

**Location**: In `postProcessModelsEnum()` or similar model processing hook

**Task**: For each enum, collect mappings where Motoko name ≠ OpenAPI value

**Data Structure**:
```java
// Map from enum type name to list of (motoko_name, openapi_value) pairs
Map<String, List<Pair<String, String>>> enumMappings = new HashMap<>();
```

**Examples Needing Mapping**:
- `"blue-green"` → `"blue_green"` (hyphen)
- `"Available Now!"` → `"Available_Now_"` (space + punctuation)
- `"100"` → `"_100_"` (numeric)
- `"café"` → `"caf_"` (unicode)

**Escaping Rules**:
- Replace non-alphanumeric with underscore
- Prefix with underscore if starts with digit
- Append underscore if reserved word or reserved identifier (e.g., `try` → `try_`, `to_candid` → `to_candid_`)
- Preserve case for human readability
- Store bidirectional mappings (encode vs decode)

**Reserved Identifiers to Check**:
- Motoko keywords: try, type, switch, for, while, if, else, case, etc.
- Reserved built-ins: `to_candid`, `from_candid`, `debug_show`

**Note**: The same escaping and mapping approach applies to record/object field names:
- OpenAPI field: `"content-type"` → Motoko field: `content_type`
- OpenAPI field: `"try"` (reserved word) → Motoko field: `try_`
- OpenAPI field: `"to_candid"` (reserved built-in) → Motoko field: `to_candid_`
- These mappings should be collected alongside enum mappings

#### 1.2 Generate Enum and Field Mapping Module

**File**: Create new template `enumMappings.mustache`

**Output**: `EnumMappings.mo` (or `IdentifierMappings.mo`)

**Scope Decision**: **Global mappings for entire API** (not per-endpoint)

**Rationale**:
- **Simplicity**: Single source of truth, easier to implement and maintain
- **Consistency**: All operations use same mappings, no behavioral inconsistencies
- **No name clash risk**: Same JSON names always map to same Motoko names
- **Expected small size**: Most APIs have ~50-100 mappings total, negligible overhead
- **Debug-friendly**: Single file to inspect when troubleshooting

**Future Optimization**: Per-endpoint mappings could be added later if profiling shows renameKeys overhead is significant, but this is unlikely for typical APIs.

**Structure**:
```motoko
// EnumMappings.mo - Global mappings for all operations
//
// This module contains all identifier mappings for the entire API.
// While each operation receives all mappings (even unused ones),
// the overhead is negligible and the simplicity is worth it.
// Future optimization could generate per-endpoint mappings if needed.
//
// Handles both enum variant names and record field names that need escaping.
module {
    // Enum variant mappings
    public let ColorEnumOptions = {
        encode = [("blue_green", "blue-green"), ("ultra_violet", "ultra-violet")];
        decode = [("blue-green", "blue_green"), ("ultra-violet", "ultra_violet")];
    };

    public let HTTPStatusEnum = {
        encode = [("_200_", "200"), ("_404_", "404"), ("_500_", "500")];
        decode = [("200", "_200_"), ("404", "_404_"), ("500", "_500_")];
    };

    public let AvailabilityEnum = {
        encode = [("Available_Now_", "Available Now!"), ("Out_of_Stock", "Out of Stock")];
        decode = [("Available Now!", "Available_Now_"), ("Out of Stock", "Out_of_Stock")];
    };

    // Record field mappings (when fields need escaping)
    public let HttpHeaderFieldOptions = {
        encode = [("content_type", "content-type"), ("cache_control", "cache-control")];
        decode = [("content-type", "content_type"), ("cache-control", "cache_control")];
    };

    public let ReservedWordFieldOptions = {
        encode = [("try_", "try"), ("type_", "type"), ("to_candid_", "to_candid"), ("from_candid_", "from_candid"), ("debug_show_", "debug_show")];
        decode = [("try", "try_"), ("type", "type_"), ("to_candid", "to_candid_"), ("from_candid", "from_candid_"), ("debug_show", "debug_show_")];
    };
}
```

**Template Variables**:
- `{{enumTypeName}}`: The enum type name
- `{{modelTypeName}}`: The model/record type name (for field mappings)
- `{{encodeMapping}}`: List of (motoko_name, json_value) pairs
- `{{decodeMapping}}`: List of (json_value, motoko_name) pairs

**Note**: Generate mapping options for:
1. Each enum type with escaped variant names
2. Each model/record with escaped field names (hyphens, reserved words, etc.)

#### 1.3 Update API Template

**File**: `modules/openapi-generator/src/main/resources/motoko/api.mustache`

**Approach**: Since we use global mappings, build the complete renameKeys arrays once at module initialization and reuse them for all operations.

**Changes**:

1. **Import EnumMappings**:
```motoko
import EnumMappings "../EnumMappings";
```

2. **Build Global Mapping Arrays** (at module top level):
```motoko
// Global encoding/decoding options built once from all mappings
{{#hasAnyMappings}}
let allEncodeMappings : [(Text, Text)] = buildMappingOptions([
    {{#enumTypes}}EnumMappings.{{name}}Options.encode{{^-last}}, {{/-last}}{{/enumTypes}}{{#hasModelMappings}},{{/hasModelMappings}}
    {{#modelTypesWithEscapedFields}}EnumMappings.{{name}}FieldOptions.encode{{^-last}}, {{/-last}}{{/modelTypesWithEscapedFields}}
]);

let allDecodeMappings : [(Text, Text)] = buildMappingOptions([
    {{#enumTypes}}EnumMappings.{{name}}Options.decode{{^-last}}, {{/-last}}{{/enumTypes}}{{#hasModelMappings}},{{/hasModelMappings}}
    {{#modelTypesWithEscapedFields}}EnumMappings.{{name}}FieldOptions.decode{{^-last}}, {{/-last}}{{/modelTypesWithEscapedFields}}
]);
{{/hasAnyMappings}}
```

3. **Request Body Serialization** (when sending data):
```motoko
{{#bodyParam}}
let requestOptions = {
    Candid.defaultOptions with
    renameKeys = {{#hasAnyMappings}}allEncodeMappings{{/hasAnyMappings}}{{^hasAnyMappings}}[]{{/hasAnyMappings}};
};
let requestBlob = to_candid({{paramName}});
let #ok(requestJson) = JSON.toText(requestBlob, [], ?requestOptions) else {
    throw Error.reject("Failed to serialize request body");
};
{{/bodyParam}}
```

4. **Response Deserialization** (when receiving data):
```motoko
let responseOptions = {
    Candid.defaultOptions with
    renameKeys = {{#hasAnyMappings}}allDecodeMappings{{/hasAnyMappings}}{{^hasAnyMappings}}[]{{/hasAnyMappings}};
};
let #ok(jsonBlob) = JSON.fromText(responseText, ?responseOptions) else {
    throw Error.reject("Failed to parse JSON: " # responseText);
};
```

5. **Helper Function** (add to API module):
```motoko
// Merge multiple mapping option arrays into single renameKeys array
func buildMappingOptions(options: [[(Text, Text)]]) : [(Text, Text)] {
    let buffer = Buffer.Buffer<(Text, Text)>(8);
    for (mappingArray in options.vals()) {
        for (pair in mappingArray.vals()) {
            buffer.add(pair);
        };
    };
    Buffer.toArray(buffer)
}
```

**Benefits of Global Approach**:
- No need to track which types each operation uses
- Mappings built once at initialization, not per request
- Simpler template logic
- Same mappings guaranteed across all operations

#### 1.4 Collect All Enums and Models with Escaped Fields

**Task**: Build global lists of all enum types and all models with escaped fields across the entire API

**Collections Needed** (at API-level, not per-operation):

1. **All Enum Types**: List of all enums defined in OpenAPI spec
2. **All Models with Escaped Fields**: List of all models that have at least one field requiring escaping

**Mark in API Codegen Context**:
```java
// Global flags
apiContext.put("hasAnyMappings", !enumTypes.isEmpty() || !modelsWithEscapedFields.isEmpty());
apiContext.put("enumTypes", allEnumTypesList); // All enums in spec
apiContext.put("modelTypesWithEscapedFields", modelsWithEscapedFieldsList); // Only models with escaped fields
apiContext.put("hasModelMappings", !modelsWithEscapedFields.isEmpty());
```

**Detection Logic**:
- Scan all schemas once during API processing
- For each enum: add to `enumTypes` list
- For each model: check if any field name needs escaping, if so add to `modelTypesWithEscapedFields`
- No per-operation tracking needed with global approach

**Escaping Check**: Field needs escaping if:
- Contains hyphens, spaces, or special characters
- Starts with a digit
- Is a Motoko reserved word or reserved identifier:
  - **Keywords**: try, type, switch, for, while, if, else, case, class, func, public, private, shared, query, async, await, actor, system, module, import, object, let, var, stable, flexible, etc.
  - **Reserved identifiers**: `to_candid`, `from_candid`, `debug_show` (Motoko built-ins that should not be shadowed)

#### 1.5 Name Clash Handling

**Question**: What if two different JSON names map to the same Motoko identifier?

**Answer**: This is **not a concern** with the global approach:

**Case 1 - Same JSON name in multiple schemas**: ✅ No problem
- Example: Both `HttpRequest.content-type` and `HttpResponse.content-type` exist
- Both map to `content_type` in Motoko
- renameKeys: `[("content_type", "content-type")]` - single entry works for both
- JSON round-trips correctly for both types

**Case 2 - Different JSON names in same schema**: ❌ Would be a problem (but won't happen)
- Example: Schema has both `"content-type"` and `"content_type"` fields
- Both would map to `content_type` in Motoko - collision!
- But this is invalid schema design (duplicate semantic meaning)
- Generator should detect and error

**Case 3 - Different JSON names across schemas**: ❌ Theoretical problem
- Example: `SchemaA.try` (reserved word) → `try_` and `SchemaB."try-it"` → `try_`?
- Extremely unlikely in practice
- If occurs: Generator should detect collision and error with clear message
- User must fix OpenAPI spec (rename one of the fields)

**Implementation**: Generator validates no Motoko name collisions within each schema. Cross-schema collisions are acceptable (same JSON → same Motoko = consistent).

---

### Phase 2: Testing Strategy

#### 2.1 Unit Tests (Java)

**Test File**: `MotokoClientCodegenTest.java`

**Test Cases**:
1. **Simple enum** (no special chars)
   - Input: `["red", "green", "blue"]`
   - Expected: No mappings needed

2. **Hyphenated enum**
   - Input: `["blue-green", "ultra-violet"]`
   - Expected: `[("blue_green", "blue-green"), ("ultra_violet", "ultra-violet")]`

3. **Numeric enum**
   - Input: `[100, 200, 404]`
   - Expected: `[("_100_", "100"), ("_200_", "200"), ("_404_", "404")]`

4. **Special characters**
   - Input: `["Available Now!", "Pre-Order", "Out of Stock"]`
   - Expected: Correct escaping with underscore

5. **Edge cases**
   - Empty string: `[""]` → `#_empty_` or error?
   - Single char: `["a"]` → `#a`
   - All special: `["!!!"]` → `#___`
   - Unicode: `["café"]` → `#caf_`

6. **Record fields with special characters**
   - Field name: `"content-type"` → `content_type`
   - Field name: `"cache-control"` → `cache_control`
   - Expected: `[("content_type", "content-type"), ("cache_control", "cache-control")]`

7. **Record fields with reserved words and identifiers**
   - Field name: `"try"` → `try_` (keyword)
   - Field name: `"type"` → `type_` (keyword)
   - Field name: `"switch"` → `switch_` (keyword)
   - Field name: `"to_candid"` → `to_candid_` (reserved built-in)
   - Field name: `"from_candid"` → `from_candid_` (reserved built-in)
   - Expected: `[("try_", "try"), ("type_", "type"), ("switch_", "switch"), ("to_candid_", "to_candid"), ("from_candid_", "from_candid")]`

#### 2.2 Integration Tests (OpenAPI Spec)

**Test Spec**: `samples/client/enum-test/specs/enum-test.json`

**Include Diverse Enums**:
```yaml
components:
  schemas:
    SimpleColorEnum:
      type: string
      enum: ["red", "green", "blue"]

    HyphenatedColorEnum:
      type: string
      enum: ["blue-green", "red-orange", "yellow-green"]

    HTTPStatusEnum:
      type: integer
      enum: [200, 404, 500, 503]

    AvailabilityEnum:
      type: string
      enum: ["Available Now!", "Out of Stock", "Pre-Order", "Coming Soon..."]

    MixedCaseEnum:
      type: string
      enum: ["AvailableNow", "OutOfStock", "PreOrder"]

    # Models with escaped field names
    HttpHeader:
      type: object
      properties:
        content-type:
          type: string
        cache-control:
          type: string
        x-request-id:
          type: string

    ReservedWordModel:
      type: object
      properties:
        try:
          type: string
        type:
          type: string
        switch:
          type: integer
        to_candid:
          type: string
        from_candid:
          type: string
        debug_show:
          type: boolean
```

**Test Operations**:
- `POST /test-enum-request` - Send enum in request body
- `GET /test-enum-response` - Receive enum in response
- `GET /test-enum-roundtrip` - Send enum, get same enum back
- `POST /test-http-header` - Send HttpHeader with hyphenated fields
- `GET /test-http-header-response` - Receive HttpHeader with hyphenated fields
- `POST /test-reserved-words` - Send ReservedWordModel with escaped field names
- `GET /test-combined` - Response with both enums and models with escaped fields

#### 2.3 End-to-End Tests (Motoko Canister)

**Test Canister**: `samples/client/enum-test/motoko-test/src/main.mo`

**Test Cases**:

```motoko
// Test A: Simple enum (no special chars)
public func testSimpleEnum() : async Text {
    let response = await api.setColor(#red);
    assert(response.color == #red);
    "✅ Simple enum works"
}

// Test B: Hyphenated enum
public func testHyphenatedEnum() : async Text {
    // Motoko: #blue_green → JSON: "blue-green"
    let response = await api.setColor(#blue_green);
    // JSON: "blue-green" → Motoko: #blue_green
    assert(response.color == #blue_green);
    "✅ Hyphenated enum serialized/deserialized correctly"
}

// Test C: Numeric enum
public func testNumericEnum() : async Text {
    let response = await api.setStatus(#_200_);
    assert(response.status == #_200_);
    "✅ Numeric enum works"
}

// Test D: Special characters enum
public func testSpecialCharsEnum() : async Text {
    let response = await api.setAvailability(#Available_Now_);
    assert(response.availability == #Available_Now_);
    "✅ Special chars enum works"
}

// Test E: Roundtrip verification
public func testEnumRoundtrip() : async Text {
    let allColors = [#red, #blue_green, #ultra_violet];
    for (color in allColors.vals()) {
        let response = await api.echoColor(color);
        assert(response == color);
    };
    "✅ All enums survived roundtrip"
}

// Test F: Hyphenated record fields
public func testHyphenatedFields() : async Text {
    // Motoko: content_type → JSON: "content-type"
    let header = {
        content_type = "application/json";
        cache_control = "no-cache";
        x_request_id = "123";
    };
    let response = await api.sendHttpHeader(header);
    assert(response.content_type == "application/json");
    "✅ Hyphenated fields serialized/deserialized correctly"
}

// Test G: Reserved word and identifier fields
public func testReservedWordFields() : async Text {
    // Motoko: try_ → JSON: "try" (keyword)
    // Motoko: to_candid_ → JSON: "to_candid" (reserved built-in)
    let data = {
        try_ = "test-value";
        type_ = "test-type";
        switch_ = 42;
        to_candid_ = "candid-value";
        from_candid_ = "from-value";
        debug_show_ = true;
    };
    let response = await api.sendReservedWords(data);
    assert(response.try_ == "test-value");
    assert(response.type_ == "test-type");
    assert(response.switch_ == 42);
    assert(response.to_candid_ == "candid-value");
    assert(response.from_candid_ == "from-value");
    assert(response.debug_show_ == true);
    "✅ Reserved word and identifier fields serialized/deserialized correctly"
}

// Test H: Combined - both enums and escaped fields
public func testCombined() : async Text {
    let response = await api.getCombined();
    // Verify enum field
    assert(response.color == #blue_green);
    // Verify escaped field
    assert(response.content_type != "");
    "✅ Combined enums and escaped fields work together"
}
```

**Runtime Validation**:
1. Deploy test canister to local dfx or IC
2. Intercept HTTP requests to verify JSON payloads
3. Confirm JSON matches OpenAPI spec exactly:
   - Enum values: `{"color": "blue-green"}` NOT `{"color": "blue_green"}`
   - Numeric enums: `{"status": 200}` NOT `{"status": "200"}` (if numeric enum)
   - Field names: `{"content-type": "..."}` NOT `{"content_type": "..."}`
   - Reserved words: `{"try": "..."}` NOT `{"try_": "..."}`
   - Reserved identifiers: `{"to_candid": "..."}` NOT `{"to_candid_": "..."}`

---

### Phase 3: Edge Cases & Special Handling

#### 3.1 Numeric Enums

**Challenge**: JSON expects integer `200`, not string `"200"`

**Current Behavior**:
- OpenAPI: `enum: [200, 404, 500]`
- Motoko: `{ #_200_; #_404_; #_500_ }`
- JSON output: `{"status": "_200_"}` ❌

**Desired Behavior**:
- JSON output: `{"status": 200}` ✅

**Potential Solutions**:

**Option A**: Type-aware variant serialization
- Enhance serde to support numeric variant values
- May require changes to Candid encoding
- Complex, but proper solution

**Option B**: Custom JSON serialization
- Don't use serde for numeric enums
- Generate custom JSON builder code
- Simple, but bypasses serde infrastructure

**Option C**: Post-processing
- Serialize normally, then string-replace in JSON
- Replace `"_200_"` → `200` in output string
- Hacky, but works as interim solution

**Recommendation**: Start with Option C as interim, plan Option A for proper fix

#### 3.2 Empty Variant Values

**OpenAPI**: `"status": "active"` (string value)

**Motoko**: `#active` (unit variant, no data)

**Candid Representation**: `#Variant("active", #Null)`

**JSON Serialization**:
- Current: `{"#active": null}` ❌
- Desired: `"active"` ✅

**Solution**: This already works correctly if the enum is used as a field value, not as a standalone variant wrapper. Verify with tests.

#### 3.3 Enum in Different Contexts

**Query Parameters**:
```
GET /items?status=blue-green
```
Currently query params are passed as Text. May need special handling to convert variant to URL-safe string.

**Request/Response Bodies**:
Already covered by renameKeys approach.

**Path Parameters**:
```
GET /items/{status}
```
Similar to query params, need to convert variant to string.

**Solution**: Generate helper functions in enum modules:
```motoko
// In ColorEnum.mo
public func toString(variant: ColorEnum) : Text {
    switch (variant) {
        case (#blue_green) "blue-green";
        case (#red) "red";
        case (#yellow) "yellow";
    }
}

public func fromString(text: Text) : ?ColorEnum {
    switch (text) {
        case ("blue-green") ?#blue_green;
        case ("red") ?#red;
        case ("yellow") ?#yellow;
        case (_) null;
    }
}
```

#### 3.4 Multiple Enums in Single Operation

**Scenario**: Request has `ColorEnum` and `StatusEnum` fields

**Challenge**: Need to merge renameKeys from both enum types

**Solution**: `buildEnumOptions()` helper function (already in plan)

```motoko
let options = {
    Candid.defaultOptions with
    renameKeys = buildEnumOptions([
        EnumMappings.ColorEnumOptions.decode,
        EnumMappings.StatusEnumOptions.decode
    ]);
};
```

**Potential Conflict**: Two enums with same variant name but different meanings
- Example: `StatusEnum#active` vs `SubscriptionEnum#active`
- If OpenAPI values are same, renameKeys will work correctly
- If Motoko names must differ, need qualified naming strategy

---

### Phase 4: Documentation

#### 4.1 Generator Documentation

**File**: `docs/generators/motoko.md` (when upstreamed)

**Content**:
- Explain enum support using variant types
- Show how renameKeys enables proper JSON mapping
- Document special character handling
- Explain numeric enum limitations and workarounds

#### 4.2 Generated Code Comments

**In Enum Type Files**:
```motoko
/// Color options
///
/// OpenAPI values: ["blue-green", "red", "yellow"]
///
/// Note: Variant names are escaped for Motoko syntax.
/// JSON serialization maps back to original OpenAPI values.
public type ColorEnum = {
    #blue_green;  // maps to "blue-green" in JSON
    #red;         // maps to "red" in JSON
    #yellow;      // maps to "yellow" in JSON
};
```

**In EnumMappings.mo**:
```motoko
// This module provides serialization mappings for enum types.
// The 'encode' arrays map Motoko variant names to JSON values.
// The 'decode' arrays map JSON values to Motoko variant names.
// These are used by the serde library's renameKeys option.
```

#### 4.3 User Guide

**Topics**:
1. How to use enums in API calls
2. Pattern matching examples
3. Converting between enums and Text
4. Troubleshooting mapping issues
5. Performance considerations

---

## Open Questions

### Q1: Global vs Per-Operation Options? ✅ RESOLVED

**Decision**: Global mappings for entire API (Option A)

**Rationale**:
- Simpler implementation - single source of truth
- No risk of missing types in complex schemas
- Expected small size (~50-100 mappings typical)
- Negligible performance overhead
- Mappings built once at module init, reused for all operations

**Future**: Per-operation optimization possible if profiling shows need, but unlikely

### Q2: Numeric Enum Candid Representation?

**Current**: Wraps as text variants `#_100_`, `#_200_`

**Alternative Options**:
1. Use `#Nat` or `#Int` Candid types instead of variants
2. Use variant with integer payload: `#Code(200)`
3. Keep current approach but enhance JSON serialization

**Recommendation**: Keep current approach for now, document as known limitation

### Q3: Name Collision Handling? ✅ RESOLVED

**Decision**: Name collisions are not a concern with global approach

**Analysis**:
- **Same JSON name, multiple schemas**: ✅ Works perfectly
  - Example: `HttpRequest.content-type` and `HttpResponse.content-type`
  - Both map to `content_type` - single renameKeys entry handles both
- **Different JSON names in same schema**: ❌ Would be invalid schema design
  - Generator should detect and error
- **Different JSON names across schemas mapping to same Motoko name**: ❌ Extremely rare
  - Generator should detect collision and error with clear message
  - User must fix OpenAPI spec

**Implementation**: Validate no collisions within each schema. Cross-schema collisions from same JSON name are acceptable and expected.

### Q4: Performance Impact?

**Question**: Does renameKeys add significant overhead?

**Expected**: Negligible overhead with global approach
- Mappings built once at module initialization
- Array lookup in renameKeys is O(n) but n is small (~50-100 typical)
- Compared to HTTP outcall latency (hundreds of ms), renameKeys overhead unmeasurable

**Optimizations**:
1. **Skip EnumMappings.mo entirely**: If no mappings needed (all identifiers valid), don't generate module
2. **Empty arrays**: Use `[]` for encode/decode when no mappings needed
3. **Benchmark if needed**: Measure with/without renameKeys on large payloads if performance questions arise

**Recommendation**: Implement, measure if questions arise, optimize only if proven necessary

---

## Success Criteria

- ✅ Simple enums (lowercase, no special chars) work without modification
- ✅ Hyphenated enums (e.g., "blue-green") serialize/deserialize correctly
- ✅ Numeric enums (e.g., HTTP status codes) work bidirectionally (or limitation documented)
- ✅ Enums with spaces/punctuation handled correctly
- ✅ Type safety preserved (pattern matching, exhaustiveness checking)
- ✅ Generated code typechecks with moc
- ✅ End-to-end test passes with real HTTP outcalls
- ✅ JSON payloads match OpenAPI spec exactly
- ✅ Performance is acceptable (no >10% regression)
- ✅ Documentation is complete and accurate

---

## Implementation Timeline

### Week 1: Foundation
- [ ] Implement enum mapping collection in `MotokoClientCodegen.java`
- [ ] Create `enumMappings.mustache` template
- [ ] Generate `EnumMappings.mo` for test cases
- [ ] Write unit tests for mapping logic

### Week 2: Integration
- [ ] Update `api.mustache` with global mapping approach
- [ ] Implement global enum/model collection (no per-operation analysis needed)
- [ ] Create integration test OpenAPI spec
- [ ] Generate and verify test client compiles

### Week 3: Testing
- [ ] Write end-to-end test canister
- [ ] Deploy and run runtime tests
- [ ] Verify JSON payloads match spec
- [ ] Test all edge cases

### Week 4: Polish
- [ ] Handle numeric enum special case
- [ ] Add toString/fromString helpers
- [ ] Write documentation
- [ ] Code review and refinement

---

## Related Files

### Serde Source Code
- `/Users/ggreif/serde/src/JSON/ToText.mo` - JSON encoding
- `/Users/ggreif/serde/src/JSON/FromText.mo` - JSON decoding
- `/Users/ggreif/serde/src/Candid/Types.mo` - Options definition
- `/Users/ggreif/serde/src/Candid/Blob/Encoder.mo:473` - Variant encoding
- `/Users/ggreif/serde/src/Candid/Blob/Decoder.mo:892` - Variant decoding

### Generator Code
- `modules/openapi-generator/src/main/java/org/openapitools/codegen/languages/MotokoClientCodegen.java`
- `modules/openapi-generator/src/main/resources/motoko/api.mustache`
- `modules/openapi-generator/src/main/resources/motoko/model.mustache`

### Test Examples
- `/Users/ggreif/serde/tests/JSON.Test.mo:139` - renameKeys example
- `/Users/ggreif/serde/tests/Candid.Test.mo:220` - renameKeys example
- `samples/client/jsonplaceholder/motoko-test/generated/Models/PostStatus.mo` - Current enum

---

## Key Architectural Decisions

### ✅ Global Mappings (Not Per-Endpoint)

**Decision**: Single `EnumMappings.mo` module with all mappings for entire API

**Rationale**:
- Simplicity: One source of truth, easier to implement and debug
- Performance: Mappings built once at init, negligible overhead (~50-100 entries typical)
- Consistency: All operations guaranteed to use same mappings
- No collision risk: Same JSON names consistently map to same Motoko names

**Trade-off**: Each operation gets all mappings even if it only uses a subset. This is acceptable because the overhead is unmeasurable compared to HTTP outcall latency.

### ✅ Unified Approach for Enums and Record Fields

**Decision**: Same renameKeys mechanism handles both:
- Enum variants: `#blue_green` ↔ `"blue-green"`
- Record fields: `content_type` ↔ `"content-type"`, `try_` ↔ `"try"`

**Benefit**: Consistent escaping strategy, single mapping module, simpler implementation

### ✅ Bidirectional Mappings

**Decision**: Separate `encode` and `decode` arrays in each mapping option

**Rationale**:
- Encoding (Motoko → JSON): `encode = [("blue_green", "blue-green")]`
- Decoding (JSON → Motoko): `decode = [("blue-green", "blue_green")]`
- Clear semantics, prevents mistakes, supports asymmetric mappings if needed

### ✅ Name Collision Strategy

**Decision**: Accept same JSON names mapping to same Motoko names (common case), error on true collisions (rare)

**Validation**: Generator validates no intra-schema Motoko name collisions. Cross-schema collisions from same JSON source are expected and correct.

---

## Priority and Impact

- **Priority**: HIGH - Critical for real-world API compatibility
- **Complexity**: MEDIUM - Generator changes + thorough testing needed
- **Impact**: HIGH - Enables proper enum support for all OpenAPI specs
- **Risk**: LOW - Localized changes, can iterate safely

---

## Next Steps

1. Get approval on implementation approach
2. Set up enum-test sample project structure
3. Begin Phase 1 implementation
4. Iterative testing and refinement
