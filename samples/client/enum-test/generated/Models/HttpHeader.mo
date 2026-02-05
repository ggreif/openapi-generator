
// HttpHeader.mo
/// Model with hyphenated field names

module {
    // Motoko-facing type: what application code uses
    public type HttpHeader = {
        contentMinustype : Text;
        cacheMinuscontrol : ?Text;
        xMinusrequestMinusid : ?Text;
    };

    // JSON sub-module: everything needed for JSON serialization
    public module JSON {
        // JSON-facing Motoko type: mirrors JSON structure
        // Named "JSON" to avoid shadowing the outer HttpHeader type
        public type JSON = {
            contentMinustype : Text;
            cacheMinuscontrol : ?Text;
            xMinusrequestMinusid : ?Text;
        };

        // Convert Motoko-facing type to JSON-facing Motoko type
        public func toJSON(value : HttpHeader) : JSON = {
            contentMinustype = value.contentMinustype;
            cacheMinuscontrol = switch (value.cacheMinuscontrol) { case (?v) ?v; case null null };
            xMinusrequestMinusid = switch (value.xMinusrequestMinusid) { case (?v) ?v; case null null };
        };

        // Convert JSON-facing Motoko type to Motoko-facing type
        public func fromJSON(json : JSON) : ?HttpHeader {
            ?{
                contentMinustype = json.contentMinustype;
                cacheMinuscontrol = json.cacheMinuscontrol;
                xMinusrequestMinusid = json.xMinusrequestMinusid;
            }
        };
    }
}
