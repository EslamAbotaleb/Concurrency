//
//  SendableExample.swift
//  ConcurrencyApp
//
//  Created by Eslam on 15/10/2025.
//

import Foundation

/*
// contains multiple data races.
 these errors ---->
/*
  Array index out of bounds crashes
  Incorrect total calculations
  Memory corruption
  Unpredictable app behavior
*/
 
class ShoppingCart {
    var items: [Product] = []
    var totalPrice: Double = 0.0

    func addItem(_ product: Product) {
        items.append(product)
        totalPrice += product.price
    }

    func removeItem(at index: Int) {
        let removedProduct = items.remove(at: index)
        totalPrice -= removedProduct.price
    }
}

// Multiple parts of the app accessing the same cart
let cart = ShoppingCart()

// Background task adding items
Task {
    cart.addItem(Product(name: "iPhone", price: 999.0))
}

// Another task removing items
Task {
    if !cart.items.isEmpty {
        cart.removeItem(at: 0)  // Potential crash!
    }
}

// Main thread displaying total
print("Total: $\(cart.totalPrice)")  // Unpredictable value!
*/

// Automatically Sendable - all properties are immutable and Sendable
struct User: Sendable {
    let id: UUID
    let name: String
    let email: String
    let registrationDate: Date
}
// Also automatically Sendable
struct APIResponse: Sendable {
    let statusCode: Int
    let data: Data
    let timestamp: Date
}

enum NetworkError: Error {
    
}
enum NetworkResult: Sendable {
    case success(Data)
    case failure(NetworkError)
    case loading
}
enum UserAction: Sendable {
    case login(username: String, password: String)
    case logout
    case updateProfile(User)
}

class DatabaseConnection {
    func execute(_ query: String) { /* ... */ }
}

let connections: [DatabaseConnection] = []  // Not Sendable

// ✅ Use Sendable identifiers instead
struct ConnectionID: Sendable {
    let id: UUID
}

let connectionIDs: [ConnectionID] = []  // Sendable

// ✅ Or use actor for managing connections
actor ConnectionPool {
    private var connections: [UUID: DatabaseConnection] = [:]

    func getConnection(id: UUID) -> DatabaseConnection? {
        return connections[id]
    }
}

// Basic API request model
struct APIRequest: Sendable {
    let url: URL
    let method: String
    let headers: [String: String]
}

// Simple data cache using actor
actor DataCache {
    private var cache: [String: Data] = [:]

    func store(key: String, data: Data) {
        cache[key] = data
    }

    func retrieve(key: String) -> Data? {
        return cache[key]
    }
}

// Sendable result type
enum Result<T: Sendable>: Sendable {
    case success(T)
    case failure(Error)
}

struct CounterSendable: Sendable {
    var value: Int  // mutable ❌
}

/*
 error Actor-isolated property 'data' can not be mutated from a nonisolated context
actor DataManagerSendable {
    var data: [String] = []
}

func useManager(_ manager: DataManagerSendable) async {
    Task.detached {
        await manager.data.append("New") // ❌ Error: actor-isolated data
    }
}
*/

/*
 Solution
 actor DataManager {
     private var data: [String] = []

     func add(_ item: String) {
         data.append(item)
     }
 }
 */

/*
struct User: Sendable {
    let id: Int
    let name: String
}

actor UserStore {
    private var users: [User] = []
    
    func add(_ user: User) {
        users.append(user)
    }

    func getAll() -> [User] {
        users
    }
}

func perform() async {
    let store = UserStore()
    
    // Structured task
    await withTaskGroup(of: Void.self) { group in
        for i in 1...3 {
            group.addTask {
                let user = User(id: i, name: "User \(i)")
                await store.add(user) // Safe, User is Sendable
            }
        }
    }
    
    let users = await store.getAll()
    print(users)
}
*/
