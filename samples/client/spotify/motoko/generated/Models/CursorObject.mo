
// CursorObject.mo

module {
    // Motoko-facing type: what application code uses
    public type CursorObject = {
        /// The cursor to use as key to find the next page of items.
        after : ?Text;
        /// The cursor to use as key to find the previous page of items.
        before : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer CursorObject type
        public type JSON = {
            after : ?Text;
            before : ?Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : CursorObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?CursorObject = ?json;
    }
}
