//
//  DispatchQueueView.swift
//  ConcurrencyApp
//
//  Created by Eslam on 13/10/2025.
//

import SwiftUI


struct DispatchAllExamplesView: View {
    @State private var logMessages: [String] = []
    private let customQueue = DispatchQueue(label: "com.eslam.customQueue", attributes: .concurrent)
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🚀 Dispatch Examples")
                .font(.title2)
                .bold()
            
            HStack(spacing: 12) {
                Button("Queue") { runQueueExamples() }
                Button("Group") { runGroupExample() }
                Button("Semaphore") { runSemaphoreExample() }
                Button("WorkItem") { runWorkItemExample() }
            }
            .buttonStyle(.borderedProminent)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(logMessages, id: \.self) { log in
                        Text(log)
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .frame(maxHeight: 400)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
    }
    
    // MARK: - 1️⃣ DispatchQueue Example
    private func runQueueExamples() {
        logMessages.removeAll()
        log("▶️ DispatchQueue Example Started")
        
        // Main queue
        DispatchQueue.main.async {
            log("🟢 Main Queue → \(Thread.current)")
        }
        
        // Global queue
        DispatchQueue.global(qos: .background).async {
            log("🔵 Global Queue → \(Thread.current)")
            sleep(1)
            DispatchQueue.main.async {
                log("⬆️ Back to Main Queue for UI update")
            }
        }
        
        // Custom queue
        customQueue.async {
            log("🟣 Custom Queue Task 1 → \(Thread.current)")
        }
        customQueue.async {
            log("🟣 Custom Queue Task 2 → \(Thread.current)")
        }
    }
    
    // MARK: - 2️⃣ DispatchGroup Example
    private func runGroupExample() {
        logMessages.removeAll()
        log("▶️ DispatchGroup Example Started")
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        for i in 1...3 {
            group.enter()
            queue.async {
                log("📦 Task \(i) started")
                sleep(UInt32(i))
                log("✅ Task \(i) finished")
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            log("🎉 All tasks in group are done → back to main thread")
        }
    }
    
    // MARK: - 3️⃣ DispatchSemaphore Example
    private func runSemaphoreExample() {
        logMessages.removeAll()
        log("▶️ DispatchSemaphore Example Started")
        
        let semaphore = DispatchSemaphore(value: 2) // only 2 tasks at a time
        let queue = DispatchQueue.global(qos: .utility)
        
        for i in 1...5 {
            queue.async {
                semaphore.wait() // wait if 2 tasks are already running
                log("🔓 Start Task \(i)")
                sleep(2)
                log("🔒 Finish Task \(i)")
                semaphore.signal() // release the lock
            }
        }
    }
    
    // MARK: - 4️⃣ DispatchWorkItem Example
    private func runWorkItemExample() {
        logMessages.removeAll()
        log("▶️ DispatchWorkItem Example Started")
        
        var workItem: DispatchWorkItem?
        
        workItem = DispatchWorkItem {
            for i in 1...5 {
                if workItem?.isCancelled == true { // ✅ Safe optional check
                    log("❌ WorkItem cancelled at step \(i)")
                    return
                }
                log("⚙️ Running step \(i)")
                sleep(1)
            }
            log("✅ WorkItem completed")
        }
        
            // Schedule it on a background queue
        DispatchQueue.global().async(execute: workItem!)
        
            // Notify when done
        workItem?.notify(queue: .main) {
            log("🎯 WorkItem finished (or cancelled) → update UI")
        }
        
            // Cancel after 2 seconds (to demo cancellation)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            log("🛑 Cancelling WorkItem after 2s")
            workItem?.cancel()
        }
    }
    
    // MARK: - Helper
    private func log(_ message: String) {
        DispatchQueue.main.async {
            logMessages.append(message)
        }
    }
}
