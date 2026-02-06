
// AlbumRestrictionObject.mo

module {
    // Motoko-facing type: what application code uses
    public type AlbumRestrictionObject = {
        /// The reason for the restriction. Albums may be restricted if the content is not available in a given market, to the user's subscription type, or when the user's account is set to not play explicit content. Additional reasons may be added in the future. 
        reason : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer AlbumRestrictionObject type
        public type JSON = {
            reason : ?Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : AlbumRestrictionObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?AlbumRestrictionObject = ?json;
    }
}
