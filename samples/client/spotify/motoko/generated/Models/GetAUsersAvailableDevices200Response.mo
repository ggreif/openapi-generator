
import { type DeviceObject; JSON = DeviceObject } "./DeviceObject";

// GetAUsersAvailableDevices200Response.mo

module {
    // Motoko-facing type: what application code uses
    public type GetAUsersAvailableDevices200Response = {
        devices : [DeviceObject];
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer GetAUsersAvailableDevices200Response type
        public type JSON = {
            devices : [DeviceObject];
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : GetAUsersAvailableDevices200Response) : JSON = value;

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?GetAUsersAvailableDevices200Response = ?json;
    }
}
