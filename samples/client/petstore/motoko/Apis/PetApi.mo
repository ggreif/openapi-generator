// PetApi.mo

import Text "mo:core/Text";
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

    /// Add a new pet to the store
    /// 
    public func addPet(baseUrl : Text, pet : Pet) : async Pet {
        let url = baseUrl # "/pet";

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = ?Text.encodeUtf8(pet);
            method = #post;
            transform = null;
        };

        // Call the management canister's http_request method
        // Note: Requires cycles and proper canister configuration
        let response : CanisterHttpResponsePayload = await managementCanister.http_request(request);

        // TODO: Parse response.body and return Pet
        // For now, returning a placeholder
        throw Error.reject("Not implemented")
    };

    /// Deletes a pet
    /// 
    public func deletePet(baseUrl : Text, petId : Int, apiKey : Text) : async () {
        let url = baseUrl # "/pet/{petId}" # "/" # debug_show(petId);

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            headers = [
                { name = "Content-Type"; value = "application/json" },
                { name = "api_key"; value = apiKey }
            ];
            body = null;
            method = #delete;
            transform = null;
        };

        // Call the management canister's http_request method
        // Note: Requires cycles and proper canister configuration
        let response : CanisterHttpResponsePayload = await managementCanister.http_request(request);

    };

    /// Finds Pets by status
    /// Multiple status values can be provided with comma separated strings
    public func findPetsByStatus(baseUrl : Text, status : [Text]) : async [Pet] {
        let url = baseUrl # "/pet/findByStatus";

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

        // TODO: Parse response.body and return [Pet]
        // For now, returning a placeholder
        []
    };

    /// Finds Pets by tags
    /// Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing.
    public func findPetsByTags(baseUrl : Text, tags : [Text]) : async [Pet] {
        let url = baseUrl # "/pet/findByTags";

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

        // TODO: Parse response.body and return [Pet]
        // For now, returning a placeholder
        []
    };

    /// Find pet by ID
    /// Returns a single pet
    public func getPetById(baseUrl : Text, petId : Int) : async Pet {
        let url = baseUrl # "/pet/{petId}" # "/" # debug_show(petId);

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

        // TODO: Parse response.body and return Pet
        // For now, returning a placeholder
        throw Error.reject("Not implemented")
    };

    /// Update an existing pet
    /// 
    public func updatePet(baseUrl : Text, pet : Pet) : async Pet {
        let url = baseUrl # "/pet";

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = ?Text.encodeUtf8(pet);
            method = #put;
            transform = null;
        };

        // Call the management canister's http_request method
        // Note: Requires cycles and proper canister configuration
        let response : CanisterHttpResponsePayload = await managementCanister.http_request(request);

        // TODO: Parse response.body and return Pet
        // For now, returning a placeholder
        throw Error.reject("Not implemented")
    };

    /// Updates a pet in the store with form data
    /// 
    public func updatePetWithForm(baseUrl : Text, petId : Int, name : Text, status : Text) : async () {
        let url = baseUrl # "/pet/{petId}" # "/" # debug_show(petId);

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = null;
            method = #post;
            transform = null;
        };

        // Call the management canister's http_request method
        // Note: Requires cycles and proper canister configuration
        let response : CanisterHttpResponsePayload = await managementCanister.http_request(request);

    };

    /// uploads an image
    /// 
    public func uploadFile(baseUrl : Text, petId : Int, additionalMetadata : Text, file : Blob) : async ApiResponse {
        let url = baseUrl # "/pet/{petId}/uploadImage" # "/" # debug_show(petId);

        let request : CanisterHttpRequestArgument = {
            url = url;
            max_response_bytes = null;
            headers = [
                { name = "Content-Type"; value = "application/json" }
            ];
            body = null;
            method = #post;
            transform = null;
        };

        // Call the management canister's http_request method
        // Note: Requires cycles and proper canister configuration
        let response : CanisterHttpResponsePayload = await managementCanister.http_request(request);

        // TODO: Parse response.body and return ApiResponse
        // For now, returning a placeholder
        throw Error.reject("Not implemented")
    };

}
