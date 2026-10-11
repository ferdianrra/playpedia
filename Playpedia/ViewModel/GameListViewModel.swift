//
//  GameListViewModel.swift
//  Playpedia
//
//  Created by Ferdiansyah Annora on 11/10/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class GameListViewModel {
    var searchText = ""
    var order = GameOrder.popular
    private(set) var games: [Game] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasNextPage = false
    private(set) var errorMessage: String?
    private let service: any GameService
    private var page = 1
    private var requestID = UUID()

    var queryID: String { "\(order.rawValue)|\(searchText)" }

    init(service: (any GameService)? = nil) {
        self.service = service ?? NetworkService()
    }

    func loadGames(debounce: Bool = false) async {
        let currentID = UUID()
        requestID = currentID
        isLoading = true
        isLoadingMore = false
        errorMessage = nil
        hasNextPage = false
        games = []
        do {
            if debounce {
                try await Task.sleep(for: .milliseconds(350))
            }
            try Task.checkCancellation()
            let result = try await service.getGames(search: searchText, order: order, page: 1)
            try Task.checkCancellation()
            guard requestID == currentID else { return }
            games = result.results
            hasNextPage = result.next != nil
            page = 1
        } catch {
            guard requestID == currentID else { return }
            if !Task.isCancelled {
                errorMessage = NetworkError.message(for: error)
            }
        }
        if requestID == currentID { isLoading = false }
    }

    func loadMoreIfNeeded(after game: Game) async {
        guard errorMessage == nil, games.suffix(3).contains(where: { $0.id == game.id }) else { return }
        await loadNextPage()
    }

    func loadNextPage() async {
        guard hasNextPage, !isLoading, !isLoadingMore else { return }
        let currentID = requestID
        isLoadingMore = true
        errorMessage = nil
        do {
            let result = try await service.getGames(search: searchText, order: order, page: page + 1)
            try Task.checkCancellation()
            guard currentID == requestID else { return }
            let existingIDs = Set(games.map(\.id))
            games.append(contentsOf: result.results.filter { !existingIDs.contains($0.id) })
            page += 1
            hasNextPage = result.next != nil
        } catch {
            guard currentID == requestID else { return }
            if !Task.isCancelled { errorMessage = NetworkError.message(for: error) }
        }
        if currentID == requestID { isLoadingMore = false }
    }
}
