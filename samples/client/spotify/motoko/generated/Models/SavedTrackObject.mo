
import { type TrackObject; JSON = TrackObject } "./TrackObject";

// SavedTrackObject.mo

module {
    // User-facing type: what application code uses
    public type SavedTrackObject = {
        /// The date and time the track was saved. Timestamps are returned in ISO 8601 format as Coordinated Universal Time (UTC) with a zero offset: YYYY-MM-DDTHH:MM:SSZ. If the time is imprecise (for example, the date/time of an album release), an additional field indicates the precision; see for example, release_date in an album object. 
        added_at : ?Text;
        /// Information about the track.
        track : ?TrackObject;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer SavedTrackObject type
        public type JSON = {
            added_at : ?Text;
            track : ?TrackObject.JSON;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : SavedTrackObject) : JSON = { value with
            track = do ? { TrackObject.toJSON(value.track!) };
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?SavedTrackObject {
            ?{ json with
                track = do ? { TrackObject.fromJSON(json.track!)! };
            }
        };
    }
}
