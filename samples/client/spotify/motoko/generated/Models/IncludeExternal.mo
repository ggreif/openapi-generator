
// IncludeExternal.mo
/// If `include_external=audio` is specified it signals that the client can play externally hosted audio content, and marks the content as playable in the response. By default externally hosted audio content is marked as unplayable in the response. 
/// Enum values: #audio

module {
    // User-facing type: type-safe variants for application code
    public type IncludeExternal = {
        #audio;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer IncludeExternal type
        public type JSON = Text;

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : IncludeExternal) : JSON =
            switch (value) {
                case (#audio) "audio";
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?IncludeExternal =
            switch (json) {
                case "audio" ?#audio;
                case _ null;
            };
    }
}
