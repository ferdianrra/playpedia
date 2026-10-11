//
//  GameDetailView.swift
//  Playpedia
//
//  Created by Ferdiansyah Annora on 11/10/26.
//

import SwiftUI

struct GameDetailView: View {
    let game: Game
    @Environment(FavoriteStore.self) private var favorites
    @State private var viewModel: GameDetailViewModel
    @State private var showNavigationHeader = false

    init(game: Game, service: (any GameService)? = nil) {
        self.game = game
        _viewModel = State(initialValue: GameDetailViewModel(service: service))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        artwork
                        titleSection
                            .background {
                                GeometryReader { titleGeometry in
                                    Color.clear.preference(
                                        key: DetailTitlePositionKey.self,
                                        value: titleGeometry.frame(in: .global).minY
                                    )
                                }
                            }
                        if viewModel.isLoading {
                            ProgressView("Loading details…")
                                .frame(maxWidth: .infinity)
                                .tint(Color.accent)
                        } else if let detail = viewModel.detail {
                            detailContent(detail)
                        } else if let error = viewModel.errorMessage {
                            StateView(symbol: "wifi.exclamationmark", title: "Unable to load details", message: error) {
                                Task { await viewModel.load(id: game.id) }
                            }
                        }
                    }
                    .padding(.bottom, 32)
                    .frame(maxWidth: 760)
                    .frame(maxWidth: .infinity)
                }
                .ignoresSafeArea(edges: .top)
            }
            .onPreferenceChange(DetailTitlePositionKey.self) { titleTop in
                showNavigationHeader = titleTop < geometry.frame(in: .global).minY
            }
        }
        .navigationTitle(showNavigationHeader ? (viewModel.detail?.name ?? game.name) : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.ambientGlow, for: .navigationBar)
        .toolbarBackground(showNavigationHeader ? .visible : .hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(Color.textPrimary)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    favorites.toggle(game)
                } label: {
                    Image(systemName: favorites.contains(game) ? "heart.fill" : "heart")
                        .foregroundStyle(favorites.contains(game) ? Color.accent : Color.textPrimary)
                }
                .accessibilityLabel(favorites.contains(game) ? "Remove from favorites" : "Add to favorites")
            }
        }
        .task { await viewModel.load(id: game.id) }
    }

    private var artwork: some View {
        GameImage(url: viewModel.detail?.backgroundImage ?? game.backgroundImage)
            .frame(height: 420)
            .overlay(alignment: .top) {
                LinearGradient(
                    colors: [Color.artworkOverlay.opacity(0.65), Color.artworkOverlay.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 180)
                .allowsHitTesting(false)
            }
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [Color.artworkOverlay.opacity(0), Color.appBackground],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 160)
            }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(viewModel.detail?.name ?? game.name)
                .font(.title.weight(.medium))
                .foregroundStyle(Color.textPrimary)
            Text(game.genreText)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
            HStack(spacing: 12) {
                RatingBadge(rating: viewModel.detail?.rating ?? game.rating)
                Label(game.releaseDateText, systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(.horizontal, 20)
    }

    private func detailContent(_ detail: GameDetail) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("About the game").font(.title3.weight(.medium))
                Text(displayText(detail.descriptionRaw, fallback: "No description available."))
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .lineSpacing(5)
                    .textSelection(.enabled)
            }
            VStack(alignment: .leading, spacing: 16) {
                information("Platform", value: detail.platforms?.map { $0.platform.name }.joined(separator: ", "))
                information("Genre", value: detail.genres?.map(\.name).joined(separator: ", "))
                information("Developer", value: detail.developers?.map(\.name).joined(separator: ", "))
                information("Publisher", value: detail.publishers?.map(\.name).joined(separator: ", "))
                HStack(alignment: .top) {
                    information("Metacritic", value: detail.metacritic.map { "\($0) / 100" })
                    Spacer()
                    information("Playtime", value: detail.playtime.flatMap { $0 > 0 ? "\($0) hours" : nil })
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 20))
            screenshots
            if let url = detail.websiteURL {
                Link(destination: url) {
                    Label("Official website", systemImage: "arrow.up.right.square")
                        .font(.subheadline.weight(.medium))
                }
            }
            Link("Source: RAWG", destination: URL(string: "https://rawg.io/games/\(game.id)")!)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
        .foregroundStyle(Color.textPrimary)
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var screenshots: some View {
        if !viewModel.screenshots.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Screenshots").font(.title3.weight(.medium))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.screenshots) { screenshot in
                            GameImage(url: screenshot.image)
                                .frame(width: 260, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
            }
        } else if let error = viewModel.screenshotError {
            VStack(alignment: .leading, spacing: 8) {
                Text(error).font(.caption).foregroundStyle(Color.textSecondary)
                Button("Retry screenshots") {
                    Task { await viewModel.loadScreenshots(id: game.id) }
                }
                .font(.caption)
            }
        }
    }

    private func displayText(_ value: String?, fallback: String) -> String {
        guard let value, !value.isEmpty else { return fallback }
        return value
    }

    private func information(_ title: String, value: String?) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.caption).foregroundStyle(Color.textSecondary)
            Text(displayText(value, fallback: "Not available"))
                .font(.subheadline.weight(.medium))
        }
    }
}

private struct DetailTitlePositionKey: PreferenceKey {
    nonisolated static let defaultValue = CGFloat.greatestFiniteMagnitude

    nonisolated static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    NavigationStack {
        GameDetailView(game: PreviewData.games[0], service: PreviewGameService())
    }
    .environment(PreviewData.favoriteStore())
    .preferredColorScheme(.dark)
}
