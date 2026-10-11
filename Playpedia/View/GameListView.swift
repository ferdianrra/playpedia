//
//  GameListView.swift
//  Playpedia
//
//  Created by Ferdiansyah Annora on 11/10/26.
//

import SwiftUI

struct GameListView: View {
    @State private var viewModel: GameListViewModel
    private let service: any GameService

    init(service: (any GameService)? = nil) {
        let service = service ?? NetworkService()
        self.service = service
        _viewModel = State(initialValue: GameListViewModel(service: service))
    }

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    orderPicker
                    gameList
                }
                .padding(20)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
            }
            .refreshable { await viewModel.loadGames() }
        }
        .navigationTitle("Playpedia")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, prompt: "Search games")
        .task(id: viewModel.queryID) {
            await viewModel.loadGames(debounce: !viewModel.searchText.isEmpty)
        }
        .navigationDestination(for: Game.self) { game in
            GameDetailView(game: game, service: service)
        }
    }

    private var orderPicker: some View {
        HStack {
            Text(viewModel.searchText.isEmpty ? "Games" : "Search results")
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.textPrimary)
            Spacer()
            Menu {
                Picker("Sort games", selection: $viewModel.order) {
                    ForEach(GameOrder.allCases) { order in
                        Text(order.title).tag(order)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(viewModel.order.title)
                    Image(systemName: "chevron.down")
                }
                .font(.subheadline)
                .foregroundStyle(Color.textPrimary)
                .padding(12)
                .background(Color.cardBackground, in: Capsule())
                .overlay {
                    Capsule().strokeBorder(Color.textSecondary.opacity(0.25))
                }
            }
            .accessibilityLabel("Sort by: \(viewModel.order.title)")
        }
    }

    @ViewBuilder
    private var gameList: some View {
        if viewModel.isLoading {
            ProgressView("Loading games…")
                .tint(Color.accent)
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity, minHeight: 240)
        } else if viewModel.games.isEmpty, let error = viewModel.errorMessage {
            StateView(symbol: "wifi.exclamationmark", title: "Unable to load games", message: error) {
                Task { await viewModel.loadGames() }
            }
        } else if viewModel.games.isEmpty {
            StateView(
                symbol: "magnifyingglass",
                title: "No games found",
                message: "Try another title or a shorter search term."
            )
        } else {
            LazyVStack(spacing: 18) {
                ForEach(viewModel.games) { game in
                    NavigationLink(value: game) {
                        GameCard(game: game)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        Task { await viewModel.loadMoreIfNeeded(after: game) }
                    }
                }
                if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                        Button("Try again") {
                            Task { await viewModel.loadNextPage() }
                        }
                        .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                } else if viewModel.hasNextPage {
                    ProgressView()
                        .accessibilityLabel("Loading more games")
                        .tint(Color.accent)
                        .foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        GameListView(service: PreviewGameService())
    }
    .environment(PreviewData.favoriteStore())
    .tint(Color.accent)
    .preferredColorScheme(.dark)
}
