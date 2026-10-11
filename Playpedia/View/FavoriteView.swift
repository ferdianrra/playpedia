//
//  FavoriteView.swift
//  Playpedia
//
//  Created by Ferdiansyah Annora on 11/10/26.
//

import SwiftUI

struct FavoriteView: View {
    @Environment(FavoriteStore.self) private var favorites
    var service: (any GameService)?

    var body: some View {
        ZStack {
            AppBackground()
            if favorites.games.isEmpty {
                StateView(
                    symbol: "heart",
                    title: "No favorites yet",
                    message: "Tap the heart on a game’s details page to save it here."
                )
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 18) {
                        Text("\(favorites.games.count) saved games")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                        ForEach(favorites.games) { game in
                            NavigationLink(value: game) { GameCard(game: game) }
                                .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: 680)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Game.self) { game in
            GameDetailView(game: game, service: service)
        }
    }
}

#Preview("Saved games") {
    NavigationStack {
        FavoriteView(service: PreviewGameService())
    }
    .environment(PreviewData.favoriteStore())
    .tint(Color.accent)
    .preferredColorScheme(.dark)
}

#Preview("Empty") {
    NavigationStack {
        FavoriteView(service: PreviewGameService())
    }
    .environment(PreviewData.favoriteStore(filled: false))
    .tint(Color.accent)
    .preferredColorScheme(.dark)
}
