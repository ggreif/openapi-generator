
import { type MixedOneOfOneOf; JSON = MixedOneOfOneOf } "./MixedOneOfOneOf";

import { type SimpleColorEnum; JSON = SimpleColorEnum } "./SimpleColorEnum";

import Int "mo:core/Int";

// MixedOneOf.mo
/// Complex oneOf with enum, integer, and object types

module {
    // Motoko-facing type: discriminated union (oneOf)
    public type MixedOneOf = {
        #one_of_0 : Nat;
        #SimpleColorEnum : SimpleColorEnum;
        #MixedOneOfOneOf : MixedOneOfOneOf;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer MixedOneOf type
        public type JSON = {
            #one_of_0 : Int;
            #SimpleColorEnum : SimpleColorEnum;
            #MixedOneOfOneOf : MixedOneOfOneOf;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : MixedOneOf) : JSON =
            switch (value) {
                case (#one_of_0(v)) #one_of_0(v);
                case (#SimpleColorEnum(v)) #SimpleColorEnum(v);
                case (#MixedOneOfOneOf(v)) #MixedOneOfOneOf(v);
            };

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?MixedOneOf =
            switch (json) {
                case (#one_of_0(v)) if (v < 0) null else ?#one_of_0(Int.abs(v));
                case (#SimpleColorEnum(v)) ?#SimpleColorEnum(v);
                case (#MixedOneOfOneOf(v)) ?#MixedOneOfOneOf(v);
            };
    }
}
