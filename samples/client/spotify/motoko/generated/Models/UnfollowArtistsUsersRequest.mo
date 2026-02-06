
// UnfollowArtistsUsersRequest.mo

module {
    // User-facing type: what application code uses
    public type UnfollowArtistsUsersRequest = {
        /// A JSON array of the artist or user [Spotify IDs](/documentation/web-api/concepts/spotify-uris-ids). For example: `{ids:[\"74ASZWbe4lXaubB36ztrGX\", \"08td7MxkoHQkXnWAYD8d6Q\"]}`. A maximum of 50 IDs can be sent in one request. _**Note**: if the `ids` parameter is present in the query string, any IDs listed here in the body will be ignored._ 
        ids : ?[Text];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer UnfollowArtistsUsersRequest type
        public type JSON = {
            ids : ?[Text];
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : UnfollowArtistsUsersRequest) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?UnfollowArtistsUsersRequest = ?json;
    }
}
