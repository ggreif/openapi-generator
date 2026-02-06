
import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

// PlaylistOwnerObject.mo

module {
    // Motoko-facing type: what application code uses
    public type PlaylistOwnerObject = {
        /// Known public external URLs for this user. 
        external_urls : ?ExternalUrlObject;
        /// A link to the Web API endpoint for this user. 
        href : ?Text;
        /// The [Spotify user ID](/documentation/web-api/concepts/spotify-uris-ids) for this user. 
        id : ?Text;
        /// The object type. 
        type_ : ?Text;
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
            type_ : ?Text;
            uri : ?Text;
            display_name : ?Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : PlaylistOwnerObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?PlaylistOwnerObject = ?json;
    }
}
