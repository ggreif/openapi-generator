
// FollowPlaylistRequest.mo

module {
    // User-facing type: what application code uses
    public type FollowPlaylistRequest = {
        /// Defaults to `true`. If `true` the playlist will be included in user's public playlists (added to profile), if `false` it will remain private. For more about public/private status, see [Working with Playlists](/documentation/web-api/concepts/playlists) 
        public_ : ?Bool;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer FollowPlaylistRequest type
        public type JSON = {
            public_ : ?Bool;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : FollowPlaylistRequest) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?FollowPlaylistRequest = ?json;
    }
}
