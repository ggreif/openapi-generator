
// AlbumRestrictionObjectReason.mo
/// The reason for the restriction. Albums may be restricted if the content is not available in a given market, to the user's subscription type, or when the user's account is set to not play explicit content. Additional reasons may be added in the future. 
/// Enum values: #market, #product, #explicit

module {
    // User-facing type: type-safe variants for application code
    public type AlbumRestrictionObjectReason = {
        #market;
        #product;
        #explicit;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer AlbumRestrictionObjectReason type
        public type JSON = Text;

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : AlbumRestrictionObjectReason) : JSON =
            switch (value) {
                case (#market) "market";
                case (#product) "product";
                case (#explicit) "explicit";
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?AlbumRestrictionObjectReason =
            switch (json) {
                case "market" ?#market;
                case "product" ?#product;
                case "explicit" ?#explicit;
                case _ null;
            };
    }
}
