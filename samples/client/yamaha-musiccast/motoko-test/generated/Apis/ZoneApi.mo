// ZoneApi.mo

import Text "mo:core/Text";
import Int "mo:core/Int";
import Array "mo:core/Array";
import Error "mo:core/Error";
import { JSON } "mo:serde";
//import { type CanisterHttpRequestArgument; type CanisterHttpResponsePayload; type HttpMethod; type HttpHeader; http_request } "ic:aaaaa-aa";
import { type SetInputInputParameter; JSON = SetInputInputParameter } "../Models/SetInputInputParameter";
import { type SetInputModeParameter; JSON = SetInputModeParameter } "../Models/SetInputModeParameter";
import { type SetVolumeVolumeParameter; JSON = SetVolumeVolumeParameter } "../Models/SetVolumeVolumeParameter";
//import { type CanisterHttpRequestArgument; type CanisterHttpResponsePayload; type HttpMethod; type HttpHeader; http_request } "ic:aaaaa-aa";
// FIXME: destructuring on `actor` types is not implemented yet
//        type error [M0114], object pattern cannot consume actor type
//import { type http_request_args; type http_request_result; type http_header; http_request } "ic:aaaaa-aa";
import Mgnt = "ic:aaaaa-aa";

module {

    type CanisterHttpRequestArgument = Mgnt.http_request_args;
    type CanisterHttpResponsePayload = Mgnt.http_request_result;
    type HttpHeader = Mgnt.http_header;
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

    /// Get sound program list
    /// Returns the list of available sound programs for the zone
    public func getSoundProgramList(config : Config__, zone : Text) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/{zone}/getSoundProgramList"
            |> Text.replace(_, #text "{zone}", zone);

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
            method = #get;
            headers;
            body = null;
        };

        // Call the management canister's http_request method with cycles
        let response : CanisterHttpResponsePayload = await (with cycles) Mgnt.http_request(request);

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
            from_candid(_) : ?Any |>
            (switch (_) {
                case (?result) result;
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

    /// Get zone status
    /// Returns the current status of the specified zone
    public func getZoneStatus(config : Config__, zone : Text) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/{zone}/getStatus"
            |> Text.replace(_, #text "{zone}", zone);

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
            method = #get;
            headers;
            body = null;
        };

        // Call the management canister's http_request method with cycles
        let response : CanisterHttpResponsePayload = await (with cycles) Mgnt.http_request(request);

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
            from_candid(_) : ?Any |>
            (switch (_) {
                case (?result) result;
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

    /// Prepare input change
    /// Let a device do necessary process before changing input in a specific zone
    public func prepareInputChange(config : Config__, zone : Text, input : Text) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/{zone}/prepareInputChange"
            |> Text.replace(_, #text "{zone}", zone)
            # "?" # "input=" # input;

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
            method = #get;
            headers;
            body = null;
        };

        // Call the management canister's http_request method with cycles
        let response : CanisterHttpResponsePayload = await (with cycles) Mgnt.http_request(request);

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
            from_candid(_) : ?Any |>
            (switch (_) {
                case (?result) result;
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

    /// Set input source
    /// Sets the input source for the zone
    public func setInput(config : Config__, zone : Text, input : SetInputInputParameter, mode : SetInputModeParameter) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/{zone}/setInput"
            |> Text.replace(_, #text "{zone}", zone)
            # "?" # "input=" # SetInputInputParameter.toJSON(input) # "&" # "mode=" # SetInputModeParameter.toJSON(mode);

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
            method = #get;
            headers;
            body = null;
        };

        // Call the management canister's http_request method with cycles
        let response : CanisterHttpResponsePayload = await (with cycles) Mgnt.http_request(request);

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
            from_candid(_) : ?Any |>
            (switch (_) {
                case (?result) result;
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

    /// Set mute
    /// Enables or disables mute for the zone
    public func setMute(config : Config__, zone : Text, enable : Bool) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/{zone}/setMute"
            |> Text.replace(_, #text "{zone}", zone)
            # "?" # "enable=" # debug_show(enable);

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
            method = #get;
            headers;
            body = null;
        };

        // Call the management canister's http_request method with cycles
        let response : CanisterHttpResponsePayload = await (with cycles) Mgnt.http_request(request);

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
            from_candid(_) : ?Any |>
            (switch (_) {
                case (?result) result;
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

    /// Set sleep timer
    /// Sets the sleep timer in minutes (0 to cancel)
    public func setSleep(config : Config__, zone : Text, sleep : Nat) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/{zone}/setSleep"
            |> Text.replace(_, #text "{zone}", zone)
            # "?" # "sleep=" # Int.toText(sleep);

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
            method = #get;
            headers;
            body = null;
        };

        // Call the management canister's http_request method with cycles
        let response : CanisterHttpResponsePayload = await (with cycles) Mgnt.http_request(request);

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
            from_candid(_) : ?Any |>
            (switch (_) {
                case (?result) result;
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

    /// Set sound program
    /// Sets the sound program (DSP mode) for the zone
    public func setSoundProgram(config : Config__, zone : Text, program : Text) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/{zone}/setSoundProgram"
            |> Text.replace(_, #text "{zone}", zone)
            # "?" # "program=" # program;

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
            method = #get;
            headers;
            body = null;
        };

        // Call the management canister's http_request method with cycles
        let response : CanisterHttpResponsePayload = await (with cycles) Mgnt.http_request(request);

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
            from_candid(_) : ?Any |>
            (switch (_) {
                case (?result) result;
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

    /// Set volume
    /// Sets the volume level directly or incrementally
    public func setVolume(config : Config__, zone : Text, volume : SetVolumeVolumeParameter, step : Nat) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/{zone}/setVolume"
            |> Text.replace(_, #text "{zone}", zone)
            # "?" # "volume=" # SetVolumeVolumeParameter.toText(volume) # "&" # "step=" # Int.toText(step);

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
            method = #get;
            headers;
            body = null;
        };

        // Call the management canister's http_request method with cycles
        let response : CanisterHttpResponsePayload = await (with cycles) Mgnt.http_request(request);

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
            from_candid(_) : ?Any |>
            (switch (_) {
                case (?result) result;
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
        getSoundProgramList;
        getZoneStatus;
        prepareInputChange;
        setInput;
        setMute;
        setSleep;
        setSoundProgram;
        setVolume;
    };

    public module class ZoneApi(config : Config__) {
        /// Get sound program list
        /// Returns the list of available sound programs for the zone
        public func getSoundProgramList(zone : Text) : async Any {
            await* operations__.getSoundProgramList(config, zone)
        };

        /// Get zone status
        /// Returns the current status of the specified zone
        public func getZoneStatus(zone : Text) : async Any {
            await* operations__.getZoneStatus(config, zone)
        };

        /// Prepare input change
        /// Let a device do necessary process before changing input in a specific zone
        public func prepareInputChange(zone : Text, input : Text) : async Any {
            await* operations__.prepareInputChange(config, zone, input)
        };

        /// Set input source
        /// Sets the input source for the zone
        public func setInput(zone : Text, input : SetInputInputParameter, mode : SetInputModeParameter) : async Any {
            await* operations__.setInput(config, zone, input, mode)
        };

        /// Set mute
        /// Enables or disables mute for the zone
        public func setMute(zone : Text, enable : Bool) : async Any {
            await* operations__.setMute(config, zone, enable)
        };

        /// Set sleep timer
        /// Sets the sleep timer in minutes (0 to cancel)
        public func setSleep(zone : Text, sleep : Nat) : async Any {
            await* operations__.setSleep(config, zone, sleep)
        };

        /// Set sound program
        /// Sets the sound program (DSP mode) for the zone
        public func setSoundProgram(zone : Text, program : Text) : async Any {
            await* operations__.setSoundProgram(config, zone, program)
        };

        /// Set volume
        /// Sets the volume level directly or incrementally
        public func setVolume(zone : Text, volume : SetVolumeVolumeParameter, step : Nat) : async Any {
            await* operations__.setVolume(config, zone, volume, step)
        };

    }
}
