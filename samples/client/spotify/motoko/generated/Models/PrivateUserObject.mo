
import { type ExplicitContentSettingsObject; JSON = ExplicitContentSettingsObject } "./ExplicitContentSettingsObject";

import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

import { type FollowersObject; JSON = FollowersObject } "./FollowersObject";

import { type ImageObject; JSON = ImageObject } "./ImageObject";

// PrivateUserObject.mo

module {
    // User-facing type: what application code uses
    public type PrivateUserObject = {
        /// The country of the user, as set in the user's account profile. An [ISO 3166-1 alpha-2 country code](http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2). _This field is only available when the current user has granted access to the [user-read-private](/documentation/web-api/concepts/scopes/#list-of-scopes) scope._ 
        country : ?Text;
        /// The name displayed on the user's profile. `null` if not available. 
        display_name : ?Text;
        /// The user's email address, as entered by the user when creating their account. _**Important!** This email address is unverified; there is no proof that it actually belongs to the user._ _This field is only available when the current user has granted access to the [user-read-email](/documentation/web-api/concepts/scopes/#list-of-scopes) scope._ 
        email : ?Text;
        /// The user's explicit content settings. _This field is only available when the current user has granted access to the [user-read-private](/documentation/web-api/concepts/scopes/#list-of-scopes) scope._ 
        explicit_content : ?ExplicitContentSettingsObject;
        /// Known external URLs for this user.
        external_urls : ?ExternalUrlObject;
        /// Information about the followers of the user.
        followers : ?FollowersObject;
        /// A link to the Web API endpoint for this user. 
        href : ?Text;
        /// The [Spotify user ID](/documentation/web-api/concepts/spotify-uris-ids) for the user. 
        id : ?Text;
        /// The user's profile image.
        images : ?[ImageObject];
        /// The user's Spotify subscription level: \"premium\", \"free\", etc. (The subscription level \"open\" can be considered the same as \"free\".) _This field is only available when the current user has granted access to the [user-read-private](/documentation/web-api/concepts/scopes/#list-of-scopes) scope._ 
        product : ?Text;
        /// The object type: \"user\" 
        type_ : ?Text;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for the user. 
        uri : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer PrivateUserObject type
        public type JSON = {
            country : ?Text;
            display_name : ?Text;
            email : ?Text;
            explicit_content : ?ExplicitContentSettingsObject;
            external_urls : ?ExternalUrlObject;
            followers : ?FollowersObject;
            href : ?Text;
            id : ?Text;
            images : ?[ImageObject];
            product : ?Text;
            type_ : ?Text;
            uri : ?Text;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : PrivateUserObject) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?PrivateUserObject = ?json;
    }
}
