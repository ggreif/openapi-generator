
import { type AudioFeaturesObject; JSON = AudioFeaturesObject } "./AudioFeaturesObject";

// GetSeveralAudioFeatures200Response.mo

module {
    // Motoko-facing type: what application code uses
    public type GetSeveralAudioFeatures200Response = {
        audio_features : [AudioFeaturesObject];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer GetSeveralAudioFeatures200Response type
        public type JSON = {
            audio_features : [AudioFeaturesObject];
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : GetSeveralAudioFeatures200Response) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?GetSeveralAudioFeatures200Response = ?json;
    }
}
