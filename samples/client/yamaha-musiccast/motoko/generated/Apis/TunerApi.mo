// TunerApi.mo

import Text "mo:core/Text";
import Int "mo:core/Int";
import Error "mo:core/Error";
import { JSON } "mo:serde";

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

    /// Get tuner playing info
    /// Returns information about the currently playing tuner station
    public func getTunerPlayInfo(baseUrl : Text) : async Any {
        let url = baseUrl # "/tuner/getPlayInfo";

        let request : CanisterHttpRequestArgument = {
            url;
            max_response_bytes = null;
            method = #get;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = null;
            transform = null;
            is_replicated = null;
        };

        // Call the management canister's http_request method with cycles
        // 30M cycles should be sufficient for most requests
        let response : CanisterHttpResponsePayload = await (with cycles = 30_000_000_000) http_request(request);

        // Parse JSON response
        let responseText = switch (Text.decodeUtf8(response.body)) {
            case (?text) text;
            case null throw Error.reject("Failed to decode response body as UTF-8");
        };

        let jsonBlob = switch (JSON.fromText(responseText, null)) {
            case (#ok(blob)) blob;
            case (#err(msg)) throw Error.reject("Failed to parse JSON: " # msg);
        };

        let result : ?Any = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to Any");
        }
    };

    /// Get tuner preset info
    /// Returns information about tuner presets
    public func getTunerPresetInfo(baseUrl : Text, band : Text) : async Any {
        let url = baseUrl # "/tuner/getPresetInfo";

        let request : CanisterHttpRequestArgument = {
            url;
            max_response_bytes = null;
            method = #get;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = null;
            transform = null;
            is_replicated = null;
        };

        // Call the management canister's http_request method with cycles
        // 30M cycles should be sufficient for most requests
        let response : CanisterHttpResponsePayload = await (with cycles = 30_000_000_000) http_request(request);

        // Parse JSON response
        let responseText = switch (Text.decodeUtf8(response.body)) {
            case (?text) text;
            case null throw Error.reject("Failed to decode response body as UTF-8");
        };

        let jsonBlob = switch (JSON.fromText(responseText, null)) {
            case (#ok(blob)) blob;
            case (#err(msg)) throw Error.reject("Failed to parse JSON: " # msg);
        };

        let result : ?Any = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to Any");
        }
    };

    /// Recall tuner preset
    /// Recalls a saved tuner preset
    public func recallTunerPreset(baseUrl : Text, zone : Text, band : Text, num : Int) : async Any {
        let url = baseUrl # "/tuner/recallPreset";

        let request : CanisterHttpRequestArgument = {
            url;
            max_response_bytes = null;
            method = #get;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = null;
            transform = null;
            is_replicated = null;
        };

        // Call the management canister's http_request method with cycles
        // 30M cycles should be sufficient for most requests
        let response : CanisterHttpResponsePayload = await (with cycles = 30_000_000_000) http_request(request);

        // Parse JSON response
        let responseText = switch (Text.decodeUtf8(response.body)) {
            case (?text) text;
            case null throw Error.reject("Failed to decode response body as UTF-8");
        };

        let jsonBlob = switch (JSON.fromText(responseText, null)) {
            case (#ok(blob)) blob;
            case (#err(msg)) throw Error.reject("Failed to parse JSON: " # msg);
        };

        let result : ?Any = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to Any");
        }
    };

    /// Change DAB service
    /// Switches to the next or previous DAB service
    public func setDabService(baseUrl : Text, dir : Text) : async Any {
        let url = baseUrl # "/tuner/setDabService";

        let request : CanisterHttpRequestArgument = {
            url;
            max_response_bytes = null;
            method = #get;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = null;
            transform = null;
            is_replicated = null;
        };

        // Call the management canister's http_request method with cycles
        // 30M cycles should be sufficient for most requests
        let response : CanisterHttpResponsePayload = await (with cycles = 30_000_000_000) http_request(request);

        // Parse JSON response
        let responseText = switch (Text.decodeUtf8(response.body)) {
            case (?text) text;
            case null throw Error.reject("Failed to decode response body as UTF-8");
        };

        let jsonBlob = switch (JSON.fromText(responseText, null)) {
            case (#ok(blob)) blob;
            case (#err(msg)) throw Error.reject("Failed to parse JSON: " # msg);
        };

        let result : ?Any = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to Any");
        }
    };

    /// Set tuner frequency
    /// Tunes to a specific frequency
    public func setTunerFreq(baseUrl : Text, band : Text, tuning : Text, num : Int) : async Any {
        let url = baseUrl # "/tuner/setFreq";

        let request : CanisterHttpRequestArgument = {
            url;
            max_response_bytes = null;
            method = #get;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = null;
            transform = null;
            is_replicated = null;
        };

        // Call the management canister's http_request method with cycles
        // 30M cycles should be sufficient for most requests
        let response : CanisterHttpResponsePayload = await (with cycles = 30_000_000_000) http_request(request);

        // Parse JSON response
        let responseText = switch (Text.decodeUtf8(response.body)) {
            case (?text) text;
            case null throw Error.reject("Failed to decode response body as UTF-8");
        };

        let jsonBlob = switch (JSON.fromText(responseText, null)) {
            case (#ok(blob)) blob;
            case (#err(msg)) throw Error.reject("Failed to parse JSON: " # msg);
        };

        let result : ?Any = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to Any");
        }
    };

    /// Store tuner preset
    /// Stores the current tuner station as a preset
    public func storeTunerPreset(baseUrl : Text, num : Int) : async Any {
        let url = baseUrl # "/tuner/storePreset";

        let request : CanisterHttpRequestArgument = {
            url;
            max_response_bytes = null;
            method = #get;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = null;
            transform = null;
            is_replicated = null;
        };

        // Call the management canister's http_request method with cycles
        // 30M cycles should be sufficient for most requests
        let response : CanisterHttpResponsePayload = await (with cycles = 30_000_000_000) http_request(request);

        // Parse JSON response
        let responseText = switch (Text.decodeUtf8(response.body)) {
            case (?text) text;
            case null throw Error.reject("Failed to decode response body as UTF-8");
        };

        let jsonBlob = switch (JSON.fromText(responseText, null)) {
            case (#ok(blob)) blob;
            case (#err(msg)) throw Error.reject("Failed to parse JSON: " # msg);
        };

        let result : ?Any = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to Any");
        }
    };

    /// Switch tuner preset
    /// Switches to the next or previous tuner preset
    public func switchTunerPreset(baseUrl : Text, dir : Text) : async Any {
        let url = baseUrl # "/tuner/switchPreset";

        let request : CanisterHttpRequestArgument = {
            url;
            max_response_bytes = null;
            method = #get;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = null;
            transform = null;
            is_replicated = null;
        };

        // Call the management canister's http_request method with cycles
        // 30M cycles should be sufficient for most requests
        let response : CanisterHttpResponsePayload = await (with cycles = 30_000_000_000) http_request(request);

        // Parse JSON response
        let responseText = switch (Text.decodeUtf8(response.body)) {
            case (?text) text;
            case null throw Error.reject("Failed to decode response body as UTF-8");
        };

        let jsonBlob = switch (JSON.fromText(responseText, null)) {
            case (#ok(blob)) blob;
            case (#err(msg)) throw Error.reject("Failed to parse JSON: " # msg);
        };

        let result : ?Any = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to Any");
        }
    };

}
