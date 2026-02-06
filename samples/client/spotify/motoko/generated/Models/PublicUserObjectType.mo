
// PublicUserObjectType.mo
/// The object type. 
/// Enum values: #user

module {
    // User-facing type: type-safe variants for application code
    public type PublicUserObjectType = {
        #user;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer PublicUserObjectType type
        public type JSON = Text;

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : PublicUserObjectType) : JSON =
            switch (value) {
                case (#user) "user";
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?PublicUserObjectType =
            switch (json) {
                case "user" ?#user;
                case _ null;
            };
    }
}
