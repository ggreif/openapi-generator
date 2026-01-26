// main.mo - Test canister for generated JSONPlaceholder API client

import DefaultApi "../generated/Apis/DefaultApi";
import { type Post } "../generated/Models/Post";
import Debug "mo:core/Debug";
import Array "mo:core/Array";
import Nat "mo:core/Nat";

persistent actor {
  transient let baseUrl = "https://jsonplaceholder.typicode.com";

  // Health check endpoint
  public query func health() : async Text {
    "API Test Canister is running"
  };

  // Test endpoint 1: Get all posts
  public func testGetPosts() : async [Post] {
    Debug.print("Calling GET /posts...");
    let posts = await DefaultApi.getPosts(baseUrl);
    Debug.print("Retrieved " # Nat.toText(Array.size(posts)) # " posts");
    posts
  };

  // Test endpoint 2: Get single post by ID
  public func testGetPostById(id: Int) : async Post {
    Debug.print("Calling GET /posts/" # debug_show(id));
    let post = await DefaultApi.getPostById(baseUrl, id);
    Debug.print("Retrieved post: " # post.title);
    post
  };

  // Get first N posts (limited test)
  public func testGetFirstPosts(n: Nat) : async [Post] {
    Debug.print("Getting first " # Nat.toText(n) # " posts...");
    let allPosts = await DefaultApi.getPosts(baseUrl);
    let count = Nat.min(n, Array.size(allPosts));
    let firstN = Array.tabulate<Post>(count, func(i) = allPosts[i]);
    Debug.print("Returning " # Nat.toText(Array.size(firstN)) # " posts");
    firstN
  };
}
