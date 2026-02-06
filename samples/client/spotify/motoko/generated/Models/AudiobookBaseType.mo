
// AudiobookBaseType.mo
/// The object type. 
/// Enum values: #audiobook

module {
    // User-facing type: type-safe variants for application code
    public type AudiobookBaseType = {
        #audiobook;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer AudiobookBaseType type
        public type JSON = Text;

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : AudiobookBaseType) : JSON =
            switch (value) {
                case (#audiobook) "audiobook";
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?AudiobookBaseType =
            switch (json) {
                case "audiobook" ?#audiobook;
                case _ null;
            };
    }
}
