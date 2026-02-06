
// ReorderOrReplacePlaylistsTracks200Response.mo

module {
    // User-facing type: what application code uses
    public type ReorderOrReplacePlaylistsTracks200Response = {
        snapshot_id : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ReorderOrReplacePlaylistsTracks200Response type
        public type JSON = {
            snapshot_id : ?Text;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : ReorderOrReplacePlaylistsTracks200Response) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?ReorderOrReplacePlaylistsTracks200Response = ?json;
    }
}
