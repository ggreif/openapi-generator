
import { type RecommendationSeedObject; JSON = RecommendationSeedObject } "./RecommendationSeedObject";

import { type TrackObject; JSON = TrackObject } "./TrackObject";

// RecommendationsObject.mo

module {
    // User-facing type: what application code uses
    public type RecommendationsObject = {
        /// An array of recommendation seed objects. 
        seeds : [RecommendationSeedObject];
        /// An array of track object (simplified) ordered according to the parameters supplied. 
        tracks : [TrackObject];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer RecommendationsObject type
        public type JSON = {
            seeds : [RecommendationSeedObject];
            tracks : [TrackObject];
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : RecommendationsObject) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?RecommendationsObject = ?json;
    }
}
