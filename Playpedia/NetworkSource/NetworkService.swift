//
//  NetworkService.swift
//  Playpedia
//
//  Created by Ferdiansyah Annora on 11/10/26.
//

import Foundation

enum GameOrder: String, CaseIterable, Identifiable {
    case popular = "-added"
    case topRated = "-rating"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .popular: "Popular"
        case .topRated: "Top rated"
        }
    }
}

protocol GameService {
    func getGames(search: String, order: GameOrder, page: Int) async throws -> GamePage
    func getDetail(id: Int) async throws -> GameDetail
    func getScreenshots(id: Int) async throws -> [GameScreenshot]
}

struct NetworkService: GameService {
    private let session: URLSession
    private let apiKey: String

    init(session: URLSession = .shared, apiKey: String = "3e2eb4a3c39b4ea2927d6e1c0bb2137e") {
        self.session = session
        self.apiKey = apiKey
    }

    func getGames(search: String = "", order: GameOrder = .popular, page: Int = 1) async throws -> GamePage {
        var query = [
            URLQueryItem(name: "page_size", value: "20"),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "ordering", value: order.rawValue)
        ]
        let search = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if !search.isEmpty {
            query.append(URLQueryItem(name: "search", value: search))
        }
        return try await fetch(path: "games", query: query)
    }

    func getDetail(id: Int) async throws -> GameDetail {
        try await fetch(path: "games/\(id)")
    }

    func getScreenshots(id: Int) async throws -> [GameScreenshot] {
        let page: ScreenshotPage = try await fetch(path: "games/\(id)/screenshots")
        return page.results
    }

    func requestURL(path: String, query: [URLQueryItem] = []) throws -> URL {
        var components = URLComponents(string: "https://api.rawg.io/api/\(path)")
        components?.queryItems = [URLQueryItem(name: "key", value: apiKey)] + query
        guard let url = components?.url else { throw NetworkError.invalidURL }
        return url
    }

    private func fetch<Response: Decodable>(path: String, query: [URLQueryItem] = []) async throws -> Response {
        var request = URLRequest(url: try requestURL(path: path, query: query))
        request.timeoutInterval = 30
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
        guard (200..<300).contains(response.statusCode) else {
            throw NetworkError.server(response.statusCode)
        }
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw NetworkError.invalidData
        }
    }
}

enum NetworkError: LocalizedError {
    case invalidURL, invalidResponse, invalidData
    case server(Int)

    static func message(for error: Error) -> String {
        if let networkError = error as? NetworkError {
            return networkError.errorDescription ?? "Unable to load data. Please try again."
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "You’re offline. Check your internet connection and try again."
            case .timedOut:
                return "The request timed out. Please try again."
            default:
                return "Unable to connect. Please try again."
            }
        }
        return "Unable to load data. Please try again."
    }

    var errorDescription: String? {
        switch self {
        case .invalidURL, .invalidResponse:
            "Unable to reach the server. Please try again."
        case .invalidData:
            "Unable to read the game data. Please try again."
        case .server(let status):
            status == 401 || status == 403
                ? "The API key is invalid. Check the RAWG configuration."
                : "The server returned an error (\(status)). Please try again."
        }
    }
}

struct PreviewGameService: GameService {
    func getGames(search: String, order: GameOrder, page: Int) async throws -> GamePage {
        let games = PreviewData.games.filter {
            search.isEmpty || $0.name.localizedCaseInsensitiveContains(search)
        }
        return GamePage(next: nil, results: games)
    }

    func getDetail(id: Int) async throws -> GameDetail {
        let game = PreviewData.games.first { $0.id == id } ?? PreviewData.games[0]
        return GameDetail(
            id: game.id,
            name: game.name,
            descriptionRaw: "Explore a vast open world, take on quests, and shape your story through your choices.",
            backgroundImage: game.backgroundImage,
            released: game.released,
            rating: game.rating,
            metacritic: 92,
            playtime: 46,
            genres: game.genres,
            developers: [GameCategory(id: 1, name: "CD PROJEKT RED")],
            publishers: [GameCategory(id: 1, name: "CD PROJEKT RED")],
            platforms: [GamePlatform(platform: GameCategory(id: 4, name: "PC"))],
            website: "https://www.thewitcher.com"
        )
    }

    func getScreenshots(id: Int) async throws -> [GameScreenshot] { [] }
}
