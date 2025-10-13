//
//  NewsLabView.swift
//  NewsAppConcurrency
//
//  Created by Eslam on 13/10/2025.
//

import SwiftUI

struct NewsLabView: View {
    @StateObject private var viewModel = NewsLabViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading news...")
                }
                List(viewModel.articles) { article in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(article.title)
                            .font(.headline)
                        if let desc = article.description {
                            Text(desc)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Divider()
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(viewModel.logMessages, id: \.self) { msg in
                            Text(msg)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(height: 120)
            }
            .navigationTitle("🧭 Concurrency Lab")
            .toolbar {
                Menu("Run Example") {
                    Button("Main vs Global vs Custom Queue") {
                        viewModel.demoQueues()
                    }
                    Button("DispatchGroup Example") {
                        viewModel.fetchAllNewsWithGroup()
                    }
                    Button("Semaphore Example") {
                        viewModel.fetchWithSemaphore()
                    }
                    Button("WorkItem Example") {
                        viewModel.runWorkItemDemo()
                    }
                    Button("OperationQueue Example") {
                        viewModel.runOperationQueueDemo()
                    }
                }
            }
        }
    }
}
