//
//  Untitled.swift
//  MyApp
//
//  Created by Gian Lardizabal on 10/26/26.
//
import SwiftUI

struct IslandView: View {
    let state: IslandState
    let music: MusicController

    var body: some View {
        VStack {
            NotchShape(radius: state.isExpanded ? 24 : 10)
                .fill(.black)
                .frame(width: state.currentSize.width, height: state.currentSize.height)
                .overlay(alignment: .bottom){
                    if state.isExpanded{
                        NowPlayingView(music: music)
                            .frame(height: state.expandedSize.height - state.closedSize.height)
                            .transition(.opacity)
                    }
                }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
