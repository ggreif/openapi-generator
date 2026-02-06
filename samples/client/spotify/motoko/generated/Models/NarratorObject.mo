
// NarratorObject.mo

module {
    // Motoko-facing type: what application code uses
    public type NarratorObject = {
        /// The name of the Narrator. 
        name : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer NarratorObject type
        public type JSON = {
            name : ?Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : NarratorObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?NarratorObject = ?json;
    }
}
