// Shows what's currently playing
//  NowPlayingView.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 10/27/26.
//  Edited by Claude Code on 10/28/26 @ 10:17 PM

import SwiftUI

struct NowPlayingView: View {
    let music: MusicController

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                ArtworkView(image: music.artwork, cornerRadius: 12)
                    .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 3) {
                    Text(music.title ?? "Nothing playing")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(music.artist ?? "Open Music or Spotify")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                MusicBarsView(isPlaying: music.isPlaying, color: music.artworkColor)
                    .frame(width: 22, height: 16)
            }

            ProgressBarView(music: music)

            HStack(spacing: 36) {
                controlButton("backward.fill", size: 18, action: music.previousTrack)
                controlButton(music.isPlaying ? "pause.fill" : "play.fill", size: 26, action: music.playPause)
                controlButton("forward.fill", size: 18, action: music.nextTrack)
            }
            .disabled(music.activeApp == nil)
        }
        .padding(.horizontal, 22)
        .onAppear {
            if music.title == nil {
                music.refresh()
            }
        }
    }

    private func controlButton(_ symbol: String, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: size))
                .foregroundStyle(.white)
                .frame(width: 40, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
