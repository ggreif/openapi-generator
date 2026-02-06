
// ItemTypeInner.mo
/// Enum values: #album, #artist, #playlist, #track, #show, #episode, #audiobook

module {
    // User-facing type: type-safe variants for application code
    public type ItemTypeInner = {
        #album;
        #artist;
        #playlist;
        #track;
        #show;
        #episode;
        #audiobook;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ItemTypeInner type
        public type JSON = Text;

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : ItemTypeInner) : JSON =
            switch (value) {
                case (#album) "album";
                case (#artist) "artist";
                case (#playlist) "playlist";
                case (#track) "track";
                case (#show) "show";
                case (#episode) "episode";
                case (#audiobook) "audiobook";
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?ItemTypeInner =
            switch (json) {
                case "album" ?#album;
                case "artist" ?#artist;
                case "playlist" ?#playlist;
                case "track" ?#track;
                case "show" ?#show;
                case "episode" ?#episode;
                case "audiobook" ?#audiobook;
                case _ null;
            };
    }
}
