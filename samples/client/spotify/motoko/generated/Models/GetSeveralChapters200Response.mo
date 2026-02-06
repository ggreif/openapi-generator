
import { type ChapterObject; JSON = ChapterObject } "./ChapterObject";

// GetSeveralChapters200Response.mo

module {
    // User-facing type: what application code uses
    public type GetSeveralChapters200Response = {
        chapters : [ChapterObject];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer GetSeveralChapters200Response type
        public type JSON = {
            chapters : [ChapterObject];
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : GetSeveralChapters200Response) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?GetSeveralChapters200Response = ?json;
    }
}
