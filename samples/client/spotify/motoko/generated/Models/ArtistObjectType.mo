
// ArtistObjectType.mo
/// The object type. 
/// Enum values: #artist

module {
    // User-facing type: type-safe variants for application code
    public type ArtistObjectType = {
        #artist;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ArtistObjectType type
        public type JSON = Text;

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : ArtistObjectType) : JSON =
            switch (value) {
                case (#artist) "artist";
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?ArtistObjectType =
            switch (json) {
                case "artist" ?#artist;
                case _ null;
            };
    }
}
