
// SaveTracksUserRequestTimestampedIdsInner.mo

module {
    // Motoko-facing type: what application code uses
    public type SaveTracksUserRequestTimestampedIdsInner = {
        /// The [Spotify ID](/documentation/web-api/concepts/spotify-uris-ids) for the track. 
        id : Text;
        /// The timestamp when the track was added to the library. Use ISO 8601 format with UTC timezone (e.g., `2023-01-15T14:30:00Z`). You can specify past timestamps to insert tracks at specific positions in the library's chronological order. The API uses minute-level granularity for ordering, though the timestamp supports millisecond precision. 
        added_at : Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer SaveTracksUserRequestTimestampedIdsInner type
        public type JSON = {
            id : Text;
            added_at : Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : SaveTracksUserRequestTimestampedIdsInner) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?SaveTracksUserRequestTimestampedIdsInner = ?json;
    }
}
