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
            ZStack(alignment: .top) {
                Color.black

               
                NowPlayingView(music: music)
                    .frame(
                        width: state.expandedSize.width,
                        height: state.expandedSize.height - state.closedSize.height
                    )
                    .padding(.top, state.closedSize.height)
                    .opacity(state.isExpanded ? 1 : 0)
                    .blur(radius: state.isExpanded ? 0 : 6)
                    .scaleEffect(state.isExpanded ? 1 : 0.9, anchor: .top)
                    .animation(
                        state.isExpanded
                            ? .easeOut(duration: 0.25).delay(0.1)
                            : .easeOut(duration: 0.2),
                        value: state.isExpanded
                    )
                    .allowsHitTesting(state.isExpanded)
            }
            .frame(width: state.currentSize.width, height: state.currentSize.height, alignment: .top)
            .clipShape(NotchShape(radius: state.isExpanded ? 24 : 10))
            .onChange(of: state.isExpanded) { _, isExpanded in
                if isExpanded && music.title == nil {
                    music.refresh()
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
