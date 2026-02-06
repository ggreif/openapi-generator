
// AudioFeaturesObjectType.mo
/// The object type. 
/// Enum values: #audio_features

module {
    // User-facing type: type-safe variants for application code
    public type AudioFeaturesObjectType = {
        #audio_features;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer AudioFeaturesObjectType type
        public type JSON = Text;

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : AudioFeaturesObjectType) : JSON =
            switch (value) {
                case (#audio_features) "audio_features";
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?AudioFeaturesObjectType =
            switch (json) {
                case "audio_features" ?#audio_features;
                case _ null;
            };
    }
}
