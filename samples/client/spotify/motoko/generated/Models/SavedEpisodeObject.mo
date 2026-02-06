
import { type EpisodeObject; JSON = EpisodeObject } "./EpisodeObject";

// SavedEpisodeObject.mo

module {
    // Motoko-facing type: what application code uses
    public type SavedEpisodeObject = {
        /// The date and time the episode was saved. Timestamps are returned in ISO 8601 format as Coordinated Universal Time (UTC) with a zero offset: YYYY-MM-DDTHH:MM:SSZ. 
        added_at : ?Text;
        /// Information about the episode.
        episode : ?EpisodeObject;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer SavedEpisodeObject type
        public type JSON = {
            added_at : ?Text;
            episode : ?EpisodeObject;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : SavedEpisodeObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?SavedEpisodeObject = ?json;
    }
}
