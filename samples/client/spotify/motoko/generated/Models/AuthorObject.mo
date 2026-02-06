
// AuthorObject.mo

module {
    // Motoko-facing type: what application code uses
    public type AuthorObject = {
        /// The name of the author. 
        name : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer AuthorObject type
        public type JSON = {
            name : ?Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : AuthorObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?AuthorObject = ?json;
    }
}
