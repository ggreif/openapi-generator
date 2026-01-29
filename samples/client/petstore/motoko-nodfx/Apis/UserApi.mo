// UserApi.mo

import Text "mo:core/Text";
import Int "mo:core/Int";
import Error "mo:core/Error";
import { JSON } "mo:serde";
import { type User } "../Models/User";

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

    /// Create user
    /// This can only be done by the logged in user.
    public func createUser(baseUrl : Text, user : User) : async () {
        let url = baseUrl # "/user";

        let request : CanisterHttpRequestArgument = {
            url;
            max_response_bytes = null;
            method = #post;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = do ? { let candidBlob = to_candid(user); let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON"); Text.encodeUtf8(jsonText) };
            transform = null;
            is_replicated = null;
        };

        // Call the management canister's http_request method with cycles
        // 30M cycles should be sufficient for most requests
        ignore await (with cycles = 30_000_000_000) http_request(request);

    };

    /// Creates list of users with given input array
    /// 
    public func createUsersWithArrayInput(baseUrl : Text, user : [User]) : async () {
        let url = baseUrl # "/user/createWithArray";

        let request : CanisterHttpRequestArgument = {
            url;
            max_response_bytes = null;
            method = #post;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = do ? { let candidBlob = to_candid(user); let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON"); Text.encodeUtf8(jsonText) };
            transform = null;
            is_replicated = null;
        };

        // Call the management canister's http_request method with cycles
        // 30M cycles should be sufficient for most requests
        ignore await (with cycles = 30_000_000_000) http_request(request);

    };

    /// Creates list of users with given input array
    /// 
    public func createUsersWithListInput(baseUrl : Text, user : [User]) : async () {
        let url = baseUrl # "/user/createWithList";

        let request : CanisterHttpRequestArgument = {
            url;
            max_response_bytes = null;
            method = #post;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = do ? { let candidBlob = to_candid(user); let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON"); Text.encodeUtf8(jsonText) };
            transform = null;
            is_replicated = null;
        };

        // Call the management canister's http_request method with cycles
        // 30M cycles should be sufficient for most requests
        ignore await (with cycles = 30_000_000_000) http_request(request);

    };

    /// Delete user
    /// This can only be done by the logged in user.
    public func deleteUser(baseUrl : Text, username : Text) : async () {
        let url = baseUrl # "/user/{username}"
            |> Text.replace(_, #text "{username}", username);

        let request : CanisterHttpRequestArgument = {
            url;
            max_response_bytes = null;
            method = #delete;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = null;
            transform = null;
            is_replicated = null;
        };

        // Call the management canister's http_request method with cycles
        // 30M cycles should be sufficient for most requests
        ignore await (with cycles = 30_000_000_000) http_request(request);

    };

    /// Get user by user name
    /// 
    public func getUserByName(baseUrl : Text, username : Text) : async User {
        let url = baseUrl # "/user/{username}"
            |> Text.replace(_, #text "{username}", username);

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

        let result : ?User = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to User");
        }
    };

    /// Logs user into the system
    /// 
    public func loginUser(baseUrl : Text, username : Text, password : Text) : async Text {
        let url = baseUrl # "/user/login";

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

        let result : ?Text = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to Text");
        }
    };

    /// Logs out current logged in user session
    /// 
    public func logoutUser(baseUrl : Text) : async () {
        let url = baseUrl # "/user/logout";

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
        ignore await (with cycles = 30_000_000_000) http_request(request);

    };

    /// Updated user
    /// This can only be done by the logged in user.
    public func updateUser(baseUrl : Text, username : Text, user : User) : async () {
        let url = baseUrl # "/user/{username}"
            |> Text.replace(_, #text "{username}", username);

        let request : CanisterHttpRequestArgument = {
            url;
            max_response_bytes = null;
            method = #put;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = do ? { let candidBlob = to_candid(user); let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON"); Text.encodeUtf8(jsonText) };
            transform = null;
            is_replicated = null;
        };

        // Call the management canister's http_request method with cycles
        // 30M cycles should be sufficient for most requests
        ignore await (with cycles = 30_000_000_000) http_request(request);

    };

}
