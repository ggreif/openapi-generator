
import Int "mo:core/Int";

// SetVolumeVolumeParameter.mo

module {
    // User-facing type: discriminated union (oneOf)
    public type SetVolumeVolumeParameter = {
        #one_of_0 : Nat;
        #up;
        #down;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer SetVolumeVolumeParameter type
        public type JSON = {
            #one_of_0 : Int;
            #up;
            #down;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : SetVolumeVolumeParameter) : JSON =
            switch (value) {
                case (#one_of_0(v)) #one_of_0(v);
                case (#up) #up;
                case (#down) #down;
            };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?SetVolumeVolumeParameter =
            switch (json) {
                case (#one_of_0(v)) if (v < 0) null else ?#one_of_0(Int.abs(v));
                case (#up) ?#up;
                case (#down) ?#down;
            };
    }
}
