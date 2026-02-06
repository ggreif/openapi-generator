
// RemoveTracksPlaylistRequestTracksInner.mo

module {
    // Motoko-facing type: what application code uses
    public type RemoveTracksPlaylistRequestTracksInner = {
        /// Spotify URI
        uri : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer RemoveTracksPlaylistRequestTracksInner type
        public type JSON = {
            uri : ?Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : RemoveTracksPlaylistRequestTracksInner) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?RemoveTracksPlaylistRequestTracksInner = ?json;
    }
}
