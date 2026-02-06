
import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

import { type PublicUserObjectType; JSON = PublicUserObjectType } "./PublicUserObjectType";

// PlaylistOwnerObject.mo

module {
    // User-facing type: what application code uses
    public type PlaylistOwnerObject = {
        /// Known public external URLs for this user. 
        external_urls : ?ExternalUrlObject;
        /// A link to the Web API endpoint for this user. 
        href : ?Text;
        /// The [Spotify user ID](/documentation/web-api/concepts/spotify-uris-ids) for this user. 
        id : ?Text;
        type_ : ?PublicUserObjectType;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for this user. 
        uri : ?Text;
        /// The name displayed on the user's profile. `null` if not available. 
        display_name : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer PlaylistOwnerObject type
        public type JSON = {
            external_urls : ?ExternalUrlObject;
            href : ?Text;
            id : ?Text;
            type_ : ?PublicUserObjectType.JSON;
            uri : ?Text;
            display_name : ?Text;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : PlaylistOwnerObject) : JSON = { value with
            type_ = do ? { PublicUserObjectType.toJSON(value.type_!) };
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?PlaylistOwnerObject {
            ?{ json with
                type_ = do ? { PublicUserObjectType.fromJSON(json.type_!)! };
            }
        };
    }
}
