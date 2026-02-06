
import { type QueueObjectCurrentlyPlaying; JSON = QueueObjectCurrentlyPlaying } "./QueueObjectCurrentlyPlaying";

import { type QueueObjectQueueInner; JSON = QueueObjectQueueInner } "./QueueObjectQueueInner";

// QueueObject.mo

module {
    // User-facing type: what application code uses
    public type QueueObject = {
        currently_playing : ?QueueObjectCurrentlyPlaying;
        /// The tracks or episodes in the queue. Can be empty.
        queue : ?[QueueObjectQueueInner];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer QueueObject type
        public type JSON = {
            currently_playing : ?QueueObjectCurrentlyPlaying.JSON;
            queue : ?[QueueObjectQueueInner];
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : QueueObject) : JSON = { value with
            currently_playing = do ? { QueueObjectCurrentlyPlaying.toJSON(value.currently_playing!) };
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?QueueObject {
            ?{ json with
                currently_playing = do ? { QueueObjectCurrentlyPlaying.fromJSON(json.currently_playing!)! };
            }
        };
    }
}
