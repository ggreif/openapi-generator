
// TimeIntervalObject.mo

module {
    // Motoko-facing type: what application code uses
    public type TimeIntervalObject = {
        /// The starting point (in seconds) of the time interval.
        start : ?Float;
        /// The duration (in seconds) of the time interval.
        duration : ?Float;
        /// The confidence, from 0.0 to 1.0, of the reliability of the interval.
        confidence : ?Float;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer TimeIntervalObject type
        public type JSON = {
            start : ?Float;
            duration : ?Float;
            confidence : ?Float;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : TimeIntervalObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?TimeIntervalObject = ?json;
    }
}
