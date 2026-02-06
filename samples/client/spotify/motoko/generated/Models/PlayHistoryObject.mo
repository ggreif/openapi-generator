
import { type ContextObject; JSON = ContextObject } "./ContextObject";

import { type TrackObject; JSON = TrackObject } "./TrackObject";

// PlayHistoryObject.mo

module {
    // User-facing type: what application code uses
    public type PlayHistoryObject = {
        /// The track the user listened to.
        track : ?TrackObject;
        /// The date and time the track was played.
        played_at : ?Text;
        /// The context the track was played from.
        context : ?ContextObject;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer PlayHistoryObject type
        public type JSON = {
            track : ?TrackObject.JSON;
            played_at : ?Text;
            context : ?ContextObject;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : PlayHistoryObject) : JSON = { value with
            track = do ? { TrackObject.toJSON(value.track!) };
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?PlayHistoryObject {
            ?{ json with
                track = do ? { TrackObject.fromJSON(json.track!)! };
            }
        };
    }
}
