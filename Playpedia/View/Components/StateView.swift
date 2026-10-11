//
//  StateView.swift
//  Playpedia
//
//  Created by Ferdiansyah Annora on 11/10/26.
//

import SwiftUI

struct StateView: View {
    let symbol: String
    let title: String
    let message: String
    var actionTitle = "Try again"
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 38))
                .foregroundStyle(Color.accent)
            Text(title).font(.title3.weight(.medium)).foregroundStyle(Color.textPrimary)
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.textSecondary)
            if let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.accent)
                    .foregroundStyle(Color.appBackground)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}

#Preview("Empty") {
    StateView(symbol: "heart", title: "No favorites yet", message: "Save a game to see it here.")
        .background(Color.appBackground)
}

#Preview("Error") {
    StateView(
        symbol: "wifi.exclamationmark",
        title: "Unable to load games",
        message: "Check your internet connection and try again."
    ) {}
    .background(Color.appBackground)
}
