
import { type AudiobookObject; JSON = AudiobookObject } "./AudiobookObject";

// GetMultipleAudiobooks200Response.mo

module {
    // User-facing type: what application code uses
    public type GetMultipleAudiobooks200Response = {
        audiobooks : [AudiobookObject];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer GetMultipleAudiobooks200Response type
        public type JSON = {
            audiobooks : [AudiobookObject];
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : GetMultipleAudiobooks200Response) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?GetMultipleAudiobooks200Response = ?json;
    }
}
