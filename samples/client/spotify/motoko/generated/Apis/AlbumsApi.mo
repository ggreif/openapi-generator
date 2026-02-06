// AlbumsApi.mo

import Text "mo:core/Text";
import Int "mo:core/Int";
import Array "mo:core/Array";
import Error "mo:core/Error";
import { JSON } "mo:serde";
import { type AlbumObject; JSON = AlbumObject } "../Models/AlbumObject";
import { type GetAnAlbum401Response; JSON = GetAnAlbum401Response } "../Models/GetAnAlbum401Response";
import { type GetMultipleAlbums200Response; JSON = GetMultipleAlbums200Response } "../Models/GetMultipleAlbums200Response";
import { type GetNewReleases200Response; JSON = GetNewReleases200Response } "../Models/GetNewReleases200Response";
import { type PagingArtistDiscographyAlbumObject; JSON = PagingArtistDiscographyAlbumObject } "../Models/PagingArtistDiscographyAlbumObject";
import { type PagingSavedAlbumObject; JSON = PagingSavedAlbumObject } "../Models/PagingSavedAlbumObject";
import { type PagingSimplifiedTrackObject; JSON = PagingSimplifiedTrackObject } "../Models/PagingSimplifiedTrackObject";
import { type SaveAlbumsUserRequest; JSON = SaveAlbumsUserRequest } "../Models/SaveAlbumsUserRequest";

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

    /// Check User's Saved Albums 
    /// Check if one or more albums is already saved in the current Spotify user's 'Your Music' library. 
    public func checkUsersSavedAlbums(config : Config__, ids : Text) : async* [Bool] {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/me/albums/contains"
            # "?" # "ids=" # ids;

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
        let response : CanisterHttpResponsePayload = await (with cycles) http_request(request);

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
            from_candid(_) : ?[Bool] |>
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

            // Try parsing 401 response as GetAnAlbum401Response
            if (response.status == 401) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 401: Bad or expired token. This can happen if the user revoked a token or the access token has expired. You should re-authenticate the user. " # errorDetail);
            };
            // Try parsing 403 response as GetAnAlbum401Response
            if (response.status == 403) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 403: Bad OAuth request (wrong consumer key, bad nonce, expired timestamp...). Unfortunately, re-authenticating the user won&#39;t help here. " # errorDetail);
            };
            // Try parsing 429 response as GetAnAlbum401Response
            if (response.status == 429) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 429: The app has exceeded its rate limits. " # errorDetail);
            };

            // Fallback for status codes not defined in OpenAPI spec
            throw Error.reject("HTTP " # Int.toText(response.status) # ": Unexpected error" #
                (if (responseText != "") { " - " # responseText } else { "" }));
        }
    };

    /// Get Album 
    /// Get Spotify catalog information for a single album. 
    public func getAnAlbum(config : Config__, id : Text, market : Text) : async* AlbumObject {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/albums/{id}"
            |> Text.replace(_, #text "{id}", id)
            # "?" # "market=" # market;

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
        let response : CanisterHttpResponsePayload = await (with cycles) http_request(request);

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
            from_candid(_) : ?AlbumObject.JSON |>
            (switch (_) {
                case (?jsonValue) {
                    switch (AlbumObject.fromJSON(jsonValue)) {
                        case (?value) value;
                        case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to convert response to AlbumObject");
                    }
                };
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to deserialize response");
            })
        } else {
            // Error response (4xx, 5xx): parse error models and throw
            let responseText = switch (Text.decodeUtf8(response.body)) {
                case (?text) text;
                case null "";  // Empty body for some errors (e.g., 404)
            };

            // Try parsing 401 response as GetAnAlbum401Response
            if (response.status == 401) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 401: Bad or expired token. This can happen if the user revoked a token or the access token has expired. You should re-authenticate the user. " # errorDetail);
            };
            // Try parsing 403 response as GetAnAlbum401Response
            if (response.status == 403) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 403: Bad OAuth request (wrong consumer key, bad nonce, expired timestamp...). Unfortunately, re-authenticating the user won&#39;t help here. " # errorDetail);
            };
            // Try parsing 429 response as GetAnAlbum401Response
            if (response.status == 429) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 429: The app has exceeded its rate limits. " # errorDetail);
            };

            // Fallback for status codes not defined in OpenAPI spec
            throw Error.reject("HTTP " # Int.toText(response.status) # ": Unexpected error" #
                (if (responseText != "") { " - " # responseText } else { "" }));
        }
    };

    /// Get Album Tracks 
    /// Get Spotify catalog information about an album’s tracks. Optional parameters can be used to limit the number of tracks returned. 
    public func getAnAlbumsTracks(config : Config__, id : Text, market : Text, limit : Int, offset : Int) : async* PagingSimplifiedTrackObject {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/albums/{id}/tracks"
            |> Text.replace(_, #text "{id}", id)
            # "?" # "market=" # market # "&" # "limit=" # Int.toText(limit) # "&" # "offset=" # Int.toText(offset);

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
        let response : CanisterHttpResponsePayload = await (with cycles) http_request(request);

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
            from_candid(_) : ?PagingSimplifiedTrackObject.JSON |>
            (switch (_) {
                case (?jsonValue) {
                    switch (PagingSimplifiedTrackObject.fromJSON(jsonValue)) {
                        case (?value) value;
                        case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to convert response to PagingSimplifiedTrackObject");
                    }
                };
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to deserialize response");
            })
        } else {
            // Error response (4xx, 5xx): parse error models and throw
            let responseText = switch (Text.decodeUtf8(response.body)) {
                case (?text) text;
                case null "";  // Empty body for some errors (e.g., 404)
            };

            // Try parsing 401 response as GetAnAlbum401Response
            if (response.status == 401) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 401: Bad or expired token. This can happen if the user revoked a token or the access token has expired. You should re-authenticate the user. " # errorDetail);
            };
            // Try parsing 403 response as GetAnAlbum401Response
            if (response.status == 403) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 403: Bad OAuth request (wrong consumer key, bad nonce, expired timestamp...). Unfortunately, re-authenticating the user won&#39;t help here. " # errorDetail);
            };
            // Try parsing 429 response as GetAnAlbum401Response
            if (response.status == 429) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 429: The app has exceeded its rate limits. " # errorDetail);
            };

            // Fallback for status codes not defined in OpenAPI spec
            throw Error.reject("HTTP " # Int.toText(response.status) # ": Unexpected error" #
                (if (responseText != "") { " - " # responseText } else { "" }));
        }
    };

    /// Get Artist's Albums 
    /// Get Spotify catalog information about an artist's albums. 
    public func getAnArtistsAlbums(config : Config__, id : Text, includeGroups : Text, market : Text, limit : Int, offset : Int) : async* PagingArtistDiscographyAlbumObject {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/artists/{id}/albums"
            |> Text.replace(_, #text "{id}", id)
            # "?" # "include_groups=" # includeGroups # "&" # "market=" # market # "&" # "limit=" # Int.toText(limit) # "&" # "offset=" # Int.toText(offset);

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
        let response : CanisterHttpResponsePayload = await (with cycles) http_request(request);

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
            from_candid(_) : ?PagingArtistDiscographyAlbumObject.JSON |>
            (switch (_) {
                case (?jsonValue) {
                    switch (PagingArtistDiscographyAlbumObject.fromJSON(jsonValue)) {
                        case (?value) value;
                        case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to convert response to PagingArtistDiscographyAlbumObject");
                    }
                };
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to deserialize response");
            })
        } else {
            // Error response (4xx, 5xx): parse error models and throw
            let responseText = switch (Text.decodeUtf8(response.body)) {
                case (?text) text;
                case null "";  // Empty body for some errors (e.g., 404)
            };

            // Try parsing 401 response as GetAnAlbum401Response
            if (response.status == 401) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 401: Bad or expired token. This can happen if the user revoked a token or the access token has expired. You should re-authenticate the user. " # errorDetail);
            };
            // Try parsing 403 response as GetAnAlbum401Response
            if (response.status == 403) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 403: Bad OAuth request (wrong consumer key, bad nonce, expired timestamp...). Unfortunately, re-authenticating the user won&#39;t help here. " # errorDetail);
            };
            // Try parsing 429 response as GetAnAlbum401Response
            if (response.status == 429) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 429: The app has exceeded its rate limits. " # errorDetail);
            };

            // Fallback for status codes not defined in OpenAPI spec
            throw Error.reject("HTTP " # Int.toText(response.status) # ": Unexpected error" #
                (if (responseText != "") { " - " # responseText } else { "" }));
        }
    };

    /// Get Several Albums 
    /// Get Spotify catalog information for multiple albums identified by their Spotify IDs. 
    public func getMultipleAlbums(config : Config__, ids : Text, market : Text) : async* GetMultipleAlbums200Response {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/albums"
            # "?" # "ids=" # ids # "&" # "market=" # market;

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
        let response : CanisterHttpResponsePayload = await (with cycles) http_request(request);

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
            from_candid(_) : ?GetMultipleAlbums200Response.JSON |>
            (switch (_) {
                case (?jsonValue) {
                    switch (GetMultipleAlbums200Response.fromJSON(jsonValue)) {
                        case (?value) value;
                        case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to convert response to GetMultipleAlbums200Response");
                    }
                };
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to deserialize response");
            })
        } else {
            // Error response (4xx, 5xx): parse error models and throw
            let responseText = switch (Text.decodeUtf8(response.body)) {
                case (?text) text;
                case null "";  // Empty body for some errors (e.g., 404)
            };

            // Try parsing 401 response as GetAnAlbum401Response
            if (response.status == 401) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 401: Bad or expired token. This can happen if the user revoked a token or the access token has expired. You should re-authenticate the user. " # errorDetail);
            };
            // Try parsing 403 response as GetAnAlbum401Response
            if (response.status == 403) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 403: Bad OAuth request (wrong consumer key, bad nonce, expired timestamp...). Unfortunately, re-authenticating the user won&#39;t help here. " # errorDetail);
            };
            // Try parsing 429 response as GetAnAlbum401Response
            if (response.status == 429) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 429: The app has exceeded its rate limits. " # errorDetail);
            };

            // Fallback for status codes not defined in OpenAPI spec
            throw Error.reject("HTTP " # Int.toText(response.status) # ": Unexpected error" #
                (if (responseText != "") { " - " # responseText } else { "" }));
        }
    };

    /// Get New Releases 
    /// Get a list of new album releases featured in Spotify (shown, for example, on a Spotify player’s “Browse” tab). 
    public func getNewReleases(config : Config__, limit : Int, offset : Int) : async* GetNewReleases200Response {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/browse/new-releases"
            # "?" # "limit=" # Int.toText(limit) # "&" # "offset=" # Int.toText(offset);

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
        let response : CanisterHttpResponsePayload = await (with cycles) http_request(request);

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
            from_candid(_) : ?GetNewReleases200Response.JSON |>
            (switch (_) {
                case (?jsonValue) {
                    switch (GetNewReleases200Response.fromJSON(jsonValue)) {
                        case (?value) value;
                        case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to convert response to GetNewReleases200Response");
                    }
                };
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to deserialize response");
            })
        } else {
            // Error response (4xx, 5xx): parse error models and throw
            let responseText = switch (Text.decodeUtf8(response.body)) {
                case (?text) text;
                case null "";  // Empty body for some errors (e.g., 404)
            };

            // Try parsing 401 response as GetAnAlbum401Response
            if (response.status == 401) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 401: Bad or expired token. This can happen if the user revoked a token or the access token has expired. You should re-authenticate the user. " # errorDetail);
            };
            // Try parsing 403 response as GetAnAlbum401Response
            if (response.status == 403) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 403: Bad OAuth request (wrong consumer key, bad nonce, expired timestamp...). Unfortunately, re-authenticating the user won&#39;t help here. " # errorDetail);
            };
            // Try parsing 429 response as GetAnAlbum401Response
            if (response.status == 429) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 429: The app has exceeded its rate limits. " # errorDetail);
            };

            // Fallback for status codes not defined in OpenAPI spec
            throw Error.reject("HTTP " # Int.toText(response.status) # ": Unexpected error" #
                (if (responseText != "") { " - " # responseText } else { "" }));
        }
    };

    /// Get User's Saved Albums 
    /// Get a list of the albums saved in the current Spotify user's 'Your Music' library. 
    public func getUsersSavedAlbums(config : Config__, limit : Int, offset : Int, market : Text) : async* PagingSavedAlbumObject {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/me/albums"
            # "?" # "limit=" # Int.toText(limit) # "&" # "offset=" # Int.toText(offset) # "&" # "market=" # market;

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
        let response : CanisterHttpResponsePayload = await (with cycles) http_request(request);

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
            from_candid(_) : ?PagingSavedAlbumObject.JSON |>
            (switch (_) {
                case (?jsonValue) {
                    switch (PagingSavedAlbumObject.fromJSON(jsonValue)) {
                        case (?value) value;
                        case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to convert response to PagingSavedAlbumObject");
                    }
                };
                case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to deserialize response");
            })
        } else {
            // Error response (4xx, 5xx): parse error models and throw
            let responseText = switch (Text.decodeUtf8(response.body)) {
                case (?text) text;
                case null "";  // Empty body for some errors (e.g., 404)
            };

            // Try parsing 401 response as GetAnAlbum401Response
            if (response.status == 401) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 401: Bad or expired token. This can happen if the user revoked a token or the access token has expired. You should re-authenticate the user. " # errorDetail);
            };
            // Try parsing 403 response as GetAnAlbum401Response
            if (response.status == 403) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 403: Bad OAuth request (wrong consumer key, bad nonce, expired timestamp...). Unfortunately, re-authenticating the user won&#39;t help here. " # errorDetail);
            };
            // Try parsing 429 response as GetAnAlbum401Response
            if (response.status == 429) {
                let errorDetail = if (responseText != "") {
                    switch (JSON.fromText(responseText, null)) {
                        case (#ok(blob)) {
                            let parsedJson : ?GetAnAlbum401Response.JSON = from_candid(blob);
                            switch (parsedJson) {
                                case (?jsonValue) {
                                    switch (GetAnAlbum401Response.fromJSON(jsonValue)) {
                                        case (?err) " - " # debug_show(err);
                                        case null " - " # responseText;
                                    }
                                };
                                case null " - " # responseText;
                            };
                        };
                        case (#err(_)) " - " # responseText;
                    };
                } else { "" };
                throw Error.reject("HTTP 429: The app has exceeded its rate limits. " # errorDetail);
            };

            // Fallback for status codes not defined in OpenAPI spec
            throw Error.reject("HTTP " # Int.toText(response.status) # ": Unexpected error" #
                (if (responseText != "") { " - " # responseText } else { "" }));
        }
    };

    /// Remove Users' Saved Albums 
    /// Remove one or more albums from the current user's 'Your Music' library. 
    public func removeAlbumsUser(config : Config__, ids : Text, saveAlbumsUserRequest : SaveAlbumsUserRequest) : async* () {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/me/albums"
            # "?" # "ids=" # ids;

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
            method = #delete;
            headers;
            body = do ? {
                let jsonValue = SaveAlbumsUserRequest.toJSON(saveAlbumsUserRequest);
                let candidBlob = to_candid(jsonValue);
                let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON");
                Text.encodeUtf8(jsonText)
            };
        };

        // Call the management canister's http_request method with cycles
        ignore await (with cycles) http_request(request);

    };

    /// Save Albums for Current User 
    /// Save one or more albums to the current user's 'Your Music' library. 
    public func saveAlbumsUser(config : Config__, ids : Text, saveAlbumsUserRequest : SaveAlbumsUserRequest) : async* () {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/me/albums"
            # "?" # "ids=" # ids;

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
            method = #put;
            headers;
            body = do ? {
                let jsonValue = SaveAlbumsUserRequest.toJSON(saveAlbumsUserRequest);
                let candidBlob = to_candid(jsonValue);
                let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON");
                Text.encodeUtf8(jsonText)
            };
        };

        // Call the management canister's http_request method with cycles
        ignore await (with cycles) http_request(request);

    };


    let operations__ = {
        checkUsersSavedAlbums;
        getAnAlbum;
        getAnAlbumsTracks;
        getAnArtistsAlbums;
        getMultipleAlbums;
        getNewReleases;
        getUsersSavedAlbums;
        removeAlbumsUser;
        saveAlbumsUser;
    };

    public module class AlbumsApi(config : Config__) {
        /// Check User's Saved Albums 
        /// Check if one or more albums is already saved in the current Spotify user's 'Your Music' library. 
        public func checkUsersSavedAlbums(ids : Text) : async [Bool] {
            await* operations__.checkUsersSavedAlbums(config, ids)
        };

        /// Get Album 
        /// Get Spotify catalog information for a single album. 
        public func getAnAlbum(id : Text, market : Text) : async AlbumObject {
            await* operations__.getAnAlbum(config, id, market)
        };

        /// Get Album Tracks 
        /// Get Spotify catalog information about an album’s tracks. Optional parameters can be used to limit the number of tracks returned. 
        public func getAnAlbumsTracks(id : Text, market : Text, limit : Int, offset : Int) : async PagingSimplifiedTrackObject {
            await* operations__.getAnAlbumsTracks(config, id, market, limit, offset)
        };

        /// Get Artist's Albums 
        /// Get Spotify catalog information about an artist's albums. 
        public func getAnArtistsAlbums(id : Text, includeGroups : Text, market : Text, limit : Int, offset : Int) : async PagingArtistDiscographyAlbumObject {
            await* operations__.getAnArtistsAlbums(config, id, includeGroups, market, limit, offset)
        };

        /// Get Several Albums 
        /// Get Spotify catalog information for multiple albums identified by their Spotify IDs. 
        public func getMultipleAlbums(ids : Text, market : Text) : async GetMultipleAlbums200Response {
            await* operations__.getMultipleAlbums(config, ids, market)
        };

        /// Get New Releases 
        /// Get a list of new album releases featured in Spotify (shown, for example, on a Spotify player’s “Browse” tab). 
        public func getNewReleases(limit : Int, offset : Int) : async GetNewReleases200Response {
            await* operations__.getNewReleases(config, limit, offset)
        };

        /// Get User's Saved Albums 
        /// Get a list of the albums saved in the current Spotify user's 'Your Music' library. 
        public func getUsersSavedAlbums(limit : Int, offset : Int, market : Text) : async PagingSavedAlbumObject {
            await* operations__.getUsersSavedAlbums(config, limit, offset, market)
        };

        /// Remove Users' Saved Albums 
        /// Remove one or more albums from the current user's 'Your Music' library. 
        public func removeAlbumsUser(ids : Text, saveAlbumsUserRequest : SaveAlbumsUserRequest) : async () {
            await* operations__.removeAlbumsUser(config, ids, saveAlbumsUserRequest)
        };

        /// Save Albums for Current User 
        /// Save one or more albums to the current user's 'Your Music' library. 
        public func saveAlbumsUser(ids : Text, saveAlbumsUserRequest : SaveAlbumsUserRequest) : async () {
            await* operations__.saveAlbumsUser(config, ids, saveAlbumsUserRequest)
        };

    }
}
