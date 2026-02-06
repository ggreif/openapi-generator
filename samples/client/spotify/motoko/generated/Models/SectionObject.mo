
// SectionObject.mo

module {
    // Motoko-facing type: what application code uses
    public type SectionObject = {
        /// The starting point (in seconds) of the section.
        start : ?Float;
        /// The duration (in seconds) of the section.
        duration : ?Float;
        /// The confidence, from 0.0 to 1.0, of the reliability of the section's \"designation\".
        confidence : ?Float;
        /// The overall loudness of the section in decibels (dB). Loudness values are useful for comparing relative loudness of sections within tracks.
        loudness : ?Float;
        /// The overall estimated tempo of the section in beats per minute (BPM). In musical terminology, tempo is the speed or pace of a given piece and derives directly from the average beat duration.
        tempo : ?Float;
        /// The confidence, from 0.0 to 1.0, of the reliability of the tempo. Some tracks contain tempo changes or sounds which don't contain tempo (like pure speech) which would correspond to a low value in this field.
        tempo_confidence : ?Float;
        /// The estimated overall key of the section. The values in this field ranging from 0 to 11 mapping to pitches using standard Pitch Class notation (E.g. 0 = C, 1 = C♯/D♭, 2 = D, and so on). If no key was detected, the value is -1.
        key : ?Int;
        /// The confidence, from 0.0 to 1.0, of the reliability of the key. Songs with many key changes may correspond to low values in this field.
        key_confidence : ?Float;
        /// Indicates the modality (major or minor) of a section, the type of scale from which its melodic content is derived. This field will contain a 0 for \"minor\", a 1 for \"major\", or a -1 for no result. Note that the major key (e.g. C major) could more likely be confused with the minor key at 3 semitones lower (e.g. A minor) as both keys carry the same pitches.
        mode : ?Float;
        /// The confidence, from 0.0 to 1.0, of the reliability of the `mode`.
        mode_confidence : ?Float;
        /// An estimated time signature. The time signature (meter) is a notational convention to specify how many beats are in each bar (or measure). The time signature ranges from 3 to 7 indicating time signatures of \"3/4\", to \"7/4\".
        time_signature : ?Int;
        /// The confidence, from 0.0 to 1.0, of the reliability of the `time_signature`. Sections with time signature changes may correspond to low values in this field.
        time_signature_confidence : ?Float;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer SectionObject type
        public type JSON = {
            start : ?Float;
            duration : ?Float;
            confidence : ?Float;
            loudness : ?Float;
            tempo : ?Float;
            tempo_confidence : ?Float;
            key : ?Int;
            key_confidence : ?Float;
            mode : ?Float;
            mode_confidence : ?Float;
            time_signature : ?Int;
            time_signature_confidence : ?Float;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : SectionObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?SectionObject = ?json;
    }
}
