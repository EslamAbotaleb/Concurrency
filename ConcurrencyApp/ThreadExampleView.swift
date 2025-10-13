//
//  ThreadExampleView.swift
//  ConcurrencyApp
//
//  Created by Eslam on 12/10/2025.
//

import SwiftUI

struct ThreadExampleView: View {
    @State private var message: String = "Waiting..."
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🧵 Thread Example")
                .font(.title2)
                .bold()
            
            Text(message)
                .padding()
                .font(.headline)
            
            if isLoading {
                ProgressView("Loading...")
            }
            
            Button("Run Task on Background Thread") {
                performHeavyTask()
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .padding()
    }
    
    private func performHeavyTask() {
        isLoading = true
        message = "Running on background thread..."
        // 🔹 Run on background thread using GCD & this fix thread pool which not support default in swift
        DispatchQueue.global(qos: .background).async {
            print("🔧 Running on thread: \(Thread.current)")
            
            // Simulate heavy work
            sleep(3)
            
            // Switch back to main thread for UI updates
            DispatchQueue.main.async {
                print("🖥 Back to main thread: \(Thread.current)")
                message = "Task completed ✅ (updated on Main Thread)"
                isLoading = false
            }
        }
    }
}
