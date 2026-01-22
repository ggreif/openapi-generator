// StoreApi.mo

import Text "mo:core/Text";
import Error "mo:core/Error";
import { type Order } "../Models/Order";
import Map "mo:core/pure/Map";

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
        headers : [HttpHeader];
        body : ?Blob;
        method : HttpMethod;
        transform : ?{
            function : shared query ({ response : CanisterHttpResponsePayload; context : Blob }) -> async CanisterHttpResponsePayload;
            context : Blob;
        };
    };

    type CanisterHttpResponsePayload = {
        status : Nat;
        headers : [HttpHeader];
        body : Blob;
    };

    let managementCanister = actor "aaaaa-aa" : actor {
        http_request : (CanisterHttpRequestArgument) -> async CanisterHttpResponsePayload;
    };

    /// Delete purchase order by ID
    /// For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors
    public func deleteOrder(baseUrl : Text, orderId : Text) : async () {
        let url = baseUrl # "/store/order/{orderId}" # "/" # orderId;

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
        let response : CanisterHttpResponsePayload = await managementCanister.http_request(request);

    };

    /// Returns pet inventories by status
    /// Returns a map of status codes to quantities
    public func getInventory(baseUrl : Text) : async Map.Map<Text, Int> {
        let url = baseUrl # "/store/inventory";

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
        let response : CanisterHttpResponsePayload = await managementCanister.http_request(request);

        // TODO: Parse response.body and return Map.Map<Text, Int>
        // For now, returning a placeholder
        throw Error.reject("Not implemented")
    };

    /// Find purchase order by ID
    /// For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions
    public func getOrderById(baseUrl : Text, orderId : Int) : async Order {
        let url = baseUrl # "/store/order/{orderId}" # "/" # debug_show(orderId);

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
        let response : CanisterHttpResponsePayload = await managementCanister.http_request(request);

        // TODO: Parse response.body and return Order
        // For now, returning a placeholder
        throw Error.reject("Not implemented")
    };

    /// Place an order for a pet
    /// 
    public func placeOrder(baseUrl : Text, order : Order) : async Order {
        let url = baseUrl # "/store/order";

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = ?Text.encodeUtf8(order);
            method = #post;
            transform = null;
        };

        // Call the management canister's http_request method
        // Note: Requires cycles and proper canister configuration
        let response : CanisterHttpResponsePayload = await managementCanister.http_request(request);

        // TODO: Parse response.body and return Order
        // For now, returning a placeholder
        throw Error.reject("Not implemented")
    };

}
