// TunerApi.mo

import Text "mo:core/Text";
import Int "mo:core/Int";
import Array "mo:core/Array";
import Error "mo:core/Error";
import { JSON } "mo:serde";
// FIXME: destructuring on `actor` types is not implemented yet for shared functions
//        type error [M0114], object pattern cannot consume actor type
import { type http_request_args; type http_request_result } "ic:aaaaa-aa";
import Mgnt__ = "ic:aaaaa-aa";
import { type RecallTunerPresetBandParameter; JSON = RecallTunerPresetBandParameter } "../Models/RecallTunerPresetBandParameter";
import { type SetTunerFreqTuningParameter; JSON = SetTunerFreqTuningParameter } "../Models/SetTunerFreqTuningParameter";
import { type SwitchTunerPresetDirParameter; JSON = SwitchTunerPresetDirParameter } "../Models/SwitchTunerPresetDirParameter";

module {
    type http_method = {
        #get;
        #head;
        #post;
        // TODO: IC HTTP outcalls currently only support GET, HEAD, and POST.
        //   PUT and DELETE methods are not yet supported by the management canister.
        //   Once support is added, uncomment these:
        // #put;
        // #delete;
    };

    let http_request = Mgnt__.http_request;

    type Config__ = {
        baseUrl : Text;
        accessToken : ?Text;
        max_response_bytes : ?Nat64;
        transform : ?{
            function : shared query ({ response : http_request_result; context : Blob }) -> async http_request_result;
            context : Blob;
        };
        is_replicated : ?Bool;
        cycles : Nat;
    };

    /// Get tuner playing info
    /// Returns information about the currently playing tuner station
    public func getTunerPlayInfo(config : Config__) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/tuner/getPlayInfo";

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

        let request : http_request_args = { config with
            url;
            method = #get;
            headers;
            body = null;
        };

        // Call the management canister's http_request method with cycles
        let response : http_request_result = await (with cycles) http_request(request);

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

    /// Get tuner preset info
    /// Returns information about tuner presets
    public func getTunerPresetInfo(config : Config__, band : RecallTunerPresetBandParameter) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/tuner/getPresetInfo"
            # "?" # "band=" # RecallTunerPresetBandParameter.toJSON(band);

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

        let request : http_request_args = { config with
            url;
            method = #get;
            headers;
            body = null;
        };

        // Call the management canister's http_request method with cycles
        let response : http_request_result = await (with cycles) http_request(request);

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

    /// Recall tuner preset
    /// Recalls a saved tuner preset
    public func recallTunerPreset(config : Config__, zone : Text, band : RecallTunerPresetBandParameter, num : Nat) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/tuner/recallPreset"
            # "?" # "zone=" # zone # "&" # "band=" # RecallTunerPresetBandParameter.toJSON(band) # "&" # "num=" # Int.toText(num);

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

        let request : http_request_args = { config with
            url;
            method = #get;
            headers;
            body = null;
        };

        // Call the management canister's http_request method with cycles
        let response : http_request_result = await (with cycles) http_request(request);

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

    /// Change DAB service
    /// Switches to the next or previous DAB service
    public func setDabService(config : Config__, dir : SwitchTunerPresetDirParameter) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/tuner/setDabService"
            # "?" # "dir=" # SwitchTunerPresetDirParameter.toJSON(dir);

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

        let request : http_request_args = { config with
            url;
            method = #get;
            headers;
            body = null;
        };

        // Call the management canister's http_request method with cycles
        let response : http_request_result = await (with cycles) http_request(request);

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

    /// Set tuner frequency
    /// Tunes to a specific frequency
    public func setTunerFreq(config : Config__, band : RecallTunerPresetBandParameter, tuning : SetTunerFreqTuningParameter, num : Nat) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/tuner/setFreq"
            # "?" # "band=" # RecallTunerPresetBandParameter.toJSON(band) # "&" # "tuning=" # SetTunerFreqTuningParameter.toJSON(tuning) # "&" # "num=" # Int.toText(num);

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

        let request : http_request_args = { config with
            url;
            method = #get;
            headers;
            body = null;
        };

        // Call the management canister's http_request method with cycles
        let response : http_request_result = await (with cycles) http_request(request);

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

    /// Store tuner preset
    /// Stores the current tuner station as a preset
    public func storeTunerPreset(config : Config__, num : Nat) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/tuner/storePreset"
            # "?" # "num=" # Int.toText(num);

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

        let request : http_request_args = { config with
            url;
            method = #get;
            headers;
            body = null;
        };

        // Call the management canister's http_request method with cycles
        let response : http_request_result = await (with cycles) http_request(request);

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

    /// Switch tuner preset
    /// Switches to the next or previous tuner preset
    public func switchTunerPreset(config : Config__, dir : SwitchTunerPresetDirParameter) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/tuner/switchPreset"
            # "?" # "dir=" # SwitchTunerPresetDirParameter.toJSON(dir);

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

        let request : http_request_args = { config with
            url;
            method = #get;
            headers;
            body = null;
        };

        // Call the management canister's http_request method with cycles
        let response : http_request_result = await (with cycles) http_request(request);

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
        getTunerPlayInfo;
        getTunerPresetInfo;
        recallTunerPreset;
        setDabService;
        setTunerFreq;
        storeTunerPreset;
        switchTunerPreset;
    };

    public module class TunerApi(config : Config__) {
        /// Get tuner playing info
        /// Returns information about the currently playing tuner station
        public func getTunerPlayInfo() : async Any {
            await* operations__.getTunerPlayInfo(config)
        };

        /// Get tuner preset info
        /// Returns information about tuner presets
        public func getTunerPresetInfo(band : RecallTunerPresetBandParameter) : async Any {
            await* operations__.getTunerPresetInfo(config, band)
        };

        /// Recall tuner preset
        /// Recalls a saved tuner preset
        public func recallTunerPreset(zone : Text, band : RecallTunerPresetBandParameter, num : Nat) : async Any {
            await* operations__.recallTunerPreset(config, zone, band, num)
        };

        /// Change DAB service
        /// Switches to the next or previous DAB service
        public func setDabService(dir : SwitchTunerPresetDirParameter) : async Any {
            await* operations__.setDabService(config, dir)
        };

        /// Set tuner frequency
        /// Tunes to a specific frequency
        public func setTunerFreq(band : RecallTunerPresetBandParameter, tuning : SetTunerFreqTuningParameter, num : Nat) : async Any {
            await* operations__.setTunerFreq(config, band, tuning, num)
        };

        /// Store tuner preset
        /// Stores the current tuner station as a preset
        public func storeTunerPreset(num : Nat) : async Any {
            await* operations__.storeTunerPreset(config, num)
        };

        /// Switch tuner preset
        /// Switches to the next or previous tuner preset
        public func switchTunerPreset(dir : SwitchTunerPresetDirParameter) : async Any {
            await* operations__.switchTunerPreset(config, dir)
        };

    }
}
