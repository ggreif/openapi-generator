
// PlaylistTracksRefObject.mo

module {
    // User-facing type: what application code uses
    public type PlaylistTracksRefObject = {
        /// A link to the Web API endpoint where full details of the playlist's tracks can be retrieved. 
        href : ?Text;
        /// Number of tracks in the playlist. 
        total : ?Int;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer PlaylistTracksRefObject type
        public type JSON = {
            href : ?Text;
            total : ?Int;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : PlaylistTracksRefObject) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?PlaylistTracksRefObject = ?json;
    }
}
