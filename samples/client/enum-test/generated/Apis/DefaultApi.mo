// DefaultApi.mo

import Text "mo:core/Text";
import Int "mo:core/Int";
import Array "mo:core/Array";
import Error "mo:core/Error";
import { JSON } "mo:serde";
import { type HttpHeader; JSON = HttpHeader } "../Models/HttpHeader";
import { type OuterRecord; JSON = OuterRecord } "../Models/OuterRecord";
import { type ReservedWordModel; JSON = ReservedWordModel } "../Models/ReservedWordModel";
import { type TestHyphenatedEnumRequest; JSON = TestHyphenatedEnumRequest } "../Models/TestHyphenatedEnumRequest";
import { type TestNumericEnumRequest; JSON = TestNumericEnumRequest } "../Models/TestNumericEnumRequest";

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
            body = do ? {
                let jsonValue = HttpHeader.toJSON(httpHeader);
                let candidBlob = to_candid(jsonValue);
                let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON");
                Text.encodeUtf8(jsonText)
            };
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
            (switch (JSON.fromText(_, null)) {
                case (#ok(blob)) blob;
                case (#err(msg)) throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to parse JSON: " # msg);
            }) |>
            from_candid(_) : ?HttpHeader.JSON |>
            (switch (_) {
                case (?jsonValue) {
                    switch (HttpHeader.fromJSON(jsonValue)) {
                        case (?value) value;
                        case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to convert response to HttpHeader");
                    }
                };
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to deserialize response");
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
            body = do ? {
                let jsonValue = TestHyphenatedEnumRequest.toJSON(testHyphenatedEnumRequest);
                let candidBlob = to_candid(jsonValue);
                let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON");
                Text.encodeUtf8(jsonText)
            };
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
            (switch (JSON.fromText(_, null)) {
                case (#ok(blob)) blob;
                case (#err(msg)) throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to parse JSON: " # msg);
            }) |>
            from_candid(_) : ?TestHyphenatedEnumRequest.JSON |>
            (switch (_) {
                case (?jsonValue) {
                    switch (TestHyphenatedEnumRequest.fromJSON(jsonValue)) {
                        case (?value) value;
                        case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to convert response to TestHyphenatedEnumRequest");
                    }
                };
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to deserialize response");
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
            body = do ? {
                let jsonValue = TestNumericEnumRequest.toJSON(testNumericEnumRequest);
                let candidBlob = to_candid(jsonValue);
                let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON");
                Text.encodeUtf8(jsonText)
            };
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
            (switch (JSON.fromText(_, null)) {
                case (#ok(blob)) blob;
                case (#err(msg)) throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to parse JSON: " # msg);
            }) |>
            from_candid(_) : ?TestNumericEnumRequest.JSON |>
            (switch (_) {
                case (?jsonValue) {
                    switch (TestNumericEnumRequest.fromJSON(jsonValue)) {
                        case (?value) value;
                        case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to convert response to TestNumericEnumRequest");
                    }
                };
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to deserialize response");
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
            body = do ? {
                let jsonValue = ReservedWordModel.toJSON(reservedWordModel);
                let candidBlob = to_candid(jsonValue);
                let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON");
                Text.encodeUtf8(jsonText)
            };
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
            (switch (JSON.fromText(_, null)) {
                case (#ok(blob)) blob;
                case (#err(msg)) throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to parse JSON: " # msg);
            }) |>
            from_candid(_) : ?ReservedWordModel.JSON |>
            (switch (_) {
                case (?jsonValue) {
                    switch (ReservedWordModel.fromJSON(jsonValue)) {
                        case (?value) value;
                        case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to convert response to ReservedWordModel");
                    }
                };
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to deserialize response");
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

    /// Test transitive enum references (Record containing Record containing Enum)
    public func testTransitiveEnum(config : Config__, outerRecord : OuterRecord) : async* OuterRecord {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/test-transitive-enum";

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
            body = do ? {
                let jsonValue = OuterRecord.toJSON(outerRecord);
                let candidBlob = to_candid(jsonValue);
                let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON");
                Text.encodeUtf8(jsonText)
            };
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
            (switch (JSON.fromText(_, null)) {
                case (#ok(blob)) blob;
                case (#err(msg)) throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to parse JSON: " # msg);
            }) |>
            from_candid(_) : ?OuterRecord.JSON |>
            (switch (_) {
                case (?jsonValue) {
                    switch (OuterRecord.fromJSON(jsonValue)) {
                        case (?value) value;
                        case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to convert response to OuterRecord");
                    }
                };
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to deserialize response");
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
        testTransitiveEnum;
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

        /// Test transitive enum references (Record containing Record containing Enum)
        public func testTransitiveEnum(outerRecord : OuterRecord) : async OuterRecord {
            await* operations__.testTransitiveEnum(config, outerRecord)
        };

    }
}
