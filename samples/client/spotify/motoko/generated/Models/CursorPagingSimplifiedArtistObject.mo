
import { type ArtistObject; JSON = ArtistObject } "./ArtistObject";

import { type CursorObject; JSON = CursorObject } "./CursorObject";

// CursorPagingSimplifiedArtistObject.mo

module {
    // User-facing type: what application code uses
    public type CursorPagingSimplifiedArtistObject = {
        /// A link to the Web API endpoint returning the full result of the request.
        href : ?Text;
        /// The maximum number of items in the response (as set in the query or by default).
        limit : ?Int;
        /// URL to the next page of items. ( `null` if none)
        next : ?Text;
        /// The cursors used to find the next set of items.
        cursors : ?CursorObject;
        /// The total number of items available to return.
        total : ?Int;
        items : ?[ArtistObject];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer CursorPagingSimplifiedArtistObject type
        public type JSON = {
            href : ?Text;
            limit : ?Int;
            next : ?Text;
            cursors : ?CursorObject;
            total : ?Int;
            items : ?[ArtistObject];
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : CursorPagingSimplifiedArtistObject) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?CursorPagingSimplifiedArtistObject = ?json;
    }
}
