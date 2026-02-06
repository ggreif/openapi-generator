
// SaveAlbumsUserRequest.mo

module {
    // User-facing type: what application code uses
    public type SaveAlbumsUserRequest = {
        /// A JSON array of the [Spotify IDs](/documentation/web-api/concepts/spotify-uris-ids). For example: `[\"4iV5W9uYEdYUVa79Axb7Rh\", \"1301WleyT98MSxVHPZCA6M\"]`<br/>A maximum of 50 items can be specified in one request. _**Note**: if the `ids` parameter is present in the query string, any IDs listed here in the body will be ignored._ 
        ids : ?[Text];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer SaveAlbumsUserRequest type
        public type JSON = {
            ids : ?[Text];
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : SaveAlbumsUserRequest) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?SaveAlbumsUserRequest = ?json;
    }
}
