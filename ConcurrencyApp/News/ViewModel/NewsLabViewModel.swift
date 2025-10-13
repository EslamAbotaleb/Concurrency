//
//  NewsLabViewModel.swift
//  NewsAppConcurrency
//
//  Created by Eslam on 13/10/2025.
//

import Foundation

class NewsLabViewModel: ObservableObject {
    @Published var articles: [NewsArticle] = []
    @Published var logMessages: [String] = []
    @Published var isLoading = false
    
    private let categories = ["technology", "sports", "world", "business"]
    let apiKey = "5fe83f5263b04dbe9c11ec7070b6f6b8"

    //MARK: - Main vs Global vs Custom Queue
    func demoQueues() {
        log("▶️ Starting queue demo")
        let customQueue = DispatchQueue(label: "com.newslab.customQueue")
        
        DispatchQueue.main.async {
            self.log("🟢 Main queue → UI updates run here")
        }
        
        DispatchQueue.global(qos: .background).async {
            self.log("🔵 Global queue → background work")
        }
        
        customQueue.async {
            self.log("🟣 Custom serial queue → task executed in order")
        }
    }
    
    // MARK: - 2️⃣ DispatchGroup (Parallel APIs)
    func fetchAllNewsWithGroup() {
        isLoading = true
        log("📡 Fetching multiple categories using DispatchGroup...")
        
        let group = DispatchGroup()
        var allArticles: [NewsArticle] = []
//        let queue = DispatchQueue(label: "com.newslab.threadSafe", attributes: .concurrent)
        let barrier = DispatchQueue(label: "com.newslab.barrier")
        
        for category in categories {
            group.enter()
            let url = URL(string: "https://newsapi.org/v2/top-headlines?country=us&category=\(category)&apiKey=\(apiKey)")!
            log("Which api using DispatchGroup...\(url)")

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let data = try Data(contentsOf: url)
                    let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
                    
                    // Protect shared array using barrier (thread-safe)
                    barrier.async(flags: .barrier) {
                        allArticles.append(contentsOf: decoded.articles)
                        self.log("✅ \(category.capitalized) loaded")
                        group.leave()
                    }
                    
                } catch {
                    self.log("❌ Error fetching \(category): \(error.localizedDescription)")
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            self.articles = allArticles
            self.isLoading = false
            self.log("🎯 All categories done (\(allArticles.count) articles)")
        }
    }
    
    // MARK: - 3️⃣ DispatchSemaphore (Limit Parallelism)
    func fetchWithSemaphore() {
        isLoading = true
        log("🚦 Using DispatchSemaphore to limit concurrency to 2...")
        let semaphore = DispatchSemaphore(value: 2)
        let group = DispatchGroup()
        var all: [NewsArticle] = []
        for category in categories {
            group.enter()
            semaphore.wait() // Wait if 2 tasks already running
            DispatchQueue.global().async {
                let url = URL(string: "https://newsapi.org/v2/top-headlines?country=us&category=\(category)&apiKey=\(self.apiKey)")!
                if let data = try? Data(contentsOf: url),
                   let decoded = try? JSONDecoder().decode(NewsResponse.self, from: data) {
                       DispatchQueue.main.async {
                           all.append(contentsOf: decoded.articles)
                       }
                }
                self.log("⬇️ Done: \(category)")
                semaphore.signal() // Allow next
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.articles = all
            self.isLoading = false
            self.log("🏁 Semaphore example complete (\(all.count) articles)")
        }
    }
    // MARK: - 4️⃣ DispatchWorkItem (Cancelable Task)
    private var workItem: DispatchWorkItem?
    
    func runWorkItemDemo() {
        log("⚙️ DispatchWorkItem started...")
        workItem = DispatchWorkItem {
            for i in 1...5 {
                if self.workItem?.isCancelled == true {
                    self.log("❌ Cancelled at step \(i)")
                    return
                }
                self.log("🔧 Working step \(i)")
                sleep(1)
            }
            self.log("✅ WorkItem completed successfully")
        }
        
        DispatchQueue.global().async(execute: workItem!)
        
            // Auto-cancel after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.log("🛑 Cancelling WorkItem...")
            self.workItem?.cancel()
        }
    }
    
        // MARK: - 5️⃣ OperationQueue (Higher-Level Control)
    func runOperationQueueDemo() {
        log("⚙️ Running OperationQueue demo...")
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 2
        
        let op1 = BlockOperation {
            self.log("🔹 Operation 1 started")
            sleep(1)
            self.log("🔹 Operation 1 finished")
        }
        
        let op2 = BlockOperation {
            self.log("🔸 Operation 2 started")
            sleep(2)
            self.log("🔸 Operation 2 finished")
        }
        
        let op3 = BlockOperation {
            self.log("🔻 Operation 3 depends on op2")
            sleep(1)
            self.log("🔻 Operation 3 finished")
        }
        op3.addDependency(op2)
        
        queue.addOperations([op1, op2, op3], waitUntilFinished: false)
    }
    // MARK: - Helpers
    private func log(_ message: String) {
        DispatchQueue.main.async {
            self.logMessages.append(message)
            print(message)
        }
    }
}
