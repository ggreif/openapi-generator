
// AlbumBaseAlbumType.mo
/// The type of the album. 
/// Enum values: #album, #single, #compilation

module {
    // User-facing type: type-safe variants for application code
    public type AlbumBaseAlbumType = {
        #album;
        #single;
        #compilation;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer AlbumBaseAlbumType type
        public type JSON = Text;

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : AlbumBaseAlbumType) : JSON =
            switch (value) {
                case (#album) "album";
                case (#single) "single";
                case (#compilation) "compilation";
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?AlbumBaseAlbumType =
            switch (json) {
                case "album" ?#album;
                case "single" ?#single;
                case "compilation" ?#compilation;
                case _ null;
            };
    }
}
