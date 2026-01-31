// main.mo - Test canister for generated JSONPlaceholder API client

import { DefaultApi } "../generated/Apis/DefaultApi";
import { type Post } "../generated/Models/Post";
import { type GeoJsonFeature } "../generated/Models/GeoJsonFeature";
import { type GeoJsonPolygon } "../generated/Models/GeoJsonPolygon";
import Debug "mo:core/Debug";
import Array "mo:core/Array";
import Nat "mo:core/Nat";
import Int "mo:core/Int";
import Text "mo:core/Text";
import Error "mo:core/Error";
import Blob "mo:core/Blob";
import Float "mo:core/Float";

persistent actor {
  transient let baseUrl = "https://jsonplaceholder.typicode.com";
  transient let httpbinUrl = "https://httpbin.org";

  // Instantiate the API client with base URL and no access token
  transient let api = DefaultApi({
    baseUrl;
    accessToken = null;
    max_response_bytes = null;
    transform = null;
    is_replicated = null;
    cycles = 30_000_000_000; // 30B cycles - sufficient for most requests
  });

  // Instantiate a separate API client for httpbin.org endpoints
  transient let httpbinApi = DefaultApi({
    baseUrl = httpbinUrl;
    accessToken = null;
    max_response_bytes = null;
    transform = null;
    is_replicated = null;
    cycles = 30_000_000_000; // 30B cycles - sufficient for most requests
  });

  // Transform callback: Convert httpbin.org /anything response to GeoJSON Polygon
  // This demonstrates the IC's transform callback feature for HTTP outcalls
  public query func transformToGeoJson(args : {
    response : { status : Nat; headers : [{ name : Text; value : Text }]; body : Blob };
    context : Blob;
  }) : async { status : Nat; headers : [{ name : Text; value : Text }]; body : Blob } {
    // Create GeoJSON Polygon response body with triple-nested arrays
    let geoJsonResponse = "{" #
      "\"type\": \"Feature\"," #
      "\"geometry\": {" #
        "\"type\": \"Polygon\"," #
        "\"coordinates\": [" #  // Level 1: array of rings
          "[" #                  // Level 2: array of points in ring
            "[-122.4194, 37.7749]," #  // Level 3: [lon, lat] pair
            "[-122.4094, 37.7849]," #
            "[-122.4294, 37.7849]," #
            "[-122.4194, 37.7749]" #   // Close the ring
          "]" #
        "]" #
      "}," #
      "\"properties\": {}" #
    "}";

    // Return transformed response
    {
      status = args.response.status;
      headers = args.response.headers;
      body = Text.encodeUtf8(geoJsonResponse);
    }
  };

  // Health check endpoint
  public query func health() : async Text {
    "API Test Canister is running"
  };

  // Test endpoint 1: Get all posts
  public func testGetPosts() : async [Post] {
    Debug.print("Calling GET /posts...");
    let posts = await api.getPosts();
    Debug.print("Retrieved " # Nat.toText(Array.size(posts)) # " posts");
    posts
  };

  // Test endpoint 2: Get single post by ID
  // Note: Changed to Text parameter to allow testing type-unsafe inputs
  public func testGetPostById(id: Text) : async Post {
    Debug.print("Calling GET /posts/" # id);
    let post = await api.getPostById(id);
    Debug.print("Retrieved post: " # post.title);
    post
  };

  // Get first N posts (limited test)
  public func testGetFirstPosts(n: Nat) : async [Post] {
    Debug.print("Getting first " # Nat.toText(n) # " posts...");
    let allPosts = await api.getPosts();
    let count = Nat.min(n, Array.size(allPosts));
    let firstN = Array.tabulate<Post>(count, func(i) = allPosts[i]);
    Debug.print("Returning " # Nat.toText(Array.size(firstN)) # " posts");
    firstN
  };

  // Test endpoint 3: Test nonexistent endpoint (expects 404 error)
  public func testNonexistentEndpoint() : async Text {
    Debug.print("Calling GET /nonexistent (expecting 404 error)...");
    try {
      let _ = await api.getNonexistent();
      "✗ Expected 404 but request succeeded"
    } catch (err) {
      let errorMsg = Error.message(err);
      Debug.print("Caught expected error: " # errorMsg);
      if (Text.contains(errorMsg, #text "404")) {
        "✓ Caught expected 404 error - " # errorMsg
      } else {
        "WARNING: Caught error but not 404 - " # errorMsg
      }
    }
  };

  // Test endpoint 4: Test getPostById with high number (expects 404)
  public func testGetPostByHighId() : async Text {
    Debug.print("Calling GET /posts/999999 (expecting 404 for non-existent post)...");
    try {
      let post = await api.getPostById("999999");
      "UNEXPECTED: Got a post with id=" # Int.toText(post.id) # ", title=" # post.title
    } catch (err) {
      let errorMsg = Error.message(err);
      Debug.print("Caught error: " # errorMsg);
      // JSONPlaceholder returns HTTP 404 for non-existent post IDs
      if (Text.contains(errorMsg, #text "404")) {
        "✓ Caught 404 error for non-existent post - " # errorMsg
      } else {
        "WARNING: Expected 404 but got different error - " # errorMsg
      }
    }
  };

  // Test endpoint 5: Test getPostById with negative number (expects 404)
  public func testGetPostByNegativeId() : async Text {
    Debug.print("Calling GET /posts/-1 (expecting 404 for invalid negative ID)...");
    try {
      let post = await api.getPostById("-1");
      "UNEXPECTED: Got a post with id=" # Int.toText(post.id) # ", title=" # post.title
    } catch (err) {
      let errorMsg = Error.message(err);
      Debug.print("Caught error: " # errorMsg);
      // JSONPlaceholder returns HTTP 404 for invalid post IDs (including negative)
      if (Text.contains(errorMsg, #text "404")) {
        "✓ Caught 404 error for negative ID - " # errorMsg
      } else {
        "WARNING: Expected 404 but got different error - " # errorMsg
      }
    }
  };

  // Test endpoint 6: Test getPostById with "deadbeef" string (expects 404)
  // This demonstrates type-unsafe input that was only possible after changing
  // the parameter type from integer to string in the OpenAPI spec.
  public func testGetPostByStringId() : async Text {
    Debug.print("Calling GET /posts/deadbeef (expecting 404 for invalid string)...");
    try {
      let post = await api.getPostById("deadbeef");
      "UNEXPECTED: Got a post with id=" # Int.toText(post.id) # ", title=" # post.title
    } catch (err) {
      let errorMsg = Error.message(err);
      Debug.print("Caught error: " # errorMsg);
      // JSONPlaceholder returns HTTP 404 for non-integer IDs
      if (Text.contains(errorMsg, #text "404")) {
        "✓ Caught 404 error for string 'deadbeef' - " # errorMsg
      } else {
        "WARNING: Expected 404 but got different error - " # errorMsg
      }
    }
  };

  // Test endpoint 8: Test HTTP 500 error from httpbin.org
  public func testGetStatus500() : async Text {
    Debug.print("Calling GET https://httpbin.org/status/500 (expecting 500 error)...");
    try {
      let _ = await httpbinApi.getStatus500();
      "✗ Expected 500 but request succeeded"
    } catch (err) {
      let errorMsg = Error.message(err);
      Debug.print("Caught expected error: " # errorMsg);
      if (Text.contains(errorMsg, #text "500")) {
        "✓ Caught expected 500 error - " # errorMsg
      } else {
        "WARNING: Caught error but not 500 - " # errorMsg
      }
    }
  };

  // Test endpoint 9: Test HTTP 503 error from httpbin.org
  public func testGetStatus503() : async Text {
    Debug.print("Calling GET https://httpbin.org/status/503 (expecting 503 error)...");
    try {
      let _ = await httpbinApi.getStatus503();
      "✗ Expected 503 but request succeeded"
    } catch (err) {
      let errorMsg = Error.message(err);
      Debug.print("Caught expected error: " # errorMsg);
      if (Text.contains(errorMsg, #text "503")) {
        "✓ Caught expected 503 error - " # errorMsg
      } else {
        "WARNING: Caught error but not 503 - " # errorMsg
      }
    }
  };

  // Test endpoint 10: Test HTTP 200 from httpbin.org (control test)
  public func testGetJson() : async Text {
    Debug.print("Calling GET https://httpbin.org/json (expecting JSON success)...");
    try {
      let response = await httpbinApi.getJson();
      Debug.print("Success: Received JSON response from httpbin.org");
      "✓ Received JSON response from httpbin.org"
    } catch (err) {
      let errorMsg = Error.message(err);
      Debug.print("Unexpected error: " # errorMsg);
      "✗ Expected 200 but got error - " # errorMsg
    }
  };

  // Test endpoint 11: Test GeoJSON Polygon with triple-nested arrays (via transform callback)
  // This tests the full flow: HTTP outcall → transform callback → JSON deserialization → [[[Float]]]
  public func testGeoJsonPolygon() : async Text {
    Debug.print("Testing GeoJSON Polygon with [[[Float]]] via transform callback...");

    // Create API client with transform callback that converts httpbin /json to GeoJSON
    let geoJsonApi = DefaultApi({
      baseUrl = httpbinUrl;
      accessToken = null;
      max_response_bytes = null;
      transform = ?{
        function = transformToGeoJson;
        context = Blob.fromArray([]);
      };
      is_replicated = null;
      cycles = 30_000_000_000;
    });

    try {
      // Call httpbin.org /json, but transform converts it to GeoJSON Polygon
      let feature = await geoJsonApi.getGeoJsonPolygon();

      // Verify triple-nested array structure works
      let ringCount = feature.geometry.coordinates.size();
      let firstRing = feature.geometry.coordinates[0];
      let pointCount = firstRing.size();
      let firstPoint = firstRing[0];
      let lon = firstPoint[0];
      let lat = firstPoint[1];

      Debug.print("✓ HTTP + transform + deserialization worked!");
      Debug.print("Rings: " # Nat.toText(ringCount));
      Debug.print("Points in first ring: " # Nat.toText(pointCount));
      Debug.print("First coordinate: [" # Float.toText(lon) # ", " # Float.toText(lat) # "]");

      "✓ [[[Float]]] HTTP+deserialization verified - Rings: " # Nat.toText(ringCount) #
      ", Points: " # Nat.toText(pointCount) #
      ", First coord: [" # Float.toText(lon) # ", " # Float.toText(lat) # "]"
    } catch (err) {
      let errorMsg = Error.message(err);
      Debug.print("✗ " # errorMsg);
      "✗ Failed to test GeoJSON Polygon - " # errorMsg
    }
  };
}
