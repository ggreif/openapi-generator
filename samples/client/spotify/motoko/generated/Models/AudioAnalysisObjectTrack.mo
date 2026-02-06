
import Int "mo:core/Int";

// AudioAnalysisObjectTrack.mo

module {
    // User-facing type: what application code uses
    public type AudioAnalysisObjectTrack = {
        /// The exact number of audio samples analyzed from this track. See also `analysis_sample_rate`.
        num_samples : ?Int;
        /// Length of the track in seconds.
        duration : ?Float;
        /// This field will always contain the empty string.
        sample_md5 : ?Text;
        /// An offset to the start of the region of the track that was analyzed. (As the entire track is analyzed, this should always be 0.)
        offset_seconds : ?Int;
        /// The length of the region of the track was analyzed, if a subset of the track was analyzed. (As the entire track is analyzed, this should always be 0.)
        window_seconds : ?Int;
        /// The sample rate used to decode and analyze this track. May differ from the actual sample rate of this track available on Spotify.
        analysis_sample_rate : ?Int;
        /// The number of channels used for analysis. If 1, all channels are summed together to mono before analysis.
        analysis_channels : ?Int;
        /// The time, in seconds, at which the track's fade-in period ends. If the track has no fade-in, this will be 0.0.
        end_of_fade_in : ?Float;
        /// The time, in seconds, at which the track's fade-out period starts. If the track has no fade-out, this should match the track's length.
        start_of_fade_out : ?Float;
        /// The overall loudness of a track in decibels (dB). Loudness values are averaged across the entire track and are useful for comparing relative loudness of tracks. Loudness is the quality of a sound that is the primary psychological correlate of physical strength (amplitude). Values typically range between -60 and 0 db. 
        loudness : ?Float;
        /// The overall estimated tempo of a track in beats per minute (BPM). In musical terminology, tempo is the speed or pace of a given piece and derives directly from the average beat duration. 
        tempo : ?Float;
        /// The confidence, from 0.0 to 1.0, of the reliability of the `tempo`.
        tempo_confidence : ?Float;
        /// An estimated time signature. The time signature (meter) is a notational convention to specify how many beats are in each bar (or measure). The time signature ranges from 3 to 7 indicating time signatures of \"3/4\", to \"7/4\".
        time_signature : ?Nat;
        /// The confidence, from 0.0 to 1.0, of the reliability of the `time_signature`.
        time_signature_confidence : ?Float;
        /// The key the track is in. Integers map to pitches using standard [Pitch Class notation](https://en.wikipedia.org/wiki/Pitch_class). E.g. 0 = C, 1 = C♯/D♭, 2 = D, and so on. If no key was detected, the value is -1. 
        key : ?Int;
        /// The confidence, from 0.0 to 1.0, of the reliability of the `key`.
        key_confidence : ?Float;
        /// Mode indicates the modality (major or minor) of a track, the type of scale from which its melodic content is derived. Major is represented by 1 and minor is 0. 
        mode : ?Int;
        /// The confidence, from 0.0 to 1.0, of the reliability of the `mode`.
        mode_confidence : ?Float;
        /// An [Echo Nest Musical Fingerprint (ENMFP)](https://academiccommons.columbia.edu/doi/10.7916/D8Q248M4) codestring for this track.
        codestring : ?Text;
        /// A version number for the Echo Nest Musical Fingerprint format used in the codestring field.
        code_version : ?Float;
        /// An [EchoPrint](https://github.com/spotify/echoprint-codegen) codestring for this track.
        echoprintstring : ?Text;
        /// A version number for the EchoPrint format used in the echoprintstring field.
        echoprint_version : ?Float;
        /// A [Synchstring](https://github.com/echonest/synchdata) for this track.
        synchstring : ?Text;
        /// A version number for the Synchstring used in the synchstring field.
        synch_version : ?Float;
        /// A Rhythmstring for this track. The format of this string is similar to the Synchstring.
        rhythmstring : ?Text;
        /// A version number for the Rhythmstring used in the rhythmstring field.
        rhythm_version : ?Float;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer AudioAnalysisObjectTrack type
        public type JSON = {
            num_samples : ?Int;
            duration : ?Float;
            sample_md5 : ?Text;
            offset_seconds : ?Int;
            window_seconds : ?Int;
            analysis_sample_rate : ?Int;
            analysis_channels : ?Int;
            end_of_fade_in : ?Float;
            start_of_fade_out : ?Float;
            loudness : ?Float;
            tempo : ?Float;
            tempo_confidence : ?Float;
            time_signature : ?Int;
            time_signature_confidence : ?Float;
            key : ?Int;
            key_confidence : ?Float;
            mode : ?Int;
            mode_confidence : ?Float;
            codestring : ?Text;
            code_version : ?Float;
            echoprintstring : ?Text;
            echoprint_version : ?Float;
            synchstring : ?Text;
            synch_version : ?Float;
            rhythmstring : ?Text;
            rhythm_version : ?Float;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : AudioAnalysisObjectTrack) : JSON = {
            num_samples = value.num_samples;
            duration = value.duration;
            sample_md5 = value.sample_md5;
            offset_seconds = value.offset_seconds;
            window_seconds = value.window_seconds;
            analysis_sample_rate = value.analysis_sample_rate;
            analysis_channels = value.analysis_channels;
            end_of_fade_in = value.end_of_fade_in;
            start_of_fade_out = value.start_of_fade_out;
            loudness = value.loudness;
            tempo = value.tempo;
            tempo_confidence = value.tempo_confidence;
            time_signature = value.time_signature;
            time_signature_confidence = value.time_signature_confidence;
            key = value.key;
            key_confidence = value.key_confidence;
            mode = value.mode;
            mode_confidence = value.mode_confidence;
            codestring = value.codestring;
            code_version = value.code_version;
            echoprintstring = value.echoprintstring;
            echoprint_version = value.echoprint_version;
            synchstring = value.synchstring;
            synch_version = value.synch_version;
            rhythmstring = value.rhythmstring;
            rhythm_version = value.rhythm_version;
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?AudioAnalysisObjectTrack {
            ?{
                num_samples = json.num_samples;
                duration = json.duration;
                sample_md5 = json.sample_md5;
                offset_seconds = json.offset_seconds;
                window_seconds = json.window_seconds;
                analysis_sample_rate = json.analysis_sample_rate;
                analysis_channels = json.analysis_channels;
                end_of_fade_in = json.end_of_fade_in;
                start_of_fade_out = json.start_of_fade_out;
                loudness = json.loudness;
                tempo = json.tempo;
                tempo_confidence = json.tempo_confidence;
                time_signature = do ? { let v = json.time_signature!; if (v < 0) return null else Int.abs(v) };
                time_signature_confidence = json.time_signature_confidence;
                key = json.key;
                key_confidence = json.key_confidence;
                mode = json.mode;
                mode_confidence = json.mode_confidence;
                codestring = json.codestring;
                code_version = json.code_version;
                echoprintstring = json.echoprintstring;
                echoprint_version = json.echoprint_version;
                synchstring = json.synchstring;
                synch_version = json.synch_version;
                rhythmstring = json.rhythmstring;
                rhythm_version = json.rhythm_version;
            }
        };
    }
}
