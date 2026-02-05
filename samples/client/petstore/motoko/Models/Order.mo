
// Order.mo
/// An order for a pets from the pet store

module {
    // Motoko-facing type: what application code uses
    public type Order = {
        id : ?Int;
        petId : ?Int;
        quantity : ?Int;
        shipDate : ?Text;
        /// Order Status
        status : ?Text;
        complete : ?Bool;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer Order type
        public type JSON = {
            id : ?Int;
            petId : ?Int;
            quantity : ?Int;
            shipDate : ?Text;
            status : ?Text;
            complete : ?Bool;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : Order) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?Order = ?json;
    }
}
