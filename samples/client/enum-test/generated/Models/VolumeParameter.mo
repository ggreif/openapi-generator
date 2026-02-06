
import Int "mo:core/Int";

// VolumeParameter.mo
/// Volume control parameter - discriminated union of integer value or direction

module {
    // Motoko-facing type: discriminated union (oneOf)
    public type VolumeParameter = {
        #one_of_0 : Nat;
        #up;
        #down;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer VolumeParameter type
        public type JSON = {
            #one_of_0 : Int;
            #up;
            #down;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : VolumeParameter) : JSON =
            switch (value) {
                case (#one_of_0(v)) #one_of_0(v);
                case (#up) #up;
                case (#down) #down;
            };

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?VolumeParameter =
            switch (json) {
                case (#one_of_0(v)) if (v < 0) null else ?#one_of_0(Int.abs(v));
                case (#up) ?#up;
                case (#down) ?#down;
            };
    }
}
