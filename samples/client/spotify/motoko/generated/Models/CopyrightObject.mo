
// CopyrightObject.mo

module {
    // User-facing type: what application code uses
    public type CopyrightObject = {
        /// The copyright text for this content. 
        text_ : ?Text;
        /// The type of copyright: `C` = the copyright, `P` = the sound recording (performance) copyright. 
        type_ : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer CopyrightObject type
        public type JSON = {
            text_ : ?Text;
            type_ : ?Text;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : CopyrightObject) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?CopyrightObject = ?json;
    }
}
