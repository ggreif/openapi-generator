
// ItemType.mo
/// The ID type: currently only `artist` is supported. 
/// Enum values: #artist

module {
    // User-facing type: type-safe variants for application code
    public type ItemType = {
        #artist;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ItemType type
        public type JSON = Text;

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : ItemType) : JSON =
            switch (value) {
                case (#artist) "artist";
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?ItemType =
            switch (json) {
                case "artist" ?#artist;
                case _ null;
            };
    }
}
