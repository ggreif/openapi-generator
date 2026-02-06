
// ExternalIdObject.mo

module {
    // User-facing type: what application code uses
    public type ExternalIdObject = {
        /// [International Standard Recording Code](http://en.wikipedia.org/wiki/International_Standard_Recording_Code) 
        isrc : ?Text;
        /// [International Article Number](http://en.wikipedia.org/wiki/International_Article_Number_%28EAN%29) 
        ean : ?Text;
        /// [Universal Product Code](http://en.wikipedia.org/wiki/Universal_Product_Code) 
        upc : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ExternalIdObject type
        public type JSON = {
            isrc : ?Text;
            ean : ?Text;
            upc : ?Text;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : ExternalIdObject) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?ExternalIdObject = ?json;
    }
}
