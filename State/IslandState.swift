//
//  IslandState.swift
//  MyApp
//
//  Created by Gian Lardizabal on 10/26/26.
//

import SwiftUI
import CoreGraphics

@Observable
final class IslandState{
    var isExpanded = false
    
    let closedSize: CGSize
    let expandedSize = CGSize(width: 400, height: 120)
    
    init(notchSize: CGSize) {
        closedSize = notchSize
    }
    
    var currentSize: CGSize {
        isExpanded ? expandedSize : closedSize
    }
}
