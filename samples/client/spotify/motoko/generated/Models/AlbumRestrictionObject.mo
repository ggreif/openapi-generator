
import { type AlbumRestrictionObjectReason; JSON = AlbumRestrictionObjectReason } "./AlbumRestrictionObjectReason";

// AlbumRestrictionObject.mo

module {
    // User-facing type: what application code uses
    public type AlbumRestrictionObject = {
        reason : ?AlbumRestrictionObjectReason;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer AlbumRestrictionObject type
        public type JSON = {
            reason : ?AlbumRestrictionObjectReason.JSON;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : AlbumRestrictionObject) : JSON = {
            reason = do ? { AlbumRestrictionObjectReason.toJSON(value.reason!) };
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?AlbumRestrictionObject {
            ?{
                reason = do ? { AlbumRestrictionObjectReason.fromJSON(json.reason!)! };
            }
        };
    }
}
