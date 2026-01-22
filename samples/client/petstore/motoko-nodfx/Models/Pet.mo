
import { type Category } "./Category";

import { type Tag } "./Tag";

// Pet.mo
/// A pet for sale in the pet store

module {
    public type Pet = {
        id : ?Int;
        category : ?Category;
        name : Text;
        photoUrls : [Text];
        tags : ?[Tag];
        /// pet status in the store
        status : ?Text;
    };
}
