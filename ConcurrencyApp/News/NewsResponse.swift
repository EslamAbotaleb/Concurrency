//
//  NewsResponse.swift
//  NewsAppConcurrency
//
//  Created by Eslam on 13/10/2025.
//

import Foundation

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [NewsArticle]
}

struct NewsArticle: Codable, Identifiable {
    var id: UUID { UUID() } // To use in SwiftUI lists
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
}
