
import { type PagingSimplifiedAlbumObject; JSON = PagingSimplifiedAlbumObject } "./PagingSimplifiedAlbumObject";

// GetNewReleases200Response.mo

module {
    // Motoko-facing type: what application code uses
    public type GetNewReleases200Response = {
        albums : PagingSimplifiedAlbumObject;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer GetNewReleases200Response type
        public type JSON = {
            albums : PagingSimplifiedAlbumObject;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : GetNewReleases200Response) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?GetNewReleases200Response = ?json;
    }
}
