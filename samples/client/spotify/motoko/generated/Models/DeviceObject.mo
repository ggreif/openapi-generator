
import Int "mo:core/Int";

// DeviceObject.mo

module {
    // User-facing type: what application code uses
    public type DeviceObject = {
        /// The device ID. This ID is unique and persistent to some extent. However, this is not guaranteed and any cached `device_id` should periodically be cleared out and refetched as necessary.
        id : ?Text;
        /// If this device is the currently active device.
        is_active : ?Bool;
        /// If this device is currently in a private session.
        is_private_session : ?Bool;
        /// Whether controlling this device is restricted. At present if this is \"true\" then no Web API commands will be accepted by this device.
        is_restricted : ?Bool;
        /// A human-readable name for the device. Some devices have a name that the user can configure (e.g. \\\"Loudest speaker\\\") and some devices have a generic name associated with the manufacturer or device model.
        name : ?Text;
        /// Device type, such as \"computer\", \"smartphone\" or \"speaker\".
        type_ : ?Text;
        /// The current volume in percent.
        volume_percent : ?Nat;
        /// If this device can be used to set the volume.
        supports_volume : ?Bool;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer DeviceObject type
        public type JSON = {
            id : ?Text;
            is_active : ?Bool;
            is_private_session : ?Bool;
            is_restricted : ?Bool;
            name : ?Text;
            type_ : ?Text;
            volume_percent : ?Int;
            supports_volume : ?Bool;
        };

        // Convert User-facing type to JSON-facing Motoko type
        public func toJSON(value : DeviceObject) : JSON = {
            id = value.id;
            is_active = value.is_active;
            is_private_session = value.is_private_session;
            is_restricted = value.is_restricted;
            name = value.name;
            type_ = value.type_;
            volume_percent = value.volume_percent;
            supports_volume = value.supports_volume;
        };

        // Convert JSON-facing Motoko type to User-facing type
        public func fromJSON(json : JSON) : ?DeviceObject {
            ?{
                id = json.id;
                is_active = json.is_active;
                is_private_session = json.is_private_session;
                is_restricted = json.is_restricted;
                name = json.name;
                type_ = json.type_;
                volume_percent = do ? { let v = json.volume_percent!; if (v < 0) return null else Int.abs(v) };
                supports_volume = json.supports_volume;
            }
        };
    }
}
