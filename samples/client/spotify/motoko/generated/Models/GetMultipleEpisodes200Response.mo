
import { type EpisodeObject; JSON = EpisodeObject } "./EpisodeObject";

// GetMultipleEpisodes200Response.mo

module {
    // User-facing type: what application code uses
    public type GetMultipleEpisodes200Response = {
        episodes : [EpisodeObject];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer GetMultipleEpisodes200Response type
        public type JSON = {
            episodes : [EpisodeObject];
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : GetMultipleEpisodes200Response) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?GetMultipleEpisodes200Response = ?json;
    }
}
