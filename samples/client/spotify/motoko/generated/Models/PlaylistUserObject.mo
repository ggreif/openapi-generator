
import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

import { type PublicUserObjectType; JSON = PublicUserObjectType } "./PublicUserObjectType";

// PlaylistUserObject.mo

module {
    // User-facing type: what application code uses
    public type PlaylistUserObject = {
        /// Known public external URLs for this user. 
        external_urls : ?ExternalUrlObject;
        /// A link to the Web API endpoint for this user. 
        href : ?Text;
        /// The [Spotify user ID](/documentation/web-api/concepts/spotify-uris-ids) for this user. 
        id : ?Text;
        type_ : ?PublicUserObjectType;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for this user. 
        uri : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer PlaylistUserObject type
        public type JSON = {
            external_urls : ?ExternalUrlObject;
            href : ?Text;
            id : ?Text;
            type_ : ?PublicUserObjectType.JSON;
            uri : ?Text;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : PlaylistUserObject) : JSON = { value with
            type_ = do ? { PublicUserObjectType.toJSON(value.type_!) };
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?PlaylistUserObject {
            ?{ json with
                type_ = do ? { PublicUserObjectType.fromJSON(json.type_!)! };
            }
        };
    }
}
