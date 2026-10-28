//
//  NowPlayingView.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 10/27/26.
//

import SwiftUI

struct NowPlayingView: View {
    let music: MusicController

    var body: some View {
        HStack(spacing: 16) {
            ArtworkView(image: music.artwork, cornerRadius: 10)
                .frame(width: 52, height: 52)
            VStack(alignment: .leading, spacing: 2) {
                Text(music.title ?? "Nothing playing")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(music.artist ?? "Open Music or Spotify")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 14) {
                controlButton("backward.fill", action: music.previousTrack)
                controlButton(music.isPlaying ? "pause.fill" : "play.fill", action: music.playPause)
                controlButton("forward.fill", action: music.nextTrack)
            }
            .disabled(music.activeApp == nil)
        }
        .padding(.horizontal, 24)
        .onAppear {
            if music.title == nil{
                music.refresh()
            }
        }
    }

    private func controlButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
