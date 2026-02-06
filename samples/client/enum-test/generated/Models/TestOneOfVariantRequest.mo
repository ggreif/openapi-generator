
import { type VolumeParameter; JSON = VolumeParameter } "./VolumeParameter";

// TestOneOfVariantRequest.mo

module {
    // Motoko-facing type: what application code uses
    public type TestOneOfVariantRequest = {
        volume : VolumeParameter;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer TestOneOfVariantRequest type
        public type JSON = {
            volume : VolumeParameter;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : TestOneOfVariantRequest) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?TestOneOfVariantRequest = ?json;
    }
}
