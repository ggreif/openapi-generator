
import { type AudioAnalysisObjectMeta; JSON = AudioAnalysisObjectMeta } "./AudioAnalysisObjectMeta";

import { type AudioAnalysisObjectTrack; JSON = AudioAnalysisObjectTrack } "./AudioAnalysisObjectTrack";

import { type SectionObject; JSON = SectionObject } "./SectionObject";

import { type SegmentObject; JSON = SegmentObject } "./SegmentObject";

import { type TimeIntervalObject; JSON = TimeIntervalObject } "./TimeIntervalObject";

// AudioAnalysisObject.mo

module {
    // Motoko-facing type: what application code uses
    public type AudioAnalysisObject = {
        meta : ?AudioAnalysisObjectMeta;
        track : ?AudioAnalysisObjectTrack;
        /// The time intervals of the bars throughout the track. A bar (or measure) is a segment of time defined as a given number of beats.
        bars : ?[TimeIntervalObject];
        /// The time intervals of beats throughout the track. A beat is the basic time unit of a piece of music; for example, each tick of a metronome. Beats are typically multiples of tatums.
        beats : ?[TimeIntervalObject];
        /// Sections are defined by large variations in rhythm or timbre, e.g. chorus, verse, bridge, guitar solo, etc. Each section contains its own descriptions of tempo, key, mode, time_signature, and loudness.
        sections : ?[SectionObject];
        /// Each segment contains a roughly conisistent sound throughout its duration.
        segments : ?[SegmentObject];
        /// A tatum represents the lowest regular pulse train that a listener intuitively infers from the timing of perceived musical events (segments).
        tatums : ?[TimeIntervalObject];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer AudioAnalysisObject type
        public type JSON = {
            meta : ?AudioAnalysisObjectMeta;
            track : ?AudioAnalysisObjectTrack;
            bars : ?[TimeIntervalObject];
            beats : ?[TimeIntervalObject];
            sections : ?[SectionObject];
            segments : ?[SegmentObject];
            tatums : ?[TimeIntervalObject];
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : AudioAnalysisObject) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?AudioAnalysisObject = ?json;
    }
}
