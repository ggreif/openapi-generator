
import { type SimplifiedTrackObject; JSON = SimplifiedTrackObject } "./SimplifiedTrackObject";

// PagingSimplifiedTrackObject.mo

module {
    // Motoko-facing type: what application code uses
    public type PagingSimplifiedTrackObject = {
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
        items : [SimplifiedTrackObject];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer PagingSimplifiedTrackObject type
        public type JSON = {
            href : Text;
            limit : Int;
            next : Text;
            offset : Int;
            previous : Text;
            total : Int;
            items : [SimplifiedTrackObject];
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : PagingSimplifiedTrackObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?PagingSimplifiedTrackObject = ?json;
    }
}
