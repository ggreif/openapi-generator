
import { type SavedShowObject; JSON = SavedShowObject } "./SavedShowObject";

// PagingSavedShowObject.mo

module {
    // User-facing type: what application code uses
    public type PagingSavedShowObject = {
        /// A link to the Web API endpoint returning the full result of the request 
        href : Text;
        /// The maximum number of items in the response (as set in the query or by default). 
        limit : Int;
        /// URL to the next page of items. ( `null` if none) 
        next : Text;
        /// The offset of the items returned (as set in the query or by default) 
        offset : Int;
        /// URL to the previous page of items. ( `null` if none) 
        previous : Text;
        /// The total number of items available to return. 
        total : Int;
        items : [SavedShowObject];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer PagingSavedShowObject type
        public type JSON = {
            href : Text;
            limit : Int;
            next : Text;
            offset : Int;
            previous : Text;
            total : Int;
            items : [SavedShowObject];
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : PagingSavedShowObject) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?PagingSavedShowObject = ?json;
    }
}
