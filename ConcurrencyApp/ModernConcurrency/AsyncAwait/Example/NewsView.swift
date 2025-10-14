//
//  NewsView.swift
//  ConcurrencyApp
//
//  Created by Eslam on 14/10/2025.
//

import SwiftUI

struct Article: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
}

struct ArticleDetailView: View {
    let article: Article

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(article.title)
                    .font(.title)
                    .bold()

                Text(article.content)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NewsView: View {
    @State private var articles: [Article] = []

    var body: some View {
        NavigationView {
            List(articles) { article in
                NavigationLink(destination: ArticleDetailView(article: article)) {
                    Text(article.title)
                }
            }
            .navigationTitle("Latest News")
            .task {
                await loadArticles()
            }
        }
    }

    @MainActor
    func loadArticles() async {
        do {
            articles = try await fetchArticles()
        } catch {
            print("Failed to load articles: \(error)")
        }
    }
}

func fetchArticles() async throws -> [Article] {
    guard let url = URL(string: "https://api.news.com/latest") else {
        throw URLError(.badURL)
    }
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode([Article].self, from: data)
}

#Preview {
    NewsView()
}
