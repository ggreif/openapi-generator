
// ExternalUrlObject.mo

module {
    // User-facing type: what application code uses
    public type ExternalUrlObject = {
        /// The [Spotify URL](/documentation/web-api/concepts/spotify-uris-ids) for the object. 
        spotify : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ExternalUrlObject type
        public type JSON = {
            spotify : ?Text;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : ExternalUrlObject) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?ExternalUrlObject = ?json;
    }
}
