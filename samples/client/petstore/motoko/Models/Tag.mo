
// Tag.mo
/// A tag for a pet

module {
    // Motoko-facing type: what application code uses
    public type Tag = {
        id : ?Int;
        name : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer Tag type
        public type JSON = {
            id : ?Int;
            name : ?Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : Tag) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?Tag = ?json;
    }
}
