//
//  IslandState.swift
//  MyApp
//
//  Created by Gian Lardizabal on 10/26/26.
//

import SwiftUI
enum islandPage: Int, CaseIterable{
    case music
    case calendar
    
    var icon: String{
        switch self{
        case .music: "music.note"
        case .calendar: "calendar"
        }
    }
}

@Observable
final class IslandState {
    var isExpanded = false
    var page: IslandPage = .music
    var pageDragOffset: CGFloat = 0

    let closedSize: CGSize
    let expandedSize = CGSize(width: 420, height: 230)
    let music: MusicController

    init(notchSize: CGSize, music: MusicController) {
        closedSize = notchSize
        self.music = music
    }

    var showsActivity: Bool {
        music.isPlaying && music.title != nil
    }

    var compactSize: CGSize {
        let wing = closedSize.height + 6
        return CGSize(width: closedSize.width + wing * 2, height: closedSize.height)
    }
    
    var bottomRadius: CGFloat{
        isExpanded ? 28 : 10
    }
    
    var topRadius: CGFloat {
        isExpanded ? 14 : 6
    }
    
    var currentSize: CGSize {
        if isExpanded { return expandedSize }
        if showsActivity { return compactSize }
        return closedSize
    }
}
