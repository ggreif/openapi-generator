
// ResumePointObject.mo

module {
    // User-facing type: what application code uses
    public type ResumePointObject = {
        /// Whether or not the episode has been fully played by the user. 
        fully_played : ?Bool;
        /// The user's most recent position in the episode in milliseconds. 
        resume_position_ms : ?Int;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ResumePointObject type
        public type JSON = {
            fully_played : ?Bool;
            resume_position_ms : ?Int;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : ResumePointObject) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?ResumePointObject = ?json;
    }
}
