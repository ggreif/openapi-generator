// ZoneApi.mo

import Text "mo:core/Text";
import Int "mo:core/Int";
import Error "mo:core/Error";
import { JSON } "mo:serde";
import { type SetVolumeVolumeParameter } "../Models/SetVolumeVolumeParameter";

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

    /// Get sound program list
    /// Returns the list of available sound programs for the zone
    public func getSoundProgramList(baseUrl : Text, zone : Text) : async Any {
        let url = baseUrl # "/{zone}/getSoundProgramList"
            |> Text.replace(_, #text "{zone}", zone);

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

    /// Get zone status
    /// Returns the current status of the specified zone
    public func getZoneStatus(baseUrl : Text, zone : Text) : async Any {
        let url = baseUrl # "/{zone}/getStatus"
            |> Text.replace(_, #text "{zone}", zone);

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

    /// Prepare input change
    /// Let a device do necessary process before changing input in a specific zone
    public func prepareInputChange(baseUrl : Text, zone : Text, input : Text) : async Any {
        let url = baseUrl # "/{zone}/prepareInputChange"
            |> Text.replace(_, #text "{zone}", zone);

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

    /// Set input source
    /// Sets the input source for the zone
    public func setInput(baseUrl : Text, zone : Text, input : Text, mode : Text) : async Any {
        let url = baseUrl # "/{zone}/setInput"
            |> Text.replace(_, #text "{zone}", zone);

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

    /// Set mute
    /// Enables or disables mute for the zone
    public func setMute(baseUrl : Text, zone : Text, enable : Bool) : async Any {
        let url = baseUrl # "/{zone}/setMute"
            |> Text.replace(_, #text "{zone}", zone);

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

    /// Set sleep timer
    /// Sets the sleep timer in minutes (0 to cancel)
    public func setSleep(baseUrl : Text, zone : Text, sleep : Int) : async Any {
        let url = baseUrl # "/{zone}/setSleep"
            |> Text.replace(_, #text "{zone}", zone);

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

    /// Set sound program
    /// Sets the sound program (DSP mode) for the zone
    public func setSoundProgram(baseUrl : Text, zone : Text, program : Text) : async Any {
        let url = baseUrl # "/{zone}/setSoundProgram"
            |> Text.replace(_, #text "{zone}", zone);

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

    /// Set volume
    /// Sets the volume level directly or incrementally
    public func setVolume(baseUrl : Text, zone : Text, volume : SetVolumeVolumeParameter, step : Int) : async Any {
        let url = baseUrl # "/{zone}/setVolume"
            |> Text.replace(_, #text "{zone}", zone);

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
