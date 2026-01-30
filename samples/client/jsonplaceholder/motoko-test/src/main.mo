// main.mo - Test canister for generated JSONPlaceholder API client

import { DefaultApi } "../generated/Apis/DefaultApi";
import { type Post } "../generated/Models/Post";
import Debug "mo:core/Debug";
import Array "mo:core/Array";
import Nat "mo:core/Nat";
import Int "mo:core/Int";
import Text "mo:core/Text";
import Error "mo:core/Error";

persistent actor {
  transient let baseUrl = "https://jsonplaceholder.typicode.com";

  // Instantiate the API client with base URL and no access token
  transient let api = DefaultApi({
    baseUrl;
    accessToken = null;
    max_response_bytes = null;
    transform = null;
    is_replicated = null;
    cycles = 30_000_000_000; // 30B cycles - sufficient for most requests
  });

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
  // Note: The API parameter type is Int, providing compile-time type safety.
  // Invalid inputs like "deadbeef" are rejected at compile time, not runtime.
  // The underlying API returns 404 for text IDs, but we never reach that
  // because the Motoko type system prevents passing non-integer values.
  public func testGetPostById(id: Int) : async Post {
    Debug.print("Calling GET /posts/" # Int.toText(id));
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
      "ERROR: Expected 404 but request succeeded"
    } catch (err) {
      let errorMsg = Error.message(err);
      Debug.print("Caught expected error: " # errorMsg);
      if (Text.contains(errorMsg, #text "404")) {
        "SUCCESS: Caught expected 404 error - " # errorMsg
      } else {
        "WARNING: Caught error but not 404 - " # errorMsg
      }
    }
  };

  // Test endpoint 4: Test getPostById with high number (expects 404)
  public func testGetPostByHighId() : async Text {
    Debug.print("Calling GET /posts/999999 (expecting 404 for non-existent post)...");
    try {
      let post = await api.getPostById(999999);
      "UNEXPECTED: Got a post with id=" # Int.toText(post.id) # ", title=" # post.title
    } catch (err) {
      let errorMsg = Error.message(err);
      Debug.print("Caught error: " # errorMsg);
      // JSONPlaceholder returns HTTP 404 for non-existent post IDs
      if (Text.contains(errorMsg, #text "404")) {
        "SUCCESS: Caught 404 error for non-existent post - " # errorMsg
      } else {
        "WARNING: Expected 404 but got different error - " # errorMsg
      }
    }
  };

  // Test endpoint 5: Test getPostById with negative number (expects 404)
  public func testGetPostByNegativeId() : async Text {
    Debug.print("Calling GET /posts/-1 (expecting 404 for invalid negative ID)...");
    try {
      let post = await api.getPostById(-1);
      "UNEXPECTED: Got a post with id=" # Int.toText(post.id) # ", title=" # post.title
    } catch (err) {
      let errorMsg = Error.message(err);
      Debug.print("Caught error: " # errorMsg);
      // JSONPlaceholder returns HTTP 404 for invalid post IDs (including negative)
      if (Text.contains(errorMsg, #text "404")) {
        "SUCCESS: Caught 404 error for negative ID - " # errorMsg
      } else {
        "WARNING: Expected 404 but got different error - " # errorMsg
      }
    }
  };
}
