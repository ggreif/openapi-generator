
import { type PagingPlaylistObject; JSON = PagingPlaylistObject } "./PagingPlaylistObject";

// PagingFeaturedPlaylistObject.mo

module {
    // User-facing type: what application code uses
    public type PagingFeaturedPlaylistObject = {
        /// The localized message of a playlist. 
        message : ?Text;
        playlists : ?PagingPlaylistObject;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer PagingFeaturedPlaylistObject type
        public type JSON = {
            message : ?Text;
            playlists : ?PagingPlaylistObject;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : PagingFeaturedPlaylistObject) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?PagingFeaturedPlaylistObject = ?json;
    }
}
