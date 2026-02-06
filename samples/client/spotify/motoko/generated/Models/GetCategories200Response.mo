
import { type GetCategories200ResponseCategories; JSON = GetCategories200ResponseCategories } "./GetCategories200ResponseCategories";

// GetCategories200Response.mo

module {
    // User-facing type: what application code uses
    public type GetCategories200Response = {
        categories : GetCategories200ResponseCategories;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer GetCategories200Response type
        public type JSON = {
            categories : GetCategories200ResponseCategories;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : GetCategories200Response) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?GetCategories200Response = ?json;
    }
}
