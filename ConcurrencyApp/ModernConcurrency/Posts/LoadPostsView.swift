//
//  LoadPostsView.swift
//  ConcurrencyApp
//
//  Created by Eslam on 15/10/2025.
//

import SwiftUI

struct LoadPostsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Button("Load Posts") {
                executePosts()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    LoadPostsView()
}
