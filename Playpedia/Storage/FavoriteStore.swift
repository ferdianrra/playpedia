//
//  FavoriteStore.swift
//  Playpedia
//
//  Created by Ferdiansyah Annora on 11/10/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class FavoriteStore {
    private(set) var games: [Game]
    private let defaults: UserDefaults
    private let storageKey = "favoriteGames"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: storageKey),
           let games = try? JSONDecoder().decode([Game].self, from: data) {
            self.games = games
        } else {
            games = []
        }
    }

    func contains(_ game: Game) -> Bool {
        games.contains { $0.id == game.id }
    }

    func toggle(_ game: Game) {
        if contains(game) {
            games.removeAll { $0.id == game.id }
        } else {
            games.insert(game, at: 0)
        }
        if let data = try? JSONEncoder().encode(games) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
