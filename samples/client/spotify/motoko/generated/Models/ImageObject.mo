
// ImageObject.mo

module {
    // User-facing type: what application code uses
    public type ImageObject = {
        /// The source URL of the image. 
        url : Text;
        /// The image height in pixels. 
        height : Int;
        /// The image width in pixels. 
        width : Int;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ImageObject type
        public type JSON = {
            url : Text;
            height : Int;
            width : Int;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : ImageObject) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?ImageObject = ?json;
    }
}
