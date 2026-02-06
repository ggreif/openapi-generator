// PowerApi.mo

import Text "mo:core/Text";
import Int "mo:core/Int";
import Array "mo:core/Array";
import Error "mo:core/Error";
import { JSON } "mo:serde";
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

    /// Enable or disable auto power standby
    /// Sets the auto power standby feature on or off
    public func setAutoPowerStandby(config : Config__, enable : Bool) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/system/setAutoPowerStandby"
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

    /// Set power status
    /// Turn the zone on, put it in standby, or toggle power
    public func setPower(config : Config__, zone : Text, power : Text) : async* Any {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/{zone}/setPower"
            |> Text.replace(_, #text "{zone}", zone)
            # "?" # "power=" # power;

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
        setAutoPowerStandby;
        setPower;
    };

    public module class PowerApi(config : Config__) {
        /// Enable or disable auto power standby
        /// Sets the auto power standby feature on or off
        public func setAutoPowerStandby(enable : Bool) : async Any {
            await* operations__.setAutoPowerStandby(config, enable)
        };

        /// Set power status
        /// Turn the zone on, put it in standby, or toggle power
        public func setPower(zone : Text, power : Text) : async Any {
            await* operations__.setPower(config, zone, power)
        };

    }
}
