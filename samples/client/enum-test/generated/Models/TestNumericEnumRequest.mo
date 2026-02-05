
import { type HTTPStatusEnum; JSON = HTTPStatusEnum } "./HTTPStatusEnum";

// TestNumericEnumRequest.mo

module {
    // Motoko-facing type: what application code uses
    public type TestNumericEnumRequest = {
        status : HTTPStatusEnum;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer TestNumericEnumRequest type
        public type JSON = {
            status : HTTPStatusEnum.JSON;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : TestNumericEnumRequest) : JSON {
            {
                status = HTTPStatusEnum.toJSON(value.status);
            }
        };

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?TestNumericEnumRequest {
            let ?status = HTTPStatusEnum.fromJSON(json.status) else return null;
            ?{
                status;
            }
        };
    }
}
