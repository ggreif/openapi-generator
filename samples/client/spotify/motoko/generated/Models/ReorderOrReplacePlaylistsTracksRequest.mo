
// ReorderOrReplacePlaylistsTracksRequest.mo

module {
    // User-facing type: what application code uses
    public type ReorderOrReplacePlaylistsTracksRequest = {
        uris : ?[Text];
        /// The position of the first item to be reordered. 
        range_start : ?Int;
        /// The position where the items should be inserted.<br/>To reorder the items to the end of the playlist, simply set _insert_before_ to the position after the last item.<br/>Examples:<br/>To reorder the first item to the last position in a playlist with 10 items, set _range_start_ to 0, and _insert_before_ to 10.<br/>To reorder the last item in a playlist with 10 items to the start of the playlist, set _range_start_ to 9, and _insert_before_ to 0. 
        insert_before : ?Int;
        /// The amount of items to be reordered. Defaults to 1 if not set.<br/>The range of items to be reordered begins from the _range_start_ position, and includes the _range_length_ subsequent items.<br/>Example:<br/>To move the items at index 9-10 to the start of the playlist, _range_start_ is set to 9, and _range_length_ is set to 2. 
        range_length : ?Int;
        /// The playlist's snapshot ID against which you want to make the changes. 
        snapshot_id : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ReorderOrReplacePlaylistsTracksRequest type
        public type JSON = {
            uris : ?[Text];
            range_start : ?Int;
            insert_before : ?Int;
            range_length : ?Int;
            snapshot_id : ?Text;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : ReorderOrReplacePlaylistsTracksRequest) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?ReorderOrReplacePlaylistsTracksRequest = ?json;
    }
}
