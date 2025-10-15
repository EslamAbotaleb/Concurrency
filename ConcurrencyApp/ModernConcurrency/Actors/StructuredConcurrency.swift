//
//  StructuredConcurrency.swift
//  ConcurrencyApp
//
//  Created by Eslam on 15/10/2025.
//
import Foundation

func fetchMultipleResources(urls: [URL]) async throws -> [Data] {
    try await withThrowingTaskGroup(of: Data.self) { group in
        for url in urls {
            group.addTask {
                let (data, _) = try await URLSession.shared.data(from: url)
                return data
            }
        }
        
        // results
        var results = [Data]()
        for try await data in group {
            results.append(data)
        }
        return results
    }
}
// Define a model for the fetched data
struct Post: Decodable {
    let id: Int
    let title: String
    let body: String
}

// Fetch posts from an API
func fetchPosts() async throws -> [Post] {
    let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode([Post].self, from: data)
}

// Process posts concurrently
func processPosts(posts: [Post]) async {
    await withTaskGroup(of: Void.self) { group in
        for post in posts {
            group.addTask {
                print("Processing post ID: \(post.id) - Title: \(post.title)")
            }
        }
    }
}

// Main function to execute the workflow
func main() async {
    do {
        let posts = try await fetchPosts()
        print("Fetched \(posts.count) posts.")
        await processPosts(posts: posts)
        print("Processing complete.")
    } catch {
        print("An error occurred: \(error)")
    }
}
func executePosts() {
        // Entry point
        Task {
            await main()
        }
}

/*
 GCD Example
 func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
     let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
     let task = URLSession.shared.dataTask(with: url) { data, _, error in
         if let error = error {
             completion(.failure(error))
             return
         }
         guard let data = data else {
             completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil)))
             return
         }
         do {
             let posts = try JSONDecoder().decode([Post].self, from: data)
             completion(.success(posts))
         } catch {
             completion(.failure(error))
         }
     }
     task.resume()
 }

 // Process posts concurrently
 func processPosts(posts: [Post]) {
     let queue = DispatchQueue(label: "com.example.processPosts", attributes: .concurrent)
     let group = DispatchGroup()

     for post in posts {
         group.enter()
         queue.async {
             print("Processing post ID: \(post.id) - Title: \(post.title)")
             group.leave()
         }
     }

     group.notify(queue: .main) {
         print("Processing complete.")
     }
 }

 // Main function to execute the workflow
 func main() {
     fetchPosts { result in
         switch result {
         case .success(let posts):
             print("Fetched \(posts.count) posts.")
             processPosts(posts: posts)
         case .failure(let error):
             print("An error occurred: \(error)")
         }
     }
 }

 // Entry point
 main()
 */
