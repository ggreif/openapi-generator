
// ExplicitContentSettingsObject.mo

module {
    // Motoko-facing type: what application code uses
    public type ExplicitContentSettingsObject = {
        /// When `true`, indicates that explicit content should not be played. 
        filter_enabled : ?Bool;
        /// When `true`, indicates that the explicit content setting is locked and can't be changed by the user. 
        filter_locked : ?Bool;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ExplicitContentSettingsObject type
        public type JSON = {
            filter_enabled : ?Bool;
            filter_locked : ?Bool;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : ExplicitContentSettingsObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?ExplicitContentSettingsObject = ?json;
    }
}
