
// ApiResponse.mo
/// Describes the result of uploading an image resource

module {
    public type ApiResponse = {
        code : ?Int;
        type_ : ?Text;
        message : ?Text;
    };
}
