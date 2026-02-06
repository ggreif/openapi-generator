
import { type PlaylistTrackObjectTrack; JSON = PlaylistTrackObjectTrack } "./PlaylistTrackObjectTrack";

import { type PlaylistUserObject; JSON = PlaylistUserObject } "./PlaylistUserObject";

// PlaylistTrackObject.mo

module {
    // User-facing type: what application code uses
    public type PlaylistTrackObject = {
        /// The date and time the track or episode was added. _**Note**: some very old playlists may return `null` in this field._ 
        added_at : ?Text;
        /// The Spotify user who added the track or episode. _**Note**: some very old playlists may return `null` in this field._ 
        added_by : ?PlaylistUserObject;
        /// Whether this track or episode is a [local file](/documentation/web-api/concepts/playlists/#local-files) or not. 
        is_local : ?Bool;
        track : ?PlaylistTrackObjectTrack;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer PlaylistTrackObject type
        public type JSON = {
            added_at : ?Text;
            added_by : ?PlaylistUserObject.JSON;
            is_local : ?Bool;
            track : ?PlaylistTrackObjectTrack.JSON;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : PlaylistTrackObject) : JSON = { value with
            added_by = do ? { PlaylistUserObject.toJSON(value.added_by!) };
            track = do ? { PlaylistTrackObjectTrack.toJSON(value.track!) };
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?PlaylistTrackObject {
            ?{ json with
                added_by = do ? { PlaylistUserObject.fromJSON(json.added_by!)! };
                track = do ? { PlaylistTrackObjectTrack.fromJSON(json.track!)! };
            }
        };
    }
}
