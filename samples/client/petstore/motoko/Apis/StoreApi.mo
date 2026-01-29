// StoreApi.mo

import Text "mo:core/Text";
import Int "mo:core/Int";
import Error "mo:core/Error";
import { JSON } "mo:serde";
import { type CanisterHttpRequestArgument; type CanisterHttpResponsePayload; type HttpMethod; type HttpHeader; http_request } "ic:aaaaa-aa";
import { type Order } "../Models/Order";
import { type Map } "mo:core/pure/Map";

module {
    /// Delete purchase order by ID
    /// For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors
    public func deleteOrder(baseUrl : Text, orderId : Text) : async () {
        let url = baseUrl # "/store/order/{orderId}"
            |> Text.replace(_, #text "{orderId}", orderId);

        let request : CanisterHttpRequestArgument = {
            url = url;
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

    /// Returns pet inventories by status
    /// Returns a map of status codes to quantities
    public func getInventory(baseUrl : Text) : async Map<Text, Int> {
        let url = baseUrl # "/store/inventory";

        let request : CanisterHttpRequestArgument = {
            url = url;
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

        let result : ?Map<Text, Int> = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to Map<Text, Int>");
        }
    };

    /// Find purchase order by ID
    /// For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions
    public func getOrderById(baseUrl : Text, orderId : Int) : async Order {
        let url = baseUrl # "/store/order/{orderId}"
            |> Text.replace(_, #text "{orderId}", debug_show(orderId));

        let request : CanisterHttpRequestArgument = {
            url = url;
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

        let result : ?Order = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to Order");
        }
    };

    /// Place an order for a pet
    /// 
    public func placeOrder(baseUrl : Text, order : Order) : async Order {
        let url = baseUrl # "/store/order";

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            method = #post;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = do ? { let candidBlob = to_candid(order); let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON"); Text.encodeUtf8(jsonText) };
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

        let result : ?Order = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to Order");
        }
    };

}
