
// ReservedWordModel.mo
/// Model with reserved word field names

module {
    // Motoko-facing type: what application code uses
    public type ReservedWordModel = {
        try_ : Text;
        type_ : ?Text;
        switch_ : ?Int;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer ReservedWordModel type
        public type JSON = {
            try_ : Text;
            type_ : ?Text;
            switch_ : ?Int;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : ReservedWordModel) : JSON = {
            try_ = value.try_;
            type_ = switch (value.type_) { case (?v) ?v; case null null };
            switch_ = switch (value.switch_) { case (?v) ?v; case null null };
        };

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?ReservedWordModel {
            ?{
                try_ = json.try_;
                type_ = json.type_;
                switch_ = json.switch_;
            }
        };
    }
}
