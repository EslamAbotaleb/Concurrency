//
//  DownloadFilesResult.swift
//  ConcurrencyApp
//
//  Created by Eslam on 15/10/2025.
//

import Foundation
/*
 struct DownloadResult {
     let filename: String
     let data: Data
 }

 func downloadFiles(_ urls: [URL]) async throws -> [DownloadResult] {
     // Create a task group that returns DownloadResult
     return try await withThrowingTaskGroup(of: DownloadResult.self) { group in
         // Add a task for each URL
         for url in urls {
             group.addTask {
                 // Each task downloads one file
                 let (data, _) = try await URLSession.shared.data(from: url)
                 let filename = url.lastPathComponent
                 return DownloadResult(filename: filename, data: data)
             }
         }

         // Collect all results
         var results: [DownloadResult] = []
         for try await result in group {
             results.append(result)
         }

         return results
     }
 }

 // Usage
 Task {
     let urls = [
         URL(string: "https://example.com/file1.json")!,
         URL(string: "https://example.com/file2.json")!,
         URL(string: "https://example.com/file3.json")!
     ]

     do {
         let files = try await downloadFiles(urls)
         print("Downloaded \(files.count) files")

         // If any download fails, all others are automatically cancelled
         // No need to manually manage tasks!
     } catch {
         print("Download failed: \(error)")
     }
 }
 */

// Downloading Files with TaskGroup
struct DownloadResult {
    let fileName: String
    let data: Data
}

func downloadFiles(_ urls: [URL]) async throws -> [DownloadResult] {
    return try await withThrowingTaskGroup(of: DownloadResult.self) { group in
        for url in urls {
            group.addTask {
                let (data, _) = try await URLSession.shared.data(from: url)
                let fileName = url.lastPathComponent
                return DownloadResult(fileName: fileName, data: data)
            }
        }
        
        var results: [DownloadResult] = []
        for try await result in group {
            results.append(result)
        }
        return results
    }
}

func executeDownloadFiles() async {
    let urls = [
        URL(string: "https://example.com/file1.json")!,
        URL(string: "https://example.com/file2.json")!,
        URL(string: "https://example.com/file3.json")!
    ]
    do {
        let files = try await downloadFiles(urls)
        print("Downloaded \(files.count) files")

        // If any download fails, all others are automatically cancelled
        // No need to manually manage tasks!
    } catch {
        print("Download failed: \(error)")
    }
}

/*
 Fetching User Data with Async Let
 struct User {
     let name: String
     let age: Int
 }

 struct Posts {
     let count: Int
     let recent: [String]
 }

 // Fetch functions (simulating API calls)
 func fetchUser(id: Int) async throws -> User {
     // Simulate network delay
     try await Task.sleep(for: .seconds(1))
     return User(name: "Alice", age: 30)
 }

 func fetchUserPosts(userId: Int) async throws -> Posts {
     // Simulate network delay
     try await Task.sleep(for: .seconds(1))
     return Posts(count: 45, recent: ["Hello World", "Swift is awesome"])
 }

 // Fetch both in parallel using async let
 func loadUserProfile(userId: Int) async throws -> (user: User, posts: Posts) {
     // Start both operations at the same time
     async let user = fetchUser(id: userId)
     async let posts = fetchUserPosts(userId: userId)

     // Wait for both to complete
     // Total time: ~1 second (not 2!) because they run in parallel
     return try await (user, posts)
 }

 // Usage
 Task {
     do {
         let (user, posts) = try await loadUserProfile(userId: 123)
         print("\(user.name) has \(posts.count) posts")

         // Both requests run in parallel
         // If either fails, the other is cancelled automatically
     } catch {
         print("Failed to load profile: \(error)")
     }
 }
 */
