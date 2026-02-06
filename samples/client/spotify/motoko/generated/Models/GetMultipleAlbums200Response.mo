
import { type AlbumObject; JSON = AlbumObject } "./AlbumObject";

// GetMultipleAlbums200Response.mo

module {
    // User-facing type: what application code uses
    public type GetMultipleAlbums200Response = {
        albums : [AlbumObject];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer GetMultipleAlbums200Response type
        public type JSON = {
            albums : [AlbumObject];
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : GetMultipleAlbums200Response) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?GetMultipleAlbums200Response = ?json;
    }
}
