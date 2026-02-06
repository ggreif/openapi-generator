
import { type SimplifiedShowObject; JSON = SimplifiedShowObject } "./SimplifiedShowObject";

// SavedShowObject.mo

module {
    // Motoko-facing type: what application code uses
    public type SavedShowObject = {
        /// The date and time the show was saved. Timestamps are returned in ISO 8601 format as Coordinated Universal Time (UTC) with a zero offset: YYYY-MM-DDTHH:MM:SSZ. If the time is imprecise (for example, the date/time of an album release), an additional field indicates the precision; see for example, release_date in an album object. 
        added_at : ?Text;
        /// Information about the show.
        show : ?SimplifiedShowObject;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer SavedShowObject type
        public type JSON = {
            added_at : ?Text;
            show : ?SimplifiedShowObject;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : SavedShowObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?SavedShowObject = ?json;
    }
}
