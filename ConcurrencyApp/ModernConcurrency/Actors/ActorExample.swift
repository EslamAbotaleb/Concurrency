//
//  ActorIsolation.swift
//  ConcurrencyApp
//
//  Created by Eslam on 14/10/2025.
//

import Foundation

/*
 Actor isolation is the core feature of actors. It ensures that mutable state managed by the actor is not directly accessible from outside.
 Instead, the state is modified or read through asynchronous methods, preserving thread safety.
*/
/*
actor BankAccount {
    private var balance: Double = 0.0
    
    func deposit(amount: Double) {
        balance += amount
    }
    func getBalance() -> Double {
        return balance
    }
}
*/
// Problem with Reentrancy example
// from this example actor consider as safe thread but maybe there error will happen here in withdraw
/*
actor BankAccount {
    var balance: Int = 1000

    func withdraw(_ amount: Int) async {
        if balance >= amount {
            print("✅ Enough balance. Processing withdrawal...")
            await Task.sleep(2_000_000_000) // simulate network call
            balance -= amount
            print("💸 Withdrawn \(amount). Balance = \(balance)")
        } else {
            print("❌ Not enough balance.")
        }
    }
}
*/
/*
// to fix previous issue through state isolation
actor BankAccount {
    var balance: Int = 1000

    /*
     here not right yet
     func deposit(amount: Double) async {
         balance += amount
         await Task.sleep(1_000_000_000)
     balance += 10
     }
 
     */
    func withdraw(_ amount: Int) async {
           // Snapshot للحالة الحالية
           let currentBalance = balance

           if currentBalance >= amount {
               print("✅ Enough balance. Processing withdrawal...")
               await Task.sleep( 2_000_000_000)

               // تحقق تاني بعد الانتظار
               if balance >= amount {
                   balance -= amount
                   print("💸 Withdrawn \(amount). Balance = \(balance)")
               } else {
                   print("❌ Balance changed during wait.")
               }
           } else {
               print("❌ Not enough balance.")
           }
       }
}
 */

//Non-blocking Behavior
/*
 actor FileDownloader {
     private var downloads: [String: Data] = [:]

     func downloadFile(from url: String) async throws -> Data {
         if let data = downloads[url] {
             return data
         }

         let fileData = try await fetchData(from: url)
         downloads[url] = fileData
         return fileData
     }

     private func fetchData(from url: String) async throws -> Data {
         // Simulate network delay
         try await Task.sleep(nanoseconds: 1_000_000_000)
         return Data(url.utf8)
     }
 }
 */

actor FileDownloader {
    private var downloads: [String: Data] = [:]
    
    func downloadFile(from url: String) async throws -> Data {
        if let data = downloads[url] {
            return data
        }
        
        let fileData = try await fetchData(from: url)
        downloads[url] = fileData
        return fileData
    }
    
    private func fetchData(from url: String) async throws -> Data {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return Data(url.utf8)
    }
}

// this be like but in case of you reverse the relation (child call parent) in this case will case problem
actor ParentActor {
    let child = ChildActor()
    func performTask() async {
        await child.childTask()
    }
}

actor ChildActor {
    func childTask() {
        // Perform child task
    }
}

/*
 actor BankAccount {
     private var balance: Double = 1000.0

     func withdraw(amount: Double) async throws {
         // snapshot
         let currentBalance = balance

         guard currentBalance >= amount else {
             throw NSError(domain: "Insufficient balance", code: 0)
         }

         print("✅ Balance is enough (\(currentBalance)). Proceeding...")

         await Task.sleep(2_000_000_000)

         // recheck بعد الانتظار
         guard balance >= amount else {
             throw NSError(domain: "Balance changed while waiting", code: 1)
         }

         balance -= amount
         print("💸 Withdrawn \(amount). New balance = \(balance)")
     }
 }
 */

actor BankAccount {
    enum BankError: Error {
        case insufficientFunds
    }
    
    var balance: Double
    
    init(initialDeposit: Double) {
        self.balance = initialDeposit
    }
    
     func withdraw(amount: Double) throws {
        guard balance >= amount else {
            throw BankError.insufficientFunds
        }
        balance -= amount
    }
    
    func deposit(amount: Double) {
        balance = balance + amount
    }
}

