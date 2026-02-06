
// Type_.mo
/// The type of entity to return. Valid values: `artists` or `tracks` 
/// Enum values: #artists, #tracks

module {
    // User-facing type: type-safe variants for application code
    public type Type_ = {
        #artists;
        #tracks;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer Type_ type
        public type JSON = Text;

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : Type_) : JSON =
            switch (value) {
                case (#artists) "artists";
                case (#tracks) "tracks";
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?Type_ =
            switch (json) {
                case "artists" ?#artists;
                case "tracks" ?#tracks;
                case _ null;
            };
    }
}
