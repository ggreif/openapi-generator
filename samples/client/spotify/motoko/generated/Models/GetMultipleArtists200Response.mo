
import { type ArtistObject; JSON = ArtistObject } "./ArtistObject";

// GetMultipleArtists200Response.mo

module {
    // User-facing type: what application code uses
    public type GetMultipleArtists200Response = {
        artists : [ArtistObject];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer GetMultipleArtists200Response type
        public type JSON = {
            artists : [ArtistObject];
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : GetMultipleArtists200Response) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?GetMultipleArtists200Response = ?json;
    }
}
