//
//  JokeView.swift
//  ConcurrencyApp
//
//  Created by Eslam on 14/10/2025.
//

import SwiftUI

struct JokeView: View {
    @State private var joke: Joke?
    @State private var isLoading = false

    var body: some View {
      VStack(spacing: 8) {
        if let joke = joke {
          Text(joke.setup)
            .font(.title)
          Text(joke.delivery)
            .font(.headline)
        } else {
          Text("Tap to fetch a joke!")
        }

        Button {
          Task {
            isLoading = true
            do {
              joke = try await fetchJoke()
            } catch {
              print("Failed to fetch joke: \(error)")
            }
            isLoading = false
          }
        } label: {
          if isLoading {
            ProgressView()
              .progressViewStyle(.circular)
              .padding(.horizontal)
          } else {
            Text("Fetch Joke")
          }
        }
        .disabled(isLoading)
        .buttonStyle(.borderedProminent)
        .padding()
      }
      .multilineTextAlignment(.center)
      .padding(.horizontal)
    }
}

#Preview {
    JokeView()
}
