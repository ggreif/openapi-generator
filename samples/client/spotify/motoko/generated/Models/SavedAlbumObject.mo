
import { type AlbumObject; JSON = AlbumObject } "./AlbumObject";

// SavedAlbumObject.mo

module {
    // User-facing type: what application code uses
    public type SavedAlbumObject = {
        /// The date and time the album was saved Timestamps are returned in ISO 8601 format as Coordinated Universal Time (UTC) with a zero offset: YYYY-MM-DDTHH:MM:SSZ. If the time is imprecise (for example, the date/time of an album release), an additional field indicates the precision; see for example, release_date in an album object. 
        added_at : ?Text;
        /// Information about the album.
        album : ?AlbumObject;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer SavedAlbumObject type
        public type JSON = {
            added_at : ?Text;
            album : ?AlbumObject.JSON;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : SavedAlbumObject) : JSON = { value with
            album = do ? { AlbumObject.toJSON(value.album!) };
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?SavedAlbumObject {
            ?{ json with
                album = do ? { AlbumObject.fromJSON(json.album!)! };
            }
        };
    }
}
