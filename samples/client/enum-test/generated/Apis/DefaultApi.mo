// DefaultApi.mo

import Text "mo:core/Text";
import Int "mo:core/Int";
import Array "mo:core/Array";
import Error "mo:core/Error";
import { JSON; Candid } "mo:serde";
import EnumMappings "../EnumMappings";
import { type HttpHeader } "../Models/HttpHeader";
import { type ReservedWordModel } "../Models/ReservedWordModel";
import { type TestHyphenatedEnumRequest } "../Models/TestHyphenatedEnumRequest";
import { type TestNumericEnumRequest } "../Models/TestNumericEnumRequest";

module {
    // Management Canister interface for HTTP outcalls
    // Based on types in https://github.com/dfinity/sdk/blob/master/src/dfx/src/util/ic.did
    type HttpHeader = {
        name : Text;
        value : Text;
    };

    type HttpMethod = {
        #get;
        #head;
        #post;
        // TODO: IC HTTP outcalls currently only support GET, HEAD, and POST.
        //   PUT and DELETE methods are not yet supported by the management canister.
        //   Once support is added, uncomment these:
        // #put;
        // #delete;
    };

    type CanisterHttpRequestArgument = {
        url : Text;
        max_response_bytes : ?Nat64;
        method : HttpMethod;
        headers : [HttpHeader];
        body : ?Blob;
        transform : ?{
            function : shared query ({ response : CanisterHttpResponsePayload; context : Blob }) -> async CanisterHttpResponsePayload;
            context : Blob;
        };
        is_replicated : ?Bool;
    };

    type CanisterHttpResponsePayload = {
        status : Nat;
        headers : [HttpHeader];
        body : Blob;
    };

    let http_request = (actor "aaaaa-aa" : actor { http_request : (CanisterHttpRequestArgument) -> async CanisterHttpResponsePayload }).http_request;

    // Global encoding/decoding options for JSON serialization
    let allEncodeMappings : [(Text, Text)] = [
        ("available_now", "Available Now!"),
        ("out_of_stock", "Out of Stock"),
        ("pre_order", "Pre-Order"),
        ("coming_soon", "Coming Soon..."),
        ("_200_", "200"),
        ("_404_", "404"),
        ("_500_", "500"),
        ("blue_green", "blue-green"),
        ("red_orange", "red-orange"),
        ("yellow_green", "yellow-green"),
        ("contentMinustype", "content-type"),
        ("cacheMinuscontrol", "cache-control"),
        ("xMinusrequestMinusid", "x-request-id"),
        ("try_", "try"),
        ("type_", "type"),
        ("switch_", "switch"),
    ];

    let allDecodeMappings : [(Text, Text)] = [
        ("Available Now!", "available_now"),
        ("Out of Stock", "out_of_stock"),
        ("Pre-Order", "pre_order"),
        ("Coming Soon...", "coming_soon"),
        ("200", "_200_"),
        ("404", "_404_"),
        ("500", "_500_"),
        ("blue-green", "blue_green"),
        ("red-orange", "red_orange"),
        ("yellow-green", "yellow_green"),
        ("content-type", "contentMinustype"),
        ("cache-control", "cacheMinuscontrol"),
        ("x-request-id", "xMinusrequestMinusid"),
        ("try", "try_"),
        ("type", "type_"),
        ("switch", "switch_"),
    ];

    type Config__ = {
        baseUrl : Text;
        accessToken : ?Text;
        max_response_bytes : ?Nat64;
        transform : ?{
            function : shared query ({ response : CanisterHttpResponsePayload; context : Blob }) -> async CanisterHttpResponsePayload;
            context : Blob;
        };
        is_replicated : ?Bool;
        cycles : Nat;
    };

    /// Test record fields with hyphens
    public func testEscapedFields(config : Config__, httpHeader : HttpHeader) : async* HttpHeader {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/test-escaped-fields";

        let baseHeaders = [
            { name = "Content-Type"; value = "application/json; charset=utf-8" }
        ];

        // Add Authorization header if access token is provided
        let headers = switch (accessToken) {
            case (?token) {
                Array.concat(baseHeaders, [{ name = "Authorization"; value = "Bearer " # token }]);
            };
            case null { baseHeaders };
        };

        let request : CanisterHttpRequestArgument = { config with
            url;
            method = #post;
            headers;
            body = do ? { let candidBlob = to_candid(httpHeader); let requestOptions = { Candid.defaultOptions with renameKeys = allEncodeMappings }; let #ok(jsonText) = JSON.toText(candidBlob, [], ?requestOptions) else throw Error.reject("Failed to serialize to JSON"); Text.encodeUtf8(jsonText) };
        };

        // Call the management canister's http_request method with cycles
        let response : CanisterHttpResponsePayload = await (with cycles) http_request(request);

        // Check HTTP status code before parsing
        if (response.status >= 200 and response.status < 300) {
            // Success response (2xx): parse as expected return type
            (switch (Text.decodeUtf8(response.body)) {
                case (?text) text;
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to decode response body as UTF-8");
            }) |>
            (do {
                let responseOptions = { Candid.defaultOptions with renameKeys = allDecodeMappings };
                switch (JSON.fromText(_, ?responseOptions)) {
                    case (#ok(blob)) blob;
                    case (#err(msg)) throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to parse JSON: " # msg);
                }
            }) |>
            from_candid(_) : ?HttpHeader |>
            (switch (_) {
                case (?value) value;
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to deserialize response to HttpHeader");
            })
        } else {
            // Error response (4xx, 5xx): parse error models and throw
            let responseText = switch (Text.decodeUtf8(response.body)) {
                case (?text) text;
                case null "";  // Empty body for some errors (e.g., 404)
            };


            // Fallback for status codes not defined in OpenAPI spec
            throw Error.reject("HTTP " # Int.toText(response.status) # ": Unexpected error" #
                (if (responseText != "") { " - " # responseText } else { "" }));
        }
    };

    /// Test hyphenated enum values
    public func testHyphenatedEnum(config : Config__, testHyphenatedEnumRequest : TestHyphenatedEnumRequest) : async* TestHyphenatedEnumRequest {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/test-hyphenated-enum";

        let baseHeaders = [
            { name = "Content-Type"; value = "application/json; charset=utf-8" }
        ];

        // Add Authorization header if access token is provided
        let headers = switch (accessToken) {
            case (?token) {
                Array.concat(baseHeaders, [{ name = "Authorization"; value = "Bearer " # token }]);
            };
            case null { baseHeaders };
        };

        let request : CanisterHttpRequestArgument = { config with
            url;
            method = #post;
            headers;
            body = do ? { let candidBlob = to_candid(testHyphenatedEnumRequest); let requestOptions = { Candid.defaultOptions with renameKeys = allEncodeMappings }; let #ok(jsonText) = JSON.toText(candidBlob, [], ?requestOptions) else throw Error.reject("Failed to serialize to JSON"); Text.encodeUtf8(jsonText) };
        };

        // Call the management canister's http_request method with cycles
        let response : CanisterHttpResponsePayload = await (with cycles) http_request(request);

        // Check HTTP status code before parsing
        if (response.status >= 200 and response.status < 300) {
            // Success response (2xx): parse as expected return type
            (switch (Text.decodeUtf8(response.body)) {
                case (?text) text;
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to decode response body as UTF-8");
            }) |>
            (do {
                let responseOptions = { Candid.defaultOptions with renameKeys = allDecodeMappings };
                switch (JSON.fromText(_, ?responseOptions)) {
                    case (#ok(blob)) blob;
                    case (#err(msg)) throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to parse JSON: " # msg);
                }
            }) |>
            from_candid(_) : ?TestHyphenatedEnumRequest |>
            (switch (_) {
                case (?value) value;
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to deserialize response to TestHyphenatedEnumRequest");
            })
        } else {
            // Error response (4xx, 5xx): parse error models and throw
            let responseText = switch (Text.decodeUtf8(response.body)) {
                case (?text) text;
                case null "";  // Empty body for some errors (e.g., 404)
            };


            // Fallback for status codes not defined in OpenAPI spec
            throw Error.reject("HTTP " # Int.toText(response.status) # ": Unexpected error" #
                (if (responseText != "") { " - " # responseText } else { "" }));
        }
    };

    /// Test numeric enum values
    public func testNumericEnum(config : Config__, testNumericEnumRequest : TestNumericEnumRequest) : async* TestNumericEnumRequest {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/test-numeric-enum";

        let baseHeaders = [
            { name = "Content-Type"; value = "application/json; charset=utf-8" }
        ];

        // Add Authorization header if access token is provided
        let headers = switch (accessToken) {
            case (?token) {
                Array.concat(baseHeaders, [{ name = "Authorization"; value = "Bearer " # token }]);
            };
            case null { baseHeaders };
        };

        let request : CanisterHttpRequestArgument = { config with
            url;
            method = #post;
            headers;
            body = do ? { let candidBlob = to_candid(testNumericEnumRequest); let requestOptions = { Candid.defaultOptions with renameKeys = allEncodeMappings }; let #ok(jsonText) = JSON.toText(candidBlob, [], ?requestOptions) else throw Error.reject("Failed to serialize to JSON"); Text.encodeUtf8(jsonText) };
        };

        // Call the management canister's http_request method with cycles
        let response : CanisterHttpResponsePayload = await (with cycles) http_request(request);

        // Check HTTP status code before parsing
        if (response.status >= 200 and response.status < 300) {
            // Success response (2xx): parse as expected return type
            (switch (Text.decodeUtf8(response.body)) {
                case (?text) text;
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to decode response body as UTF-8");
            }) |>
            (do {
                let responseOptions = { Candid.defaultOptions with renameKeys = allDecodeMappings };
                switch (JSON.fromText(_, ?responseOptions)) {
                    case (#ok(blob)) blob;
                    case (#err(msg)) throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to parse JSON: " # msg);
                }
            }) |>
            from_candid(_) : ?TestNumericEnumRequest |>
            (switch (_) {
                case (?value) value;
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to deserialize response to TestNumericEnumRequest");
            })
        } else {
            // Error response (4xx, 5xx): parse error models and throw
            let responseText = switch (Text.decodeUtf8(response.body)) {
                case (?text) text;
                case null "";  // Empty body for some errors (e.g., 404)
            };


            // Fallback for status codes not defined in OpenAPI spec
            throw Error.reject("HTTP " # Int.toText(response.status) # ": Unexpected error" #
                (if (responseText != "") { " - " # responseText } else { "" }));
        }
    };

    /// Test reserved word field names
    public func testReservedWords(config : Config__, reservedWordModel : ReservedWordModel) : async* ReservedWordModel {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/test-reserved-words";

        let baseHeaders = [
            { name = "Content-Type"; value = "application/json; charset=utf-8" }
        ];

        // Add Authorization header if access token is provided
        let headers = switch (accessToken) {
            case (?token) {
                Array.concat(baseHeaders, [{ name = "Authorization"; value = "Bearer " # token }]);
            };
            case null { baseHeaders };
        };

        let request : CanisterHttpRequestArgument = { config with
            url;
            method = #post;
            headers;
            body = do ? { let candidBlob = to_candid(reservedWordModel); let requestOptions = { Candid.defaultOptions with renameKeys = allEncodeMappings }; let #ok(jsonText) = JSON.toText(candidBlob, [], ?requestOptions) else throw Error.reject("Failed to serialize to JSON"); Text.encodeUtf8(jsonText) };
        };

        // Call the management canister's http_request method with cycles
        let response : CanisterHttpResponsePayload = await (with cycles) http_request(request);

        // Check HTTP status code before parsing
        if (response.status >= 200 and response.status < 300) {
            // Success response (2xx): parse as expected return type
            (switch (Text.decodeUtf8(response.body)) {
                case (?text) text;
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to decode response body as UTF-8");
            }) |>
            (do {
                let responseOptions = { Candid.defaultOptions with renameKeys = allDecodeMappings };
                switch (JSON.fromText(_, ?responseOptions)) {
                    case (#ok(blob)) blob;
                    case (#err(msg)) throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to parse JSON: " # msg);
                }
            }) |>
            from_candid(_) : ?ReservedWordModel |>
            (switch (_) {
                case (?value) value;
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to deserialize response to ReservedWordModel");
            })
        } else {
            // Error response (4xx, 5xx): parse error models and throw
            let responseText = switch (Text.decodeUtf8(response.body)) {
                case (?text) text;
                case null "";  // Empty body for some errors (e.g., 404)
            };


            // Fallback for status codes not defined in OpenAPI spec
            throw Error.reject("HTTP " # Int.toText(response.status) # ": Unexpected error" #
                (if (responseText != "") { " - " # responseText } else { "" }));
        }
    };


    let operations__ = {
        testEscapedFields;
        testHyphenatedEnum;
        testNumericEnum;
        testReservedWords;
    };

    public module class DefaultApi(config : Config__) {
        /// Test record fields with hyphens
        public func testEscapedFields(httpHeader : HttpHeader) : async HttpHeader {
            await* operations__.testEscapedFields(config, httpHeader)
        };

        /// Test hyphenated enum values
        public func testHyphenatedEnum(testHyphenatedEnumRequest : TestHyphenatedEnumRequest) : async TestHyphenatedEnumRequest {
            await* operations__.testHyphenatedEnum(config, testHyphenatedEnumRequest)
        };

        /// Test numeric enum values
        public func testNumericEnum(testNumericEnumRequest : TestNumericEnumRequest) : async TestNumericEnumRequest {
            await* operations__.testNumericEnum(config, testNumericEnumRequest)
        };

        /// Test reserved word field names
        public func testReservedWords(reservedWordModel : ReservedWordModel) : async ReservedWordModel {
            await* operations__.testReservedWords(config, reservedWordModel)
        };

    }
}
