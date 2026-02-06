
// GetAvailableMarkets200Response.mo

module {
    // User-facing type: what application code uses
    public type GetAvailableMarkets200Response = {
        markets : ?[Text];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer GetAvailableMarkets200Response type
        public type JSON = {
            markets : ?[Text];
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : GetAvailableMarkets200Response) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?GetAvailableMarkets200Response = ?json;
    }
}
