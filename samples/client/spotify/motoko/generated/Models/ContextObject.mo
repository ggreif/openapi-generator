
import { type ExternalUrlObject; JSON = ExternalUrlObject } "./ExternalUrlObject";

// ContextObject.mo

module {
    // Motoko-facing type: what application code uses
    public type ContextObject = {
        /// The object type, e.g. \"artist\", \"playlist\", \"album\", \"show\". 
        type_ : ?Text;
        /// A link to the Web API endpoint providing full details of the track.
        href : ?Text;
        /// External URLs for this context.
        external_urls : ?ExternalUrlObject;
        /// The [Spotify URI](/documentation/web-api/concepts/spotify-uris-ids) for the context. 
        uri : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ContextObject type
        public type JSON = {
            type_ : ?Text;
            href : ?Text;
            external_urls : ?ExternalUrlObject;
            uri : ?Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : ContextObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?ContextObject = ?json;
    }
}
