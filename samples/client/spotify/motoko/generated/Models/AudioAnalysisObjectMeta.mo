
// AudioAnalysisObjectMeta.mo

module {
    // User-facing type: what application code uses
    public type AudioAnalysisObjectMeta = {
        /// The version of the Analyzer used to analyze this track.
        analyzer_version : ?Text;
        /// The platform used to read the track's audio data.
        platform : ?Text;
        /// A detailed status code for this track. If analysis data is missing, this code may explain why.
        detailed_status : ?Text;
        /// The return code of the analyzer process. 0 if successful, 1 if any errors occurred.
        status_code : ?Int;
        /// The Unix timestamp (in seconds) at which this track was analyzed.
        timestamp : ?Int;
        /// The amount of time taken to analyze this track.
        analysis_time : ?Float;
        /// The method used to read the track's audio data.
        input_process : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer AudioAnalysisObjectMeta type
        public type JSON = {
            analyzer_version : ?Text;
            platform : ?Text;
            detailed_status : ?Text;
            status_code : ?Int;
            timestamp : ?Int;
            analysis_time : ?Float;
            input_process : ?Text;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : AudioAnalysisObjectMeta) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?AudioAnalysisObjectMeta = ?json;
    }
}
