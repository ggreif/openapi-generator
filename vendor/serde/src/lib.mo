// Minimal typecheck-only stub for serde
// This is NOT a functional implementation, just type signatures for typechecking generated code

module {
    public type Options = {
        // Placeholder for options - not used in generated code (always null)
    };

    public module JSON {
        /// Converts JSON text to a serialized Candid blob
        /// Returns #ok(blob) on success, #err(message) on failure
        public func fromText(_text : Text, _options : ?Options) : { #ok : Blob; #err : Text } {
            // Stub implementation - not actually callable
            #err("Stub implementation for typechecking only")
        };

        /// Converts serialized Candid blob to JSON text
        /// Returns #ok(text) on success, #err(message) on failure
        /// Parameters: blob - Candid-encoded data, keys - field names for decoding, options - optional configuration
        public func toText(_blob : Blob, _keys : [Text], _options : ?Options) : { #ok : Text; #err : Text } {
            // Stub implementation - not actually callable
            #err("Stub implementation for typechecking only")
        };
    };
};
