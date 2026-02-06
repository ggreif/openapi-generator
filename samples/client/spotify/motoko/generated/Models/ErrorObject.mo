
// ErrorObject.mo

module {
    // Motoko-facing type: what application code uses
    public type ErrorObject = {
        /// The HTTP status code (also returned in the response header; see [Response Status Codes](/documentation/web-api/concepts/api-calls#response-status-codes) for more information). 
        status : Int;
        /// A short description of the cause of the error. 
        message : Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ErrorObject type
        public type JSON = {
            status : Int;
            message : Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : ErrorObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?ErrorObject = ?json;
    }
}
