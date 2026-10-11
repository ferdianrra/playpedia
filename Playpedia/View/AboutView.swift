//
//  AboutView.swift
//  Playpedia
//
//  Created by Ferdiansyah Annora on 11/10/26.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 24) {
                    Image("myPhoto")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 170, height: 170)
                        .clipShape(Circle())
                        .overlay { Circle().strokeBorder(Color.accent.opacity(0.6), lineWidth: 3) }
                        .accessibilityLabel("Photo of Ferdiansyah Annora")
                        .padding(.top, 32)
                    VStack(spacing: 10) {
                        Text("Ferdiansyah Annora")
                            .font(.title2.weight(.medium))
                            .multilineTextAlignment(.center)
                        Text("Playpedia developer")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                    }
                    VStack(alignment: .leading, spacing: 14) {
                        Text("About me")
                            .font(.headline.weight(.medium))
                        Text("I'm Ferdiansyah Annora. I built Playpedia as part of my "
                             + "iOS development course at Dicoding.")
                        Text("Playpedia lets you browse games, read their details, "
                             + "and keep a list of your favorites.")
                            .foregroundStyle(Color.textSecondary)
                    }
                    .font(.subheadline)
                    .lineSpacing(5)
                    .padding(22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 22))
                    VStack(spacing: 8) {
                        Label("Playpedia", systemImage: "gamecontroller.fill")
                            .font(.body.weight(.medium))
                        Text("Version 1.0 · Built with SwiftUI")
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                        Link("Game data and artwork from RAWG ↗", destination: URL(string: "https://rawg.io")!)
                            .font(.caption)
                            .foregroundStyle(Color.accent)
                    }
                }
                .foregroundStyle(Color.textPrimary)
                .padding(24)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
    .tint(Color.accent)
    .preferredColorScheme(.dark)
}
