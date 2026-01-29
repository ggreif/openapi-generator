// PetApi.mo

import Text "mo:core/Text";
import Int "mo:core/Int";
import Error "mo:core/Error";
import { JSON } "mo:serde";
import { type ApiResponse } "../Models/ApiResponse";
import { type Pet } "../Models/Pet";

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

    /// Add a new pet to the store
    /// 
    public func addPet(baseUrl : Text, pet : Pet) : async Pet {
        let url = baseUrl # "/pet";

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            method = #post;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = do ? { let candidBlob = to_candid(pet); let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON"); Text.encodeUtf8(jsonText) };
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

        let result : ?Pet = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to Pet");
        }
    };

    /// Deletes a pet
    /// 
    public func deletePet(baseUrl : Text, petId : Int, apiKey : Text) : async () {
        let url = baseUrl # "/pet/{petId}"
            |> Text.replace(_, #text "{petId}", debug_show(petId));

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            method = #delete;
            headers = [
                { name = "Content-Type"; value = "application/json" },
                { name = "api_key"; value = apiKey }
            ];
            body = null;
            transform = null;
            is_replicated = null;
        };

        // Call the management canister's http_request method with cycles
        // 30M cycles should be sufficient for most requests
        ignore await (with cycles = 30_000_000_000) http_request(request);

    };

    /// Finds Pets by status
    /// Multiple status values can be provided with comma separated strings
    public func findPetsByStatus(baseUrl : Text, status : [Text]) : async [Pet] {
        let url = baseUrl # "/pet/findByStatus";

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

        let result : ?[Pet] = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to [Pet]");
        }
    };

    /// Finds Pets by tags
    /// Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing.
    public func findPetsByTags(baseUrl : Text, tags : [Text]) : async [Pet] {
        let url = baseUrl # "/pet/findByTags";

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

        let result : ?[Pet] = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to [Pet]");
        }
    };

    /// Find pet by ID
    /// Returns a single pet
    public func getPetById(baseUrl : Text, petId : Int) : async Pet {
        let url = baseUrl # "/pet/{petId}"
            |> Text.replace(_, #text "{petId}", debug_show(petId));

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

        let result : ?Pet = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to Pet");
        }
    };

    /// Update an existing pet
    /// 
    public func updatePet(baseUrl : Text, pet : Pet) : async Pet {
        let url = baseUrl # "/pet";

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            method = #put;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = do ? { let candidBlob = to_candid(pet); let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON"); Text.encodeUtf8(jsonText) };
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

        let result : ?Pet = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to Pet");
        }
    };

    /// Updates a pet in the store with form data
    /// 
    public func updatePetWithForm(baseUrl : Text, petId : Int, name : Text, status : Text) : async () {
        let url = baseUrl # "/pet/{petId}"
            |> Text.replace(_, #text "{petId}", debug_show(petId));

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            method = #post;
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

    /// uploads an image
    /// 
    public func uploadFile(baseUrl : Text, petId : Int, additionalMetadata : Text, file : Blob) : async ApiResponse {
        let url = baseUrl # "/pet/{petId}/uploadImage"
            |> Text.replace(_, #text "{petId}", debug_show(petId));

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            method = #post;
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

        let result : ?ApiResponse = from_candid(jsonBlob);
        switch (result) {
            case (?value) value;
            case null throw Error.reject("Failed to deserialize response to ApiResponse");
        }
    };

}
