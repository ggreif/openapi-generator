// main.mo - Test canister for generated JSONPlaceholder API client

import { DefaultApi } "../generated/Apis/DefaultApi";
import { type Post } "../generated/Models/Post";
import Debug "mo:core/Debug";
import Array "mo:core/Array";
import Nat "mo:core/Nat";
import Int "mo:core/Int";

persistent actor {
  transient let baseUrl = "https://jsonplaceholder.typicode.com";

  // Instantiate the API client with base URL and no access token
  transient let api = DefaultApi({
    baseUrl;
    accessToken = null;
    max_response_bytes = null;
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
}
