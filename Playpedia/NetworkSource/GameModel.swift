//
//  GameModel.swift
//  Playpedia
//
//  Created by Ferdiansyah Annora on 11/10/26.
//

import Foundation

struct GamePage: Decodable {
    let next: URL?
    let results: [Game]
}

struct Game: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let released: String?
    let backgroundImage: URL?
    let rating: Double
    let ratingsCount: Int?
    let genres: [GameCategory]?

    var releaseDateText: String {
        guard let released, let date = Self.dateParser.date(from: released) else {
            return "To be announced"
        }
        return date.formatted(.dateTime.day().month(.abbreviated).year().locale(Locale(identifier: "en_US")))
    }

    var genreText: String {
        genres?.map(\.name).joined(separator: " · ") ?? "Game"
    }

    private static let dateParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    enum CodingKeys: String, CodingKey {
        case id, name, released, rating, genres
        case backgroundImage = "background_image"
        case ratingsCount = "ratings_count"
    }
}

struct GameCategory: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}

struct GameDetail: Decodable {
    let id: Int
    let name: String
    let descriptionRaw: String?
    let backgroundImage: URL?
    let released: String?
    let rating: Double
    let metacritic: Int?
    let playtime: Int?
    let genres: [GameCategory]?
    let developers: [GameCategory]?
    let publishers: [GameCategory]?
    let platforms: [GamePlatform]?
    let website: String?

    var websiteURL: URL? {
        guard let website, let url = URL(string: website),
              ["https", "http"].contains(url.scheme?.lowercased() ?? "") else {
            return nil
        }
        return url
    }

    enum CodingKeys: String, CodingKey {
        case id, name, released, rating, metacritic, playtime, genres
        case developers, publishers, platforms, website
        case descriptionRaw = "description_raw"
        case backgroundImage = "background_image"
    }
}

struct GamePlatform: Decodable {
    let platform: GameCategory
}

struct ScreenshotPage: Decodable {
    let results: [GameScreenshot]
}

struct GameScreenshot: Decodable, Identifiable {
    let id: Int
    let image: URL
}

enum PreviewData {
    static let games = [
        Game(
            id: 3328,
            name: "The Witcher 3: Wild Hunt",
            released: "2015-05-18",
            backgroundImage: nil,
            rating: 4.6,
            ratingsCount: 7200,
            genres: [GameCategory(id: 4, name: "Action"), GameCategory(id: 5, name: "RPG")]
        ),
        Game(
            id: 3498,
            name: "Grand Theft Auto V",
            released: "2013-09-17",
            backgroundImage: nil,
            rating: 4.5,
            ratingsCount: 6900,
            genres: [GameCategory(id: 4, name: "Action")]
        )
    ]

    static func favoriteStore(filled: Bool = true) -> FavoriteStore {
        let suite = "Playpedia.Previews.\(filled)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = FavoriteStore(defaults: defaults)
        if filled {
            for game in games.reversed() { store.toggle(game) }
        }
        return store
    }
}
