
import { type SaveTracksUserRequestTimestampedIdsInner; JSON = SaveTracksUserRequestTimestampedIdsInner } "./SaveTracksUserRequestTimestampedIdsInner";

// SaveTracksUserRequest.mo

module {
    // User-facing type: what application code uses
    public type SaveTracksUserRequest = {
        /// A JSON array of the [Spotify IDs](/documentation/web-api/concepts/spotify-uris-ids). For example: `[\"4iV5W9uYEdYUVa79Axb7Rh\", \"1301WleyT98MSxVHPZCA6M\"]`<br/>A maximum of 50 items can be specified in one request. _**Note**: if the `timestamped_ids` is present in the body, any IDs listed in the query parameters (deprecated) or the `ids` field in the body will be ignored._ 
        ids : ?[Text];
        /// A JSON array of objects containing track IDs with their corresponding timestamps. Each object must include a track ID and an `added_at` timestamp. This allows you to specify when tracks were added to maintain a specific chronological order in the user's library.<br/>A maximum of 50 items can be specified in one request. _**Note**: if the `timestamped_ids` is present in the body, any IDs listed in the query parameters (deprecated) or the `ids` field in the body will be ignored._ 
        timestamped_ids : ?[SaveTracksUserRequestTimestampedIdsInner];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer SaveTracksUserRequest type
        public type JSON = {
            ids : ?[Text];
            timestamped_ids : ?[SaveTracksUserRequestTimestampedIdsInner];
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : SaveTracksUserRequest) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?SaveTracksUserRequest = ?json;
    }
}
