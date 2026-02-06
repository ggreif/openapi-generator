
// RecommendationSeedObject.mo

module {
    // User-facing type: what application code uses
    public type RecommendationSeedObject = {
        /// The number of tracks available after min\\_\\* and max\\_\\* filters have been applied. 
        afterFilteringSize : ?Int;
        /// The number of tracks available after relinking for regional availability. 
        afterRelinkingSize : ?Int;
        /// A link to the full track or artist data for this seed. For tracks this will be a link to a Track Object. For artists a link to an Artist Object. For genre seeds, this value will be `null`. 
        href : ?Text;
        /// The id used to select this seed. This will be the same as the string used in the `seed_artists`, `seed_tracks` or `seed_genres` parameter. 
        id : ?Text;
        /// The number of recommended tracks available for this seed. 
        initialPoolSize : ?Int;
        /// The entity type of this seed. One of `artist`, `track` or `genre`. 
        type_ : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer RecommendationSeedObject type
        public type JSON = {
            afterFilteringSize : ?Int;
            afterRelinkingSize : ?Int;
            href : ?Text;
            id : ?Text;
            initialPoolSize : ?Int;
            type_ : ?Text;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : RecommendationSeedObject) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?RecommendationSeedObject = ?json;
    }
}
