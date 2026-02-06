
import { type SimplifiedShowObject; JSON = SimplifiedShowObject } "./SimplifiedShowObject";

// GetMultipleShows200Response.mo

module {
    // User-facing type: what application code uses
    public type GetMultipleShows200Response = {
        shows : [SimplifiedShowObject];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer GetMultipleShows200Response type
        public type JSON = {
            shows : [SimplifiedShowObject];
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : GetMultipleShows200Response) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?GetMultipleShows200Response = ?json;
    }
}
