
// ArtistDiscographyAlbumObjectAllOfAlbumGroup.mo
/// This field describes the relationship between the artist and the album. 
/// Enum values: #album, #single, #compilation, #appears_on

module {
    // User-facing type: type-safe variants for application code
    public type ArtistDiscographyAlbumObjectAllOfAlbumGroup = {
        #album;
        #single;
        #compilation;
        #appears_on;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ArtistDiscographyAlbumObjectAllOfAlbumGroup type
        public type JSON = Text;

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : ArtistDiscographyAlbumObjectAllOfAlbumGroup) : JSON =
            switch (value) {
                case (#album) "album";
                case (#single) "single";
                case (#compilation) "compilation";
                case (#appears_on) "appears_on";
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?ArtistDiscographyAlbumObjectAllOfAlbumGroup =
            switch (json) {
                case "album" ?#album;
                case "single" ?#single;
                case "compilation" ?#compilation;
                case "appears_on" ?#appears_on;
                case _ null;
            };
    }
}
