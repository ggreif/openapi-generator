
// MixedOneOfOneOf.mo

module {
    // Motoko-facing type: what application code uses
    public type MixedOneOfOneOf = {
        custom : Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer MixedOneOfOneOf type
        public type JSON = {
            custom : Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : MixedOneOfOneOf) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?MixedOneOfOneOf = ?json;
    }
}
