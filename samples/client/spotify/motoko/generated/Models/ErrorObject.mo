
import Int "mo:core/Int";

// ErrorObject.mo

module {
    // User-facing type: what application code uses
    public type ErrorObject = {
        /// The HTTP status code (also returned in the response header; see [Response Status Codes](/documentation/web-api/concepts/api-calls#response-status-codes) for more information). 
        status : Nat;
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

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : ErrorObject) : JSON = {
            status = value.status;
            message = value.message;
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?ErrorObject {
            ?{
                status = if (json.status < 0) return null else Int.abs(json.status);
                message = json.message;
            }
        };
    }
}
