//
//  Isle_Project.swift
//  MyApp
//
//  Created by Gian Lardizabal on 10/26/26.
//
import SwiftUI

struct IslandView: View {
    let state: IslandState
    let music: MusicController

    private var showsCompact: Bool {
        state.showsActivity && !state.isExpanded
    }

    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                CompactActivityView(
                    music: music,
                    notchWidth: state.closedSize.width,
                    height: state.closedSize.height
                )
                .frame(width: state.compactSize.width, height: state.closedSize.height)
                .opacity(showsCompact ? 1 : 0)
                .blur(radius: showsCompact ? 0 : 4)
                .animation(.easeOut(duration: 0.2), value: showsCompact)
                .allowsHitTesting(false)

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
            .padding(.horizontal, state.topRadius) // room for the shoulders
            .background(Color.black)
            .clipShape(NotchShape(bottomRadius: state.bottomRadius, topRadius: state.topRadius))
            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: state.showsActivity)
            .onChange(of: state.isExpanded) { _, isExpanded in
                guard isExpanded else { return }
                if music.title == nil {
                    music.refresh()
                } else {
                    music.syncPosition() 
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
