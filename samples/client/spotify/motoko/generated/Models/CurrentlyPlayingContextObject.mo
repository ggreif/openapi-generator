
import { type ContextObject; JSON = ContextObject } "./ContextObject";

import { type DeviceObject; JSON = DeviceObject } "./DeviceObject";

import { type DisallowsObject; JSON = DisallowsObject } "./DisallowsObject";

import { type QueueObjectCurrentlyPlaying; JSON = QueueObjectCurrentlyPlaying } "./QueueObjectCurrentlyPlaying";

// CurrentlyPlayingContextObject.mo

module {
    // Motoko-facing type: what application code uses
    public type CurrentlyPlayingContextObject = {
        /// The device that is currently active. 
        device : ?DeviceObject;
        /// off, track, context
        repeat_state : ?Text;
        /// If shuffle is on or off.
        shuffle_state : ?Bool;
        /// A Context Object. Can be `null`.
        context : ?ContextObject;
        /// Unix Millisecond Timestamp when playback state was last changed (play, pause, skip, scrub, new song, etc.).
        timestamp : ?Int;
        /// Progress into the currently playing track or episode. Can be `null`.
        progress_ms : ?Int;
        /// If something is currently playing, return `true`.
        is_playing : ?Bool;
        item : ?QueueObjectCurrentlyPlaying;
        /// The object type of the currently playing item. Can be one of `track`, `episode`, `ad` or `unknown`. 
        currently_playing_type : ?Text;
        /// Allows to update the user interface based on which playback actions are available within the current context. 
        actions : ?DisallowsObject;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer CurrentlyPlayingContextObject type
        public type JSON = {
            device : ?DeviceObject;
            repeat_state : ?Text;
            shuffle_state : ?Bool;
            context : ?ContextObject;
            timestamp : ?Int;
            progress_ms : ?Int;
            is_playing : ?Bool;
            item : ?QueueObjectCurrentlyPlaying;
            currently_playing_type : ?Text;
            actions : ?DisallowsObject;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : CurrentlyPlayingContextObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?CurrentlyPlayingContextObject = ?json;
    }
}
