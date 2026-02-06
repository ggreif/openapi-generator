
import { type ContextObject; JSON = ContextObject } "./ContextObject";

import { type TrackObject; JSON = TrackObject } "./TrackObject";

// PlayHistoryObject.mo

module {
    // Motoko-facing type: what application code uses
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
            track : ?TrackObject;
            played_at : ?Text;
            context : ?ContextObject;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : PlayHistoryObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?PlayHistoryObject = ?json;
    }
}
