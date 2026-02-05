
import { type InnerRecordWithEnum; JSON = InnerRecordWithEnum } "./InnerRecordWithEnum";

// OuterRecord.mo
/// Outer record containing inner record with enum (transitive)

module {
    // Motoko-facing type: what application code uses
    public type OuterRecord = {
        inner : InnerRecordWithEnum;
        id : ?Int;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer OuterRecord type
        public type JSON = {
            inner : InnerRecordWithEnum.JSON;
            id : ?Int;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : OuterRecord) : JSON = {
            inner = InnerRecordWithEnum.toJSON(value.inner);
            id = value.id;
        };

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?OuterRecord {
            let ?inner = InnerRecordWithEnum.fromJSON(json.inner) else return null;
            ?{
                inner;
                id = json.id;
            }
        };
    }
}
