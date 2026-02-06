import { type Map } "mo:core/pure/Map";

// TransferAUsersPlaybackRequest.mo

module {
    // User-facing type: what application code uses
    public type TransferAUsersPlaybackRequest = {
        /// A JSON array containing the ID of the device on which playback should be started/transferred.<br/>For example:`{device_ids:[\"74ASZWbe4lXaubB36ztrGX\"]}`<br/>_**Note**: Although an array is accepted, only a single device_id is currently supported. Supplying more than one will return `400 Bad Request`_ 
        device_ids : [Text];
        /// **true**: ensure playback happens on new device.<br/>**false** or not provided: keep the current playback state. 
        play : ?Map<Text, Text>;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer TransferAUsersPlaybackRequest type
        public type JSON = {
            device_ids : [Text];
            play : ?Map<Text, Text>;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : TransferAUsersPlaybackRequest) : JSON = value;

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?TransferAUsersPlaybackRequest = ?json;
    }
}
