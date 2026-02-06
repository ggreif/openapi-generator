
// ItemType2.mo
/// The ID type: either `artist` or `user`. 
/// Enum values: #artist, #user

module {
    // User-facing type: type-safe variants for application code
    public type ItemType2 = {
        #artist;
        #user;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ItemType2 type
        public type JSON = Text;

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : ItemType2) : JSON =
            switch (value) {
                case (#artist) "artist";
                case (#user) "user";
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?ItemType2 =
            switch (json) {
                case "artist" ?#artist;
                case "user" ?#user;
                case _ null;
            };
    }
}
