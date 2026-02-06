
import { type QueueObjectCurrentlyPlaying; JSON = QueueObjectCurrentlyPlaying } "./QueueObjectCurrentlyPlaying";

import { type QueueObjectQueueInner; JSON = QueueObjectQueueInner } "./QueueObjectQueueInner";

// QueueObject.mo

module {
    // Motoko-facing type: what application code uses
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
            currently_playing : ?QueueObjectCurrentlyPlaying;
            queue : ?[QueueObjectQueueInner];
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : QueueObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?QueueObject = ?json;
    }
}
