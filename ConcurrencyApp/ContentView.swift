//
//  ContentView.swift
//  ConcurrencyApp
//
//  Created by Eslam on 12/10/2025.
//

import SwiftUI

// MARK: - SwiftUI View
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Load Home Data") {
                Task { await viewModel.loadAllSections() }
            }
            .buttonStyle(.borderedProminent)
            
            List(viewModel.logs, id: \.self) { log in
                Text(log)
                    .font(.system(.body, design: .monospaced))
            }
        }
        .padding()
    }
}


// MARK: - ViewModel
@MainActor
class HomeViewModel: ObservableObject {
    @Published var logs: [String] = []
    private let semaphore = AsyncSemaphore(value: 4) // Max 4 concurrent APIs
    
    func loadAllSections() async {
        logs.removeAll()
        await withTaskGroup(of: Void.self) { group in
            for i in 1...5 {
                group.addTask {
                    await self.fetchSection(id: i)
                }
            }
        }
        await MainActor.run {
            self.logs.append("✅ All sections loaded!")
        }
    }
    
    private func fetchSection(id: Int) async {
        await semaphore.wait()
        
        await MainActor.run {
            logs.append("⬆️ Start Section \(id)")
        }
        
        // Simulate API delay
        try? await Task.sleep(nanoseconds: UInt64.random(in: 1_000_000_000...3_000_000_000))
        
        await MainActor.run {
            logs.append("⬇️ Done Section \(id)")
        }
        
        // Release the semaphore after finishing work
        Task {
            await semaphore.signal()
        }
    }
}

