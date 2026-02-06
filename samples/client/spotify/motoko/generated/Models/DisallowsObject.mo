
// DisallowsObject.mo

module {
    // User-facing type: what application code uses
    public type DisallowsObject = {
        /// Interrupting playback. Optional field.
        interrupting_playback : ?Bool;
        /// Pausing. Optional field.
        pausing : ?Bool;
        /// Resuming. Optional field.
        resuming : ?Bool;
        /// Seeking playback location. Optional field.
        seeking : ?Bool;
        /// Skipping to the next context. Optional field.
        skipping_next : ?Bool;
        /// Skipping to the previous context. Optional field.
        skipping_prev : ?Bool;
        /// Toggling repeat context flag. Optional field.
        toggling_repeat_context : ?Bool;
        /// Toggling shuffle flag. Optional field.
        toggling_shuffle : ?Bool;
        /// Toggling repeat track flag. Optional field.
        toggling_repeat_track : ?Bool;
        /// Transfering playback between devices. Optional field.
        transferring_playback : ?Bool;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer DisallowsObject type
        public type JSON = {
            interrupting_playback : ?Bool;
            pausing : ?Bool;
            resuming : ?Bool;
            seeking : ?Bool;
            skipping_next : ?Bool;
            skipping_prev : ?Bool;
            toggling_repeat_context : ?Bool;
            toggling_shuffle : ?Bool;
            toggling_repeat_track : ?Bool;
            transferring_playback : ?Bool;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : DisallowsObject) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?DisallowsObject = ?json;
    }
}
