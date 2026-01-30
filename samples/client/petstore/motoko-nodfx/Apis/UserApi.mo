// UserApi.mo

import Text "mo:core/Text";
import Int "mo:core/Int";
import Array "mo:core/Array";
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
    /// Create user
    /// This can only be done by the logged in user.
    public func createUser(config : Config__, user : User) : async* () {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/user";

        let baseHeaders = [
            { name = "Content-Type"; value = "application/json" }
        ];

        // Add Authorization header if access token is provided
        let headers = switch (accessToken) {
            case (?token) {
                Array.flatten([baseHeaders, [{ name = "Authorization"; value = "Bearer " # token }]]);
            };
            case null { baseHeaders };
        };

        let request : CanisterHttpRequestArgument = { config with
            url;
            method = #post;
            headers;
            body = do ? { let candidBlob = to_candid(user); let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON"); Text.encodeUtf8(jsonText) };
        };

        // Call the management canister's http_request method with cycles
        ignore await (with cycles) http_request(request);

    };

    /// Creates list of users with given input array
    /// 
    public func createUsersWithArrayInput(config : Config__, user : [User]) : async* () {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/user/createWithArray";

        let baseHeaders = [
            { name = "Content-Type"; value = "application/json" }
        ];

        // Add Authorization header if access token is provided
        let headers = switch (accessToken) {
            case (?token) {
                Array.flatten([baseHeaders, [{ name = "Authorization"; value = "Bearer " # token }]]);
            };
            case null { baseHeaders };
        };

        let request : CanisterHttpRequestArgument = { config with
            url;
            method = #post;
            headers;
            body = do ? { let candidBlob = to_candid(user); let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON"); Text.encodeUtf8(jsonText) };
        };

        // Call the management canister's http_request method with cycles
        ignore await (with cycles) http_request(request);

    };

    /// Creates list of users with given input array
    /// 
    public func createUsersWithListInput(config : Config__, user : [User]) : async* () {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/user/createWithList";

        let baseHeaders = [
            { name = "Content-Type"; value = "application/json" }
        ];

        // Add Authorization header if access token is provided
        let headers = switch (accessToken) {
            case (?token) {
                Array.flatten([baseHeaders, [{ name = "Authorization"; value = "Bearer " # token }]]);
            };
            case null { baseHeaders };
        };

        let request : CanisterHttpRequestArgument = { config with
            url;
            method = #post;
            headers;
            body = do ? { let candidBlob = to_candid(user); let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON"); Text.encodeUtf8(jsonText) };
        };

        // Call the management canister's http_request method with cycles
        ignore await (with cycles) http_request(request);

    };

    /// Delete user
    /// This can only be done by the logged in user.
    public func deleteUser(config : Config__, username : Text) : async* () {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/user/{username}"
            |> Text.replace(_, #text "{username}", username);

        let baseHeaders = [
            { name = "Content-Type"; value = "application/json" }
        ];

        // Add Authorization header if access token is provided
        let headers = switch (accessToken) {
            case (?token) {
                Array.flatten([baseHeaders, [{ name = "Authorization"; value = "Bearer " # token }]]);
            };
            case null { baseHeaders };
        };

        let request : CanisterHttpRequestArgument = { config with
            url;
            method = #delete;
            headers;
            body = null;
        };

        // Call the management canister's http_request method with cycles
        ignore await (with cycles) http_request(request);

    };

    /// Get user by user name
    /// 
    public func getUserByName(config : Config__, username : Text) : async* User {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/user/{username}"
            |> Text.replace(_, #text "{username}", username);

        let baseHeaders = [
            { name = "Content-Type"; value = "application/json" }
        ];

        // Add Authorization header if access token is provided
        let headers = switch (accessToken) {
            case (?token) {
                Array.flatten([baseHeaders, [{ name = "Authorization"; value = "Bearer " # token }]]);
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
        let response : CanisterHttpResponsePayload = await (with cycles) http_request(request);

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
    public func loginUser(config : Config__, username : Text, password : Text) : async* Text {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/user/login";

        let baseHeaders = [
            { name = "Content-Type"; value = "application/json" }
        ];

        // Add Authorization header if access token is provided
        let headers = switch (accessToken) {
            case (?token) {
                Array.flatten([baseHeaders, [{ name = "Authorization"; value = "Bearer " # token }]]);
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
        let response : CanisterHttpResponsePayload = await (with cycles) http_request(request);

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
    public func logoutUser(config : Config__) : async* () {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/user/logout";

        let baseHeaders = [
            { name = "Content-Type"; value = "application/json" }
        ];

        // Add Authorization header if access token is provided
        let headers = switch (accessToken) {
            case (?token) {
                Array.flatten([baseHeaders, [{ name = "Authorization"; value = "Bearer " # token }]]);
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
        ignore await (with cycles) http_request(request);

    };

    /// Updated user
    /// This can only be done by the logged in user.
    public func updateUser(config : Config__, username : Text, user : User) : async* () {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/user/{username}"
            |> Text.replace(_, #text "{username}", username);

        let baseHeaders = [
            { name = "Content-Type"; value = "application/json" }
        ];

        // Add Authorization header if access token is provided
        let headers = switch (accessToken) {
            case (?token) {
                Array.flatten([baseHeaders, [{ name = "Authorization"; value = "Bearer " # token }]]);
            };
            case null { baseHeaders };
        };

        let request : CanisterHttpRequestArgument = { config with
            url;
            method = #put;
            headers;
            body = do ? { let candidBlob = to_candid(user); let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON"); Text.encodeUtf8(jsonText) };
        };

        // Call the management canister's http_request method with cycles
        ignore await (with cycles) http_request(request);

    };


    let operations__ = {
        createUser;
        createUsersWithArrayInput;
        createUsersWithListInput;
        deleteUser;
        getUserByName;
        loginUser;
        logoutUser;
        updateUser;
    };

    public module class UserApi(config : Config__) {
        /// Create user
        /// This can only be done by the logged in user.
        public func createUser(user : User) : async () {
            await* operations__.createUser(config, user)
        };

        /// Creates list of users with given input array
        /// 
        public func createUsersWithArrayInput(user : [User]) : async () {
            await* operations__.createUsersWithArrayInput(config, user)
        };

        /// Creates list of users with given input array
        /// 
        public func createUsersWithListInput(user : [User]) : async () {
            await* operations__.createUsersWithListInput(config, user)
        };

        /// Delete user
        /// This can only be done by the logged in user.
        public func deleteUser(username : Text) : async () {
            await* operations__.deleteUser(config, username)
        };

        /// Get user by user name
        /// 
        public func getUserByName(username : Text) : async User {
            await* operations__.getUserByName(config, username)
        };

        /// Logs user into the system
        /// 
        public func loginUser(username : Text, password : Text) : async Text {
            await* operations__.loginUser(config, username, password)
        };

        /// Logs out current logged in user session
        /// 
        public func logoutUser() : async () {
            await* operations__.logoutUser(config)
        };

        /// Updated user
        /// This can only be done by the logged in user.
        public func updateUser(username : Text, user : User) : async () {
            await* operations__.updateUser(config, username, user)
        };

    }
}
