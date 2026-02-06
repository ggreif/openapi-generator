
import { type ErrorObject; JSON = ErrorObject } "./ErrorObject";

// GetAnAlbum401Response.mo

module {
    // Motoko-facing type: what application code uses
    public type GetAnAlbum401Response = {
        error : ErrorObject;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer GetAnAlbum401Response type
        public type JSON = {
            error : ErrorObject;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : GetAnAlbum401Response) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?GetAnAlbum401Response = ?json;
    }
}
