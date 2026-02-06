
// EpisodeBaseType.mo
/// The object type. 
/// Enum values: #episode

module {
    // User-facing type: type-safe variants for application code
    public type EpisodeBaseType = {
        #episode;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer EpisodeBaseType type
        public type JSON = Text;

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : EpisodeBaseType) : JSON =
            switch (value) {
                case (#episode) "episode";
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?EpisodeBaseType =
            switch (json) {
                case "episode" ?#episode;
                case _ null;
            };
    }
}
