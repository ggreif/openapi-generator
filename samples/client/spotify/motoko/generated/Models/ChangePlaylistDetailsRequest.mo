
// ChangePlaylistDetailsRequest.mo

module {
    // Motoko-facing type: what application code uses
    public type ChangePlaylistDetailsRequest = {
        /// The new name for the playlist, for example `\"My New Playlist Title\"` 
        name : ?Text;
        /// The playlist's public/private status (if it should be added to the user's profile or not): `true` the playlist will be public, `false` the playlist will be private, `null` the playlist status is not relevant. For more about public/private status, see [Working with Playlists](/documentation/web-api/concepts/playlists) 
        public_ : ?Bool;
        /// If `true`, the playlist will become collaborative and other users will be able to modify the playlist in their Spotify client. <br/> _**Note**: You can only set `collaborative` to `true` on non-public playlists._ 
        collaborative : ?Bool;
        /// Value for playlist description as displayed in Spotify Clients and in the Web API. 
        description : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ChangePlaylistDetailsRequest type
        public type JSON = {
            name : ?Text;
            public_ : ?Bool;
            collaborative : ?Bool;
            description : ?Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : ChangePlaylistDetailsRequest) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?ChangePlaylistDetailsRequest = ?json;
    }
}
