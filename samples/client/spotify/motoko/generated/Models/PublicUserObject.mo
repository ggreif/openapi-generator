
import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

import { type FollowersObject; JSON = FollowersObject } "./FollowersObject";

import { type ImageObject; JSON = ImageObject } "./ImageObject";

import { type PublicUserObjectType; JSON = PublicUserObjectType } "./PublicUserObjectType";

// PublicUserObject.mo

module {
    // User-facing type: what application code uses
    public type PublicUserObject = {
        /// The name displayed on the user's profile. `null` if not available. 
        display_name : ?Text;
        /// Known public external URLs for this user. 
        external_urls : ?ExternalUrlObject;
        /// Information about the followers of this user. 
        followers : ?FollowersObject;
        /// A link to the Web API endpoint for this user. 
        href : ?Text;
        /// The [Spotify user ID](/documentation/web-api/concepts/spotify-uris-ids) for this user. 
        id : ?Text;
        /// The user's profile image. 
        images : ?[ImageObject];
        type_ : ?PublicUserObjectType;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for this user. 
        uri : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer PublicUserObject type
        public type JSON = {
            display_name : ?Text;
            external_urls : ?ExternalUrlObject;
            followers : ?FollowersObject;
            href : ?Text;
            id : ?Text;
            images : ?[ImageObject];
            type_ : ?PublicUserObjectType.JSON;
            uri : ?Text;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : PublicUserObject) : JSON = { value with
            type_ = do ? { PublicUserObjectType.toJSON(value.type_!) };
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?PublicUserObject {
            ?{ json with
                type_ = do ? { PublicUserObjectType.fromJSON(json.type_!)! };
            }
        };
    }
}
