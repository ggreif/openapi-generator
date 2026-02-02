// EnumMappings.mo - Global identifier mappings for JSON serialization
//
// This module contains all identifier mappings for the entire API.
// It provides bidirectional mappings for:
// - Enum variant names with special characters
// - Record field names with hyphens or reserved words
//
// These are used by serde's renameKeys option during JSON serialization.

module {
    // Mappings for AvailabilityEnum enum
    public let AvailabilityEnumOptions = {
        encode = [
            ("available_now", "Available Now!"),
            ("out_of_stock", "Out of Stock"),
            ("pre_order", "Pre-Order"),
            ("coming_soon", "Coming Soon...")
        ];
        decode = [
            ("Available Now!", "available_now"),
            ("Out of Stock", "out_of_stock"),
            ("Pre-Order", "pre_order"),
            ("Coming Soon...", "coming_soon")
        ];
    };

    // Mappings for HTTPStatusEnum enum
    public let HTTPStatusEnumOptions = {
        encode = [
            ("_200_", "200"),
            ("_404_", "404"),
            ("_500_", "500")
        ];
        decode = [
            ("200", "_200_"),
            ("404", "_404_"),
            ("500", "_500_")
        ];
    };

    // Mappings for HyphenatedColorEnum enum
    public let HyphenatedColorEnumOptions = {
        encode = [
            ("blue_green", "blue-green"),
            ("red_orange", "red-orange"),
            ("yellow_green", "yellow-green")
        ];
        decode = [
            ("blue-green", "blue_green"),
            ("red-orange", "red_orange"),
            ("yellow-green", "yellow_green")
        ];
    };

    // Field mappings for HttpHeader model
    public let HttpHeaderFieldOptions = {
        encode = [
            ("contentMinustype", "content-type"),
            ("cacheMinuscontrol", "cache-control"),
            ("xMinusrequestMinusid", "x-request-id")
        ];
        decode = [
            ("content-type", "contentMinustype"),
            ("cache-control", "cacheMinuscontrol"),
            ("x-request-id", "xMinusrequestMinusid")
        ];
    };

    // Field mappings for ReservedWordModel model
    public let ReservedWordModelFieldOptions = {
        encode = [
            ("try_", "try"),
            ("type_", "type"),
            ("switch_", "switch")
        ];
        decode = [
            ("try", "try_"),
            ("type", "type_"),
            ("switch", "switch_")
        ];
    };

}
