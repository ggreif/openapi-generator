
// AlbumBaseType.mo
/// The object type. 
/// Enum values: #album

module {
    // User-facing type: type-safe variants for application code
    public type AlbumBaseType = {
        #album;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer AlbumBaseType type
        public type JSON = Text;

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : AlbumBaseType) : JSON =
            switch (value) {
                case (#album) "album";
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?AlbumBaseType =
            switch (json) {
                case "album" ?#album;
                case _ null;
            };
    }
}
