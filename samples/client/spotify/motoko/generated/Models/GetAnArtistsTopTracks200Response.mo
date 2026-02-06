
import { type TrackObject; JSON = TrackObject } "./TrackObject";

// GetAnArtistsTopTracks200Response.mo

module {
    // Motoko-facing type: what application code uses
    public type GetAnArtistsTopTracks200Response = {
        tracks : [TrackObject];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer GetAnArtistsTopTracks200Response type
        public type JSON = {
            tracks : [TrackObject];
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : GetAnArtistsTopTracks200Response) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?GetAnArtistsTopTracks200Response = ?json;
    }
}
