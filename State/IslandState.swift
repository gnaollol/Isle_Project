//
//  IslandState.swift
//  MyApp
//
//  Created by Gian Lardizabal on 10/26/26.
//

import SwiftUI

@Observable
final class IslandState {
    var isExpanded = false

    let closedSize: CGSize
    let expandedSize = CGSize(width: 400, height: 120)
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

    var currentSize: CGSize {
        if isExpanded { return expandedSize }
        if showsActivity { return compactSize }
        return closedSize
    }
}
