//
//  QueueExampleView.swift
//  ConcurrencyApp
//
//  Created by Eslam on 12/10/2025.
//

import SwiftUI

// MARK: - Queue Example View
struct QueueExampleView: View {
    @State private var message = "Tap to start..."
    @State private var logMessages: [String] = []
    @State private var downloadedImage: UIImage?

    private let operationQueue = OperationQueue()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🧩 Queue Example")
                .font(.title2).bold()
            
            Text(message)
                .foregroundColor(.blue)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(logMessages, id: \.self) { log in
                        Text(log)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 200)
            .border(.gray.opacity(0.3))
            
            HStack {
                Button("🚀 Run All Queue Types") {
                    runQueueExamples()
                }
                .buttonStyle(.borderedProminent)
                
                Button("❌ Cancel Operations") {
                    cancelOperations()
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            Button("DispatchSemaphore") {
                dispatchSemaphoreExample()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
                // Display downloaded image
                        if let uiImage = downloadedImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(radius: 4)
                        }
                        
            
            Button("📸 Download Image") {
                downloadImage()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding()
    }
}

extension QueueExampleView {
    
    private func log(_ text: String) {
        DispatchQueue.main.async {
            logMessages.append(text)
        }
    }
    
    private func runQueueExamples() {
        logMessages.removeAll()
        message = "Running queue examples..."
        
        // 1️⃣ Main Queue
        DispatchQueue.main.async {
            log("🟢 Main Queue → \(Thread.current)")
        }
        
        // 2️⃣ Global Queue with QoS
        DispatchQueue.global(qos: .background).async {
            log("⚫ Global Queue (.background) → \(Thread.current)")
            sleep(1)
        }
        
        // 3️⃣ Serial Queue
        let serialQueue = DispatchQueue(label: "com.example.serial", qos: .userInitiated)
        serialQueue.async {
            log("🧱 Serial Queue → Task 1")
            sleep(1)
        }
        serialQueue.async {
            log("🧱 Serial Queue → Task 2")
        }
        
        // 4️⃣ Concurrent Queue
        let concurrentQueue = DispatchQueue(label: "com.example.concurrent", qos: .userInitiated, attributes: .concurrent)
        concurrentQueue.async {
            log("⚙️ Concurrent Queue → Task A")
            sleep(2)
        }
        concurrentQueue.async {
            log("⚙️ Concurrent Queue → Task B")
        }
        
        // 5️⃣ Custom Queue with QoS
        let customQueue = DispatchQueue(label: "com.example.custom", qos: .userInitiated)
        customQueue.async {
            log("💎 Custom Queue (.userInitiated) → \(Thread.current)")
        }
        
        // 6️⃣ Operation Queue with Dependencies
        operationQueue.qualityOfService = .userInitiated
        operationQueue.maxConcurrentOperationCount = 2
        
        let op1 = BlockOperation()
        op1.addExecutionBlock { [weak op1] in
            for i in 1...3 {
                if op1?.isCancelled == true { return }
                self.log("🧩 Operation 1 Step \(i)")
                sleep(1)
            }
        }

        let op2 = BlockOperation()
        op2.addExecutionBlock { [weak op2] in
            if op2?.isCancelled == true { return }
            self.log("🧩 Operation 2 running")
            sleep(1)
        }
        
        op2.addDependency(op1)
        operationQueue.addOperations([op1, op2], waitUntilFinished: false)
        
        // Update message
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            message = "✅ Queue examples completed!"
        }
    }
    
    private func downloadImage() {
        log("📸 Starting image download...")
        
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        
        let imageURL = URL(string: "https://picsum.photos/300")!
        let downloadOp = ImageDownloadOperation(url: imageURL)
        
        downloadOp.completionBlock = {
            DispatchQueue.main.async {
                if let img = downloadOp.image {
                    self.downloadedImage = img
                    self.log("✅ Image downloaded successfully!")
                } else {
                    self.log("❌ Failed to download image.")
                }
            }
        }
        
        queue.addOperation(downloadOp)
    }
    
    
    private func dispatchSemaphoreExample() {
        let semaphore = DispatchSemaphore(value: 2)
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        for i in 1...5 {
            queue.async(qos: .userInitiated) {
                semaphore.wait()
                print("🔹 Start Task \(i) — \(Thread.current)")
                sleep(2)
                print("✅ Finish Task \(i)")
                semaphore.signal()
            }
        }
    }
    
    private func cancelOperations() {
        operationQueue.cancelAllOperations()
        log("⚠️ All operations cancelled")
        message = "❌ Operations cancelled"
    }
}
