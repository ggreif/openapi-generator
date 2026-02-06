
// FollowersObject.mo

module {
    // User-facing type: what application code uses
    public type FollowersObject = {
        /// This will always be set to null, as the Web API does not support it at the moment. 
        href : ?Text;
        /// The total number of followers. 
        total : ?Int;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer FollowersObject type
        public type JSON = {
            href : ?Text;
            total : ?Int;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : FollowersObject) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?FollowersObject = ?json;
    }
}
