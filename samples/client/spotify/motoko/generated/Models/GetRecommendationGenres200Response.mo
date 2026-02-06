
// GetRecommendationGenres200Response.mo

module {
    // User-facing type: what application code uses
    public type GetRecommendationGenres200Response = {
        genres : [Text];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer GetRecommendationGenres200Response type
        public type JSON = {
            genres : [Text];
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : GetRecommendationGenres200Response) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?GetRecommendationGenres200Response = ?json;
    }
}
