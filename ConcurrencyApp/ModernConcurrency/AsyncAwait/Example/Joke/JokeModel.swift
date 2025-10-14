//
//  JokeModel.swift
//  ConcurrencyApp
//
//  Created by Eslam on 14/10/2025.
//

import Foundation
struct Joke: Codable {
  let setup: String
  let delivery: String
}

func fetchJoke() async throws -> Joke {
    let url = URL(string: "https://v2.jokeapi.dev/joke/Programming?type=twopart")!
    let request = URLRequest(url: url)
    let (data, _) = try await URLSession.shared.data(for: request)
    let joke = try JSONDecoder().decode(Joke.self, from: data)
    return joke
}