struct Charger {
//    static func charge(amount: Double, from bankAccount: BankAccount) async throws -> Double {
//        try await bankAccount.withdraw(amount: amount)
//        let newBalance = await bankAccount.balance
//        return newBalance
//    }
        /// Due to using the `isolated` keyword, we only need to await at the caller side.
        static func charge(amount:  Double, from bankAccount: isolated BankAccount) async throws -> Double {
            try bankAccount.withdraw(amount: amount)
            let newBalance = bankAccount.balance
            return newBalance
        }
}
actor Database {
    func beginTransaction() {
        // ...
    }
    
    func commitTransaction() {
        // ...
    }
    
    func rollbackTransaction() {
        // ...
    }
    
    /// By using an isolated `Database` parameter inside the closure, we can access `Database`-actor isolation from anywhere
    /// allowing us to perform multiple database queries with just one `await`.
    func transaction<Result>(_ transaction: @Sendable (_ database: isolated Database) throws -> Result) throws -> Result {
        do {
            beginTransaction()
            let result = try transaction(self)
            commitTransaction()
            
            return result
        } catch {
            rollbackTransaction()
            throw error
        }
    }
}

extension Actor {
    /// Adds a general `perform` method for any actor to access its isolation domain to perform
    /// multiple operations in one go using the closure.
    @discardableResult
    func performInIsolation<T: Sendable>(_ block: @Sendable (_ actor: isolated Self) throws -> T) async rethrows -> T {
        try block(self)
    }
}
actor Counter {
    private var value = 0

    func increment() {
        value += 1
    }

    func current() -> Int {
        value
    }
}
/*
//Nonisolated Methods for Read-Only Access
actor Logger {
    private var logs: [String] = []

    func log(message: String) {
        logs.append(message)
    }
    /*
     // not accept cause of logs isolated with actor Logger
     nonisolated func readLogs() -> [String] {
         return logs
     }
     */

     func readLogs() -> [String] {
        return logs
    }
    
    // this accept cause of i don't deal with property logs which isolated to actor logger
    nonisolated func messageLog() -> [String] {
        return ["logs"]
    }
}
*/
/*
 1.
actor Logger {
    private var logs: [String] = []

    func log(_ msg: String) {
        logs.append(msg)
    }

    func readLogs() -> [String] {
        logs
    }
}
*/

/*
 2.
actor Logger {
    private var logs: [String] = []

    func log(_ msg: String) {
        logs.append(msg)
    }

    private func getLogsCopy() -> [String] {
        logs
    }

    nonisolated func readLogs(from logger: Logger) async -> [String] {
        await logger.getLogsCopy()
    }
}
*/
actor Config {
    static let version = "1.0"
    nonisolated func appVersion() -> String {
        Self.version
    }
}

//Wrong
/*
 actor BankAccount {
     private var balance: Double = 1000

     func transfer(amount: Double, to receiver: BankAccount) async throws {
         guard balance >= amount else { throw NSError(domain: "Insufficient funds", code: 0) }

         await Task.sleep(2_000_000_000) // simulate network delay
         balance -= amount
         await receiver.deposit(amount: amount)
     }

     func deposit(amount: Double) {
         balance += amount
     }
 }
 */

//Right
/*
 actor BankAccount {
     private var balance: Double = 1000

     func snapshotBalance() -> Double { balance }

     func withdraw(amount: Double) {
         balance -= amount
     }

     func deposit(amount: Double) {
         balance += amount
     }

     func transfer(amount: Double, to receiver: BankAccount) async throws {
         let currentBalance = await snapshotBalance() // snapshot safely

         guard currentBalance >= amount else { throw NSError(domain: "Insufficient funds", code: 0) }

         await Task.sleep(2_000_000_000)

         let finalBalance = await snapshotBalance()
         guard finalBalance >= amount else { throw NSError(domain: "Insufficient funds after delay", code: 1) }

         await withdraw(amount: amount)
         await receiver.deposit(amount: amount)
     }
 }

 */
actor Settings {
    private var theme = "Light"

    func changeTheme(to new: String) {
        theme = new
    }

    func currentTheme() -> String {
        theme
    }
}
actor UserSettings {
    private(set) var theme: String = "Light"
    
    func updateTheme(to newTheme: String) async {
        theme = newTheme
    }
}


@globalActor
actor ImageProcessing {
    static let shared = ImageProcessing()
}

actor DataManager {
    var data: [String] = []
    
     func addData(_ item: String) {
        data.append(item)
    }
}

actor Logger {
    private var logs: [String] = []

    nonisolated func log(_ message: String) {
        Task { await Logger.shared.append(message) }
    }

    private func append(_ message: String) {
        logs.append(message)
        print("Logged:", message)
    }

    static let shared = Logger()
}
