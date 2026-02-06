
// ShowBaseType.mo
/// The object type. 
/// Enum values: #show

module {
    // User-facing type: type-safe variants for application code
    public type ShowBaseType = {
        #show;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ShowBaseType type
        public type JSON = Text;

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : ShowBaseType) : JSON =
            switch (value) {
                case (#show) "show";
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?ShowBaseType =
            switch (json) {
                case "show" ?#show;
                case _ null;
            };
    }
}
