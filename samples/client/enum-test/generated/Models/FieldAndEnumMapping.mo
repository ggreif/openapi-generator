
import { type AvailabilityEnum; JSON = AvailabilityEnum } "./AvailabilityEnum";

import { type HTTPStatusEnum; JSON = HTTPStatusEnum } "./HTTPStatusEnum";

// FieldAndEnumMapping.mo
/// Test model with BOTH field name mapping AND enum value mapping

module {
    // Motoko-facing type: what application code uses
    public type FieldAndEnumMapping = {
        statusMinuscode : HTTPStatusEnum;
        availabilityMinusstatus : ?AvailabilityEnum;
        contentMinustype : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer FieldAndEnumMapping type
        public type JSON = {
            statusMinuscode : HTTPStatusEnum.JSON;
            availabilityMinusstatus : ?AvailabilityEnum.JSON;
            contentMinustype : ?Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : FieldAndEnumMapping) : JSON = {
            statusMinuscode = HTTPStatusEnum.toJSON(value.statusMinuscode);
            availabilityMinusstatus = switch (value.availabilityMinusstatus) { case (?v) ?AvailabilityEnum.toJSON(v); case null null };
            contentMinustype = value.contentMinustype;
        };

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?FieldAndEnumMapping {
            let ?statusMinuscode = HTTPStatusEnum.fromJSON(json.statusMinuscode) else return null;
            ?{
                statusMinuscode;
                availabilityMinusstatus = switch (json.availabilityMinusstatus) { case (?v) AvailabilityEnum.fromJSON(v); case null null };
                contentMinustype = json.contentMinustype;
            }
        };
    }
}
