
// EpisodeBaseReleaseDatePrecision.mo
/// The precision with which `release_date` value is known. 
/// Enum values: #year, #month, #day

module {
    // User-facing type: type-safe variants for application code
    public type EpisodeBaseReleaseDatePrecision = {
        #year;
        #month;
        #day;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer EpisodeBaseReleaseDatePrecision type
        public type JSON = Text;

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : EpisodeBaseReleaseDatePrecision) : JSON =
            switch (value) {
                case (#year) "year";
                case (#month) "month";
                case (#day) "day";
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?EpisodeBaseReleaseDatePrecision =
            switch (json) {
                case "year" ?#year;
                case "month" ?#month;
                case "day" ?#day;
                case _ null;
            };
    }
}
