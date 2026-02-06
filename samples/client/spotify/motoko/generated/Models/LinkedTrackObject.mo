
import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

// LinkedTrackObject.mo

module {
    // Motoko-facing type: what application code uses
    public type LinkedTrackObject = {
        /// Known external URLs for this track. 
        external_urls : ?ExternalUrlObject;
        /// A link to the Web API endpoint providing full details of the track. 
        href : ?Text;
        /// The [Spotify ID](/documentation/web-api/concepts/spotify-uris-ids) for the track. 
        id : ?Text;
        /// The object type: \"track\". 
        type_ : ?Text;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for the track. 
        uri : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer LinkedTrackObject type
        public type JSON = {
            external_urls : ?ExternalUrlObject;
            href : ?Text;
            id : ?Text;
            type_ : ?Text;
            uri : ?Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : LinkedTrackObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?LinkedTrackObject = ?json;
    }
}
