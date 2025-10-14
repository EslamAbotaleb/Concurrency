//
//  SampleAsynAwaitView.swift
//  ConcurrencyApp
//
//  Created by Eslam on 14/10/2025.
//

import SwiftUI

struct Item: Identifiable, Codable {
    let id: UUID
    let name: String
}

struct SampleAsynAwaitVie: View {
    @State private var items: [Item] = []

    var body: some View {
        List(items) { item in
            Text(item.name)
        }
        .task {
            await loadData()
        }
    }

    @MainActor
    func loadData() async {
        do {
            items = try await fetchData()
        } catch {
            print("Error fetching data: \(error)")
        }
    }

    func fetchData() async throws -> [Item] {
        guard let url = URL(string: "") else {
            throw URLError(.badURL)
        }
        let (data,_) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Item].self, from: data)
    }
}

#Preview {
    SampleAsynAwaitVie()
}
