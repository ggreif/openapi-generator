
import { type RemoveTracksPlaylistRequestTracksInner; JSON = RemoveTracksPlaylistRequestTracksInner } "./RemoveTracksPlaylistRequestTracksInner";

// RemoveTracksPlaylistRequest.mo

module {
    // User-facing type: what application code uses
    public type RemoveTracksPlaylistRequest = {
        /// An array of objects containing [Spotify URIs](/documentation/web-api/concepts/spotify-uris-ids) of the tracks or episodes to remove. For example: `{ \"tracks\": [{ \"uri\": \"spotify:track:4iV5W9uYEdYUVa79Axb7Rh\" },{ \"uri\": \"spotify:track:1301WleyT98MSxVHPZCA6M\" }] }`. A maximum of 100 objects can be sent at once. 
        tracks : [RemoveTracksPlaylistRequestTracksInner];
        /// The playlist's snapshot ID against which you want to make the changes. The API will validate that the specified items exist and in the specified positions and make the changes, even if more recent changes have been made to the playlist. 
        snapshot_id : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer RemoveTracksPlaylistRequest type
        public type JSON = {
            tracks : [RemoveTracksPlaylistRequestTracksInner];
            snapshot_id : ?Text;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : RemoveTracksPlaylistRequest) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?RemoveTracksPlaylistRequest = ?json;
    }
}
