//
//  FullExampleSendable.swift
//  ConcurrencyApp
//
//  Created by Eslam on 15/10/2025.
//

import Foundation
/*
// MARK: - 1️⃣ Basic Sendable Example

struct User: Sendable {
    let id: Int
    let name: String
}

// ✅ Safe because all properties are immutable and Sendable
let user = User(id: 1, name: "Eslam")

// MARK: - 2️⃣ Non-Sendable Example (Mutable class)

final class Counter {
    var value: Int = 0
}

let counter = Counter()

// ❌ This closure is concurrent but captures a non-Sendable class
Task.detached {
    // compiler warning: capture of 'counter' in concurrently executing closure
    counter.value += 1
}

// MARK: - 3️⃣ Fix with @unchecked Sendable (use only if you are sure!)

final class SafeCounter: @unchecked Sendable {
    private let queue = DispatchQueue(label: "safe.counter")
    private var _value: Int = 0
    
    func increment() {
        queue.sync {
            _value += 1
        }
    }
    
    func value() -> Int {
        queue.sync { _value }
    }
}

let safeCounter = SafeCounter()
Task.detached {
    safeCounter.increment()
}

// MARK: - 4️⃣ Sendable Closure (@Sendable)

func doWork(operation: @Sendable () -> Void) {
    operation()
}

doWork {
    print("✅ This closure is Sendable-safe")
}

// ❌ Unsafe version without @Sendable (will warn in Swift 6)
func doWorkUnsafe(operation: () -> Void) {
    operation()
}

// MARK: - 5️⃣ Sendable with Task and capture

struct DataItem: Sendable {
    let id: Int
}

actor DataStore {
    private var items: [DataItem] = []
    
    func add(_ item: DataItem) {
        items.append(item)
    }
    
    func getAll() -> [DataItem] {
        items
    }
}

func performTasks() async {
    let store = DataStore()
    
    // ✅ Structured Concurrency - Safe
    await withTaskGroup(of: Void.self) { group in
        for i in 1...3 {
            group.addTask {
                let item = DataItem(id: i)
                await store.add(item)
            }
        }
    }
    
    let items = await store.getAll()
    print("✅ Stored items:", items.map { $0.id })
}

// run
Task {
    await performTasks()
}

// MARK: - 6️⃣ Example showing nonisolated vs actor isolation

actor Logger {
    private var logs: [String] = []
    
    func log(_ message: String) {
        logs.append(message)
    }
    
    nonisolated func staticLogInfo() {
        print("ℹ️ Logger is active.") // ✅ works because no access to actor state
    }
    
    nonisolated func wrongAccess() {
        // ❌ Error: actor-isolated property 'logs' can not be referenced
        // print(logs.count)
    }
}

// MARK: - 7️⃣ @Sendable in async tasks

actor NetworkManager {
    func fetch() async -> String {
        "📡 Network done"
    }
}

func runAsyncTask() {
    let manager = NetworkManager()
    
    Task { @Sendable in
        let result = await manager.fetch()
        print(result)
    }
}

runAsyncTask()
*/
