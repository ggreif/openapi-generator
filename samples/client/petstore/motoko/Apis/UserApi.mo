// UserApi.mo

import { type CanisterHttpRequestArgument; type CanisterHttpResponsePayload; type HttpMethod; type HttpHeader; http_request } "ic:aaaaa-aa";
import Text "mo:core/Text";
import { type User } "../Models/User";

module {
    /// Create user
    /// This can only be done by the logged in user.
    public func createUser(baseUrl : Text, user : User) : async () {
        let url = baseUrl # "/user";

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = ?Text.encodeUtf8(user);
            method = #post;
            transform = null;
        };

        // Call the management canister's http_request method
        // Note: Requires cycles and proper canister configuration
        let response : CanisterHttpResponsePayload = await http_request(request);

    };

    /// Creates list of users with given input array
    /// 
    public func createUsersWithArrayInput(baseUrl : Text, user : [User]) : async () {
        let url = baseUrl # "/user/createWithArray";

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = ?Text.encodeUtf8(user);
            method = #post;
            transform = null;
        };

        // Call the management canister's http_request method
        // Note: Requires cycles and proper canister configuration
        let response : CanisterHttpResponsePayload = await http_request(request);

    };

    /// Creates list of users with given input array
    /// 
    public func createUsersWithListInput(baseUrl : Text, user : [User]) : async () {
        let url = baseUrl # "/user/createWithList";

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = ?Text.encodeUtf8(user);
            method = #post;
            transform = null;
        };

        // Call the management canister's http_request method
        // Note: Requires cycles and proper canister configuration
        let response : CanisterHttpResponsePayload = await http_request(request);

    };

    /// Delete user
    /// This can only be done by the logged in user.
    public func deleteUser(baseUrl : Text, username : Text) : async () {
        let url = baseUrl # "/user/{username}" # "/" # username;

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = null;
            method = #delete;
            transform = null;
        };

        // Call the management canister's http_request method
        // Note: Requires cycles and proper canister configuration
        let response : CanisterHttpResponsePayload = await http_request(request);

    };

    /// Get user by user name
    /// 
    public func getUserByName(baseUrl : Text, username : Text) : async User {
        let url = baseUrl # "/user/{username}" # "/" # username;

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = null;
            method = #get;
            transform = null;
        };

        // Call the management canister's http_request method
        // Note: Requires cycles and proper canister configuration
        let response : CanisterHttpResponsePayload = await http_request(request);

        // TODO: Parse response.body and return User
        // For now, returning a placeholder
        throw Error.reject("Not implemented")
    };

    /// Logs user into the system
    /// 
    public func loginUser(baseUrl : Text, username : Text, password : Text) : async Text {
        let url = baseUrl # "/user/login";

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = null;
            method = #get;
            transform = null;
        };

        // Call the management canister's http_request method
        // Note: Requires cycles and proper canister configuration
        let response : CanisterHttpResponsePayload = await http_request(request);

        // TODO: Parse response.body and return Text
        // For now, returning a placeholder
        throw Error.reject("Not implemented")
    };

    /// Logs out current logged in user session
    /// 
    public func logoutUser(baseUrl : Text) : async () {
        let url = baseUrl # "/user/logout";

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = null;
            method = #get;
            transform = null;
        };

        // Call the management canister's http_request method
        // Note: Requires cycles and proper canister configuration
        let response : CanisterHttpResponsePayload = await http_request(request);

    };

    /// Updated user
    /// This can only be done by the logged in user.
    public func updateUser(baseUrl : Text, username : Text, user : User) : async () {
        let url = baseUrl # "/user/{username}" # "/" # username;

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = ?Text.encodeUtf8(user);
            method = #put;
            transform = null;
        };

        // Call the management canister's http_request method
        // Note: Requires cycles and proper canister configuration
        let response : CanisterHttpResponsePayload = await http_request(request);

    };

}
