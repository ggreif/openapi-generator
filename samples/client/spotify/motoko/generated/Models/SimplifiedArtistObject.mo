
import { type ArtistObjectType; JSON = ArtistObjectType } "./ArtistObjectType";

import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

// SimplifiedArtistObject.mo

module {
    // User-facing type: what application code uses
    public type SimplifiedArtistObject = {
        /// Known external URLs for this artist. 
        external_urls : ?ExternalUrlObject;
        /// A link to the Web API endpoint providing full details of the artist. 
        href : ?Text;
        /// The [Spotify ID](/documentation/web-api/concepts/spotify-uris-ids) for the artist. 
        id : ?Text;
        /// The name of the artist. 
        name : ?Text;
        type_ : ?ArtistObjectType;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for the artist. 
        uri : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer SimplifiedArtistObject type
        public type JSON = {
            external_urls : ?ExternalUrlObject;
            href : ?Text;
            id : ?Text;
            name : ?Text;
            type_ : ?ArtistObjectType.JSON;
            uri : ?Text;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : SimplifiedArtistObject) : JSON = { value with
            type_ = do ? { ArtistObjectType.toJSON(value.type_!) };
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?SimplifiedArtistObject {
            ?{ json with
                type_ = do ? { ArtistObjectType.fromJSON(json.type_!)! };
            }
        };
    }
}
