//
//  GameDetailViewModel.swift
//  Playpedia
//
//  Created by Ferdiansyah Annora on 11/10/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class GameDetailViewModel {
    private(set) var detail: GameDetail?
    private(set) var screenshots: [GameScreenshot] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var screenshotError: String?
    private let service: any GameService

    init(service: (any GameService)? = nil) {
        self.service = service ?? NetworkService()
    }

    func load(id: Int) async {
        guard detail == nil, !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            detail = try await service.getDetail(id: id)
            try Task.checkCancellation()
        } catch {
            if !Task.isCancelled { errorMessage = NetworkError.message(for: error) }
            isLoading = false
            return
        }
        isLoading = false
        await loadScreenshots(id: id)
    }

    func loadScreenshots(id: Int) async {
        screenshotError = nil
        do {
            screenshots = try await service.getScreenshots(id: id)
        } catch {
            if !Task.isCancelled { screenshotError = "Unable to load screenshots." }
        }
    }
}
