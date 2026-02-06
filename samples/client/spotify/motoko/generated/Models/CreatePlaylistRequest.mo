
// CreatePlaylistRequest.mo

module {
    // Motoko-facing type: what application code uses
    public type CreatePlaylistRequest = {
        /// The name for the new playlist, for example `\"Your Coolest Playlist\"`. This name does not need to be unique; a user may have several playlists with the same name. 
        name : Text;
        /// Defaults to `true`. The playlist's public/private status (if it should be added to the user's profile or not): `true` the playlist will be public, `false` the playlist will be private. To be able to create private playlists, the user must have granted the `playlist-modify-private` [scope](/documentation/web-api/concepts/scopes/#list-of-scopes). For more about public/private status, see [Working with Playlists](/documentation/web-api/concepts/playlists) 
        public_ : ?Bool;
        /// Defaults to `false`. If `true` the playlist will be collaborative. _**Note**: to create a collaborative playlist you must also set `public` to `false`. To create collaborative playlists you must have granted `playlist-modify-private` and `playlist-modify-public` [scopes](/documentation/web-api/concepts/scopes/#list-of-scopes)._ 
        collaborative : ?Bool;
        /// value for playlist description as displayed in Spotify Clients and in the Web API. 
        description : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer CreatePlaylistRequest type
        public type JSON = {
            name : Text;
            public_ : ?Bool;
            collaborative : ?Bool;
            description : ?Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : CreatePlaylistRequest) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?CreatePlaylistRequest = ?json;
    }
}
