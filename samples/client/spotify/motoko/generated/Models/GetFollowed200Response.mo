
import { type CursorPagingSimplifiedArtistObject; JSON = CursorPagingSimplifiedArtistObject } "./CursorPagingSimplifiedArtistObject";

// GetFollowed200Response.mo

module {
    // Motoko-facing type: what application code uses
    public type GetFollowed200Response = {
        artists : CursorPagingSimplifiedArtistObject;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer GetFollowed200Response type
        public type JSON = {
            artists : CursorPagingSimplifiedArtistObject;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : GetFollowed200Response) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?GetFollowed200Response = ?json;
    }
}
