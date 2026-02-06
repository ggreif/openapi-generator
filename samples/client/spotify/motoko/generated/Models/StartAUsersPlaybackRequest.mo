import { type Map } "mo:core/pure/Map";

// StartAUsersPlaybackRequest.mo

module {
    // Motoko-facing type: what application code uses
    public type StartAUsersPlaybackRequest = {
        /// Optional. Spotify URI of the context to play. Valid contexts are albums, artists & playlists. `{context_uri:\"spotify:album:1Je1IMUlBXcx1Fz0WE7oPT\"}` 
        context_uri : ?Map<Text, Text>;
        /// Optional. A JSON array of the Spotify track URIs to play. For example: `{\"uris\": [\"spotify:track:4iV5W9uYEdYUVa79Axb7Rh\", \"spotify:track:1301WleyT98MSxVHPZCA6M\"]}` 
        uris : ?[Text];
        /// Optional. Indicates from where in the context playback should start. Only available when context_uri corresponds to an album or playlist object \"position\" is zero based and can’t be negative. Example: `\"offset\": {\"position\": 5}` \"uri\" is a string representing the uri of the item to start at. Example: `\"offset\": {\"uri\": \"spotify:track:1301WleyT98MSxVHPZCA6M\"}` 
        offset : ?Map<Text, Text>;
        /// integer
        position_ms : ?Map<Text, Text>;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer StartAUsersPlaybackRequest type
        public type JSON = {
            context_uri : ?Map<Text, Text>;
            uris : ?[Text];
            offset : ?Map<Text, Text>;
            position_ms : ?Map<Text, Text>;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : StartAUsersPlaybackRequest) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?StartAUsersPlaybackRequest = ?json;
    }
}
