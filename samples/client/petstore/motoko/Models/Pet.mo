
import { type Category; JSON = Category } "./Category";

import { type Tag; JSON = Tag } "./Tag";

// Pet.mo
/// A pet for sale in the pet store

module {
    // Motoko-facing type: what application code uses
    public type Pet = {
        id : ?Int;
        category : ?Category;
        name : Text;
        photoUrls : [Text];
        tags : ?[Tag];
        /// pet status in the store
        status : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer Pet type
        public type JSON = {
            id : ?Int;
            category : ?Category;
            name : Text;
            photoUrls : [Text];
            tags : ?[Tag];
            status : ?Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : Pet) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?Pet = ?json;
    }
}
