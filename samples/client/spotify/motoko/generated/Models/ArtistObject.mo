
import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

import { type FollowersObject; JSON = FollowersObject } "./FollowersObject";

import { type ImageObject; JSON = ImageObject } "./ImageObject";

// ArtistObject.mo

module {
    // Motoko-facing type: what application code uses
    public type ArtistObject = {
        /// Known external URLs for this artist. 
        external_urls : ?ExternalUrlObject;
        /// Information about the followers of the artist. 
        followers : ?FollowersObject;
        /// A list of the genres the artist is associated with. If not yet classified, the array is empty. 
        genres : ?[Text];
        /// A link to the Web API endpoint providing full details of the artist. 
        href : ?Text;
        /// The [Spotify ID](/documentation/web-api/concepts/spotify-uris-ids) for the artist. 
        id : ?Text;
        /// Images of the artist in various sizes, widest first. 
        images : ?[ImageObject];
        /// The name of the artist. 
        name : ?Text;
        /// The popularity of the artist. The value will be between 0 and 100, with 100 being the most popular. The artist's popularity is calculated from the popularity of all the artist's tracks. 
        popularity : ?Int;
        /// The object type. 
        type_ : ?Text;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for the artist. 
        uri : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ArtistObject type
        public type JSON = {
            external_urls : ?ExternalUrlObject;
            followers : ?FollowersObject;
            genres : ?[Text];
            href : ?Text;
            id : ?Text;
            images : ?[ImageObject];
            name : ?Text;
            popularity : ?Int;
            type_ : ?Text;
            uri : ?Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : ArtistObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?ArtistObject = ?json;
    }
}
