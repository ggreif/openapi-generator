// ArtistsApi.mo

import Text "mo:core/Text";
import Int "mo:core/Int";
import Array "mo:core/Array";
import Error "mo:core/Error";
import { JSON } "mo:serde";
import { type ArtistObject; JSON = ArtistObject } "../Models/ArtistObject";
import { type FollowArtistsUsersRequest; JSON = FollowArtistsUsersRequest } "../Models/FollowArtistsUsersRequest";
import { type GetAnAlbum401Response; JSON = GetAnAlbum401Response } "../Models/GetAnAlbum401Response";
import { type GetAnArtistsTopTracks200Response; JSON = GetAnArtistsTopTracks200Response } "../Models/GetAnArtistsTopTracks200Response";
import { type GetFollowed200Response; JSON = GetFollowed200Response } "../Models/GetFollowed200Response";
import { type GetMultipleArtists200Response; JSON = GetMultipleArtists200Response } "../Models/GetMultipleArtists200Response";
import { type PagingArtistDiscographyAlbumObject; JSON = PagingArtistDiscographyAlbumObject } "../Models/PagingArtistDiscographyAlbumObject";
import { type UnfollowArtistsUsersRequest; JSON = UnfollowArtistsUsersRequest } "../Models/UnfollowArtistsUsersRequest";

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

    /// Check If User Follows Artists or Users 
    /// Check to see if the current user is following one or more artists or other Spotify users. 
    public func checkCurrentUserFollows(config : Config__, type_ : Text, ids : Text) : async* [Bool] {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/me/following/contains"
            # "?" # "type=" # (switch (type_) { case (#artist) artist; case (#user) user; }) # "&" # "ids=" # ids;

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

    /// Follow Artists or Users 
    /// Add the current user as a follower of one or more artists or other Spotify users. 
    public func followArtistsUsers(config : Config__, type_ : Text, ids : Text, followArtistsUsersRequest : FollowArtistsUsersRequest) : async* () {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/me/following"
            # "?" # "type=" # (switch (type_) { case (#artist) artist; case (#user) user; }) # "&" # "ids=" # ids;

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
                let jsonValue = FollowArtistsUsersRequest.toJSON(followArtistsUsersRequest);
                let candidBlob = to_candid(jsonValue);
                let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON");
                Text.encodeUtf8(jsonText)
            };
        };

        // Call the management canister's http_request method with cycles
        ignore await (with cycles) http_request(request);

    };

    /// Get Artist 
    /// Get Spotify catalog information for a single artist identified by their unique Spotify ID. 
    public func getAnArtist(config : Config__, id : Text) : async* ArtistObject {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/artists/{id}"
            |> Text.replace(_, #text "{id}", id);

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
            from_candid(_) : ?ArtistObject.JSON |>
            (switch (_) {
                case (?jsonValue) {
                    switch (ArtistObject.fromJSON(jsonValue)) {
                        case (?value) value;
                        case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to convert response to ArtistObject");
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

    /// Get Artist's Related Artists 
    /// Get Spotify catalog information about artists similar to a given artist. Similarity is based on analysis of the Spotify community's listening history. 
    public func getAnArtistsRelatedArtists(config : Config__, id : Text) : async* GetMultipleArtists200Response {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/artists/{id}/related-artists"
            |> Text.replace(_, #text "{id}", id);

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
            from_candid(_) : ?GetMultipleArtists200Response.JSON |>
            (switch (_) {
                case (?jsonValue) {
                    switch (GetMultipleArtists200Response.fromJSON(jsonValue)) {
                        case (?value) value;
                        case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to convert response to GetMultipleArtists200Response");
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

    /// Get Artist's Top Tracks 
    /// Get Spotify catalog information about an artist's top tracks by country. 
    public func getAnArtistsTopTracks(config : Config__, id : Text, market : Text) : async* GetAnArtistsTopTracks200Response {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/artists/{id}/top-tracks"
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
            from_candid(_) : ?GetAnArtistsTopTracks200Response.JSON |>
            (switch (_) {
                case (?jsonValue) {
                    switch (GetAnArtistsTopTracks200Response.fromJSON(jsonValue)) {
                        case (?value) value;
                        case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to convert response to GetAnArtistsTopTracks200Response");
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

    /// Get Followed Artists 
    /// Get the current user's followed artists. 
    public func getFollowed(config : Config__, type_ : Text, after : Text, limit : Int) : async* GetFollowed200Response {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/me/following"
            # "?" # "type=" # (switch (type_) { case (#artist) artist; }) # "&" # "after=" # after # "&" # "limit=" # Int.toText(limit);

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
            from_candid(_) : ?GetFollowed200Response.JSON |>
            (switch (_) {
                case (?jsonValue) {
                    switch (GetFollowed200Response.fromJSON(jsonValue)) {
                        case (?value) value;
                        case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to convert response to GetFollowed200Response");
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

    /// Get Several Artists 
    /// Get Spotify catalog information for several artists based on their Spotify IDs. 
    public func getMultipleArtists(config : Config__, ids : Text) : async* GetMultipleArtists200Response {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/artists"
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
            from_candid(_) : ?GetMultipleArtists200Response.JSON |>
            (switch (_) {
                case (?jsonValue) {
                    switch (GetMultipleArtists200Response.fromJSON(jsonValue)) {
                        case (?value) value;
                        case null throw Error.reject("HTTP " # Int.toText(response.status) # ": Failed to convert response to GetMultipleArtists200Response");
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

    /// Unfollow Artists or Users 
    /// Remove the current user as a follower of one or more artists or other Spotify users. 
    public func unfollowArtistsUsers(config : Config__, type_ : Text, ids : Text, unfollowArtistsUsersRequest : UnfollowArtistsUsersRequest) : async* () {
        let {baseUrl; accessToken; cycles} = config;
        let url = baseUrl # "/me/following"
            # "?" # "type=" # (switch (type_) { case (#artist) artist; case (#user) user; }) # "&" # "ids=" # ids;

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
                let jsonValue = UnfollowArtistsUsersRequest.toJSON(unfollowArtistsUsersRequest);
                let candidBlob = to_candid(jsonValue);
                let #ok(jsonText) = JSON.toText(candidBlob, [], null) else throw Error.reject("Failed to serialize to JSON");
                Text.encodeUtf8(jsonText)
            };
        };

        // Call the management canister's http_request method with cycles
        ignore await (with cycles) http_request(request);

    };


    let operations__ = {
        checkCurrentUserFollows;
        followArtistsUsers;
        getAnArtist;
        getAnArtistsAlbums;
        getAnArtistsRelatedArtists;
        getAnArtistsTopTracks;
        getFollowed;
        getMultipleArtists;
        unfollowArtistsUsers;
    };

    public module class ArtistsApi(config : Config__) {
        /// Check If User Follows Artists or Users 
        /// Check to see if the current user is following one or more artists or other Spotify users. 
        public func checkCurrentUserFollows(type_ : Text, ids : Text) : async [Bool] {
            await* operations__.checkCurrentUserFollows(config, type_, ids)
        };

        /// Follow Artists or Users 
        /// Add the current user as a follower of one or more artists or other Spotify users. 
        public func followArtistsUsers(type_ : Text, ids : Text, followArtistsUsersRequest : FollowArtistsUsersRequest) : async () {
            await* operations__.followArtistsUsers(config, type_, ids, followArtistsUsersRequest)
        };

        /// Get Artist 
        /// Get Spotify catalog information for a single artist identified by their unique Spotify ID. 
        public func getAnArtist(id : Text) : async ArtistObject {
            await* operations__.getAnArtist(config, id)
        };

        /// Get Artist's Albums 
        /// Get Spotify catalog information about an artist's albums. 
        public func getAnArtistsAlbums(id : Text, includeGroups : Text, market : Text, limit : Int, offset : Int) : async PagingArtistDiscographyAlbumObject {
            await* operations__.getAnArtistsAlbums(config, id, includeGroups, market, limit, offset)
        };

        /// Get Artist's Related Artists 
        /// Get Spotify catalog information about artists similar to a given artist. Similarity is based on analysis of the Spotify community's listening history. 
        public func getAnArtistsRelatedArtists(id : Text) : async GetMultipleArtists200Response {
            await* operations__.getAnArtistsRelatedArtists(config, id)
        };

        /// Get Artist's Top Tracks 
        /// Get Spotify catalog information about an artist's top tracks by country. 
        public func getAnArtistsTopTracks(id : Text, market : Text) : async GetAnArtistsTopTracks200Response {
            await* operations__.getAnArtistsTopTracks(config, id, market)
        };

        /// Get Followed Artists 
        /// Get the current user's followed artists. 
        public func getFollowed(type_ : Text, after : Text, limit : Int) : async GetFollowed200Response {
            await* operations__.getFollowed(config, type_, after, limit)
        };

        /// Get Several Artists 
        /// Get Spotify catalog information for several artists based on their Spotify IDs. 
        public func getMultipleArtists(ids : Text) : async GetMultipleArtists200Response {
            await* operations__.getMultipleArtists(config, ids)
        };

        /// Unfollow Artists or Users 
        /// Remove the current user as a follower of one or more artists or other Spotify users. 
        public func unfollowArtistsUsers(type_ : Text, ids : Text, unfollowArtistsUsersRequest : UnfollowArtistsUsersRequest) : async () {
            await* operations__.unfollowArtistsUsers(config, type_, ids, unfollowArtistsUsersRequest)
        };

    }
}
