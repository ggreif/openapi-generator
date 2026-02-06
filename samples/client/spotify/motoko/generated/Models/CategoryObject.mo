
import { type ImageObject; JSON = ImageObject } "./ImageObject";

// CategoryObject.mo

module {
    // Motoko-facing type: what application code uses
    public type CategoryObject = {
        /// A link to the Web API endpoint returning full details of the category. 
        href : Text;
        /// The category icon, in various sizes. 
        icons : [ImageObject];
        /// The [Spotify category ID](/documentation/web-api/concepts/spotify-uris-ids) of the category. 
        id : Text;
        /// The name of the category. 
        name : Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer CategoryObject type
        public type JSON = {
            href : Text;
            icons : [ImageObject];
            id : Text;
            name : Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : CategoryObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?CategoryObject = ?json;
    }
}
