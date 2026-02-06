// EnumMappings.mo - Global identifier mappings for JSON serialization
//
// This module contains all identifier mappings for the entire API.
// It provides bidirectional mappings for:
// - Enum variant names with special characters
// - Record field names with hyphens or reserved words
//
// These are used by serde's renameKeys option during JSON serialization.

module {
    // Mappings for SetPowerPowerParameter enum
    public let SetPowerPowerParameterOptions = {
        encode = [
            ("true_", "true")
        ];
        decode = [
            ("true", "true_")
        ];
    };

}
