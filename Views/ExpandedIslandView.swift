//  Expanded island
//  ExpandedIslandView.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 10/29/26.
//

import SwiftUI

struct ExpandedIslandView: View {
    let state: IslandState
    let music: MusicController
    let calendar: CalendarService

    var body: some View {
        VStack(spacing: 6) {
            WidgetIconRow(state: state)
            pager
        }
        .padding(.bottom, 14)
    }

    
    private var pager: some View {
        let width = state.expandedSize.width

        return HStack(spacing: 0) {
            ForEach(IslandPage.allCases, id: \.self) { page in
                widget(for: page)
                    .frame(width: width)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: width, alignment: .leading)
        .offset(x: -CGFloat(state.page.rawValue) * width + state.pageDragOffset)
        .clipped()
    }

    @ViewBuilder
    private func widget(for page: IslandPage) -> some View {
        switch page {
        case .music:
            NowPlayingView(music: music)
        case .calendar:
            UpNextWidget(calendar: calendar)
        }
    }
}
    