//
//  NotchPanel.swift
//  MyApp
//
//  Created by Gian Lardizabal on 10/26/26.
//

import AppKit
import SwiftUI


final class NotchPanel: NSPanel {
    private let state: IslandState
    private let screenFrame: NSRect
    private var tracker: MouseTracker?
    
    private let hoverPadding: CGFloat = 8
    
    init(screen: NSScreen){
        state = IslandState(notchSize: screen.notchSize)
        screenFrame = screen.frame
        
        let canvas = NSSize(width: 640, height: 240)
        let frame = NSRect(
            x: screen.frame.midX - canvas.width / 2,
            y: screen.frame.maxY - canvas.height,
            width: canvas.width,
            height: canvas.height
        )
        
        super.init(
            contentRect: frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        isMovable = false
        level = .mainMenu + 3
        collectionBehavior = [
            .canJoinAllSpaces,
            .stationary,
            .fullScreenAuxiliary,
            .ignoresCycle
        ]
        
        ignoresMouseEvents = true
        acceptsMouseMovedEvents = true
        
        contentView = NSHostingView(rootView: IslandView(state: state))
        
        tracker = MouseTracker { [weak self] point in
            self?.mouseMoved(to: point)
        }
        tracker?.start()
    }
    
    override var canBecomeKey: Bool { true }
    
    override func close(){
        tracker?.stop()
        tracker = nil
        super.close()
    }
    
    private func mouseMoved(to point: NSPoint) {
        let isOverIsland = islandRect().contains(point)
        
        ignoresMouseEvents = !isOverIsland
        
        if isOverIsland != state.isExpanded {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)){
                state.isExpanded = isOverIsland
            }
        }
    }
    
    private func islandRect() -> NSRect {
        let size = state.currentSize
        let rect = NSRect(
            x: screenFrame.midX - size.width / 2,
            y: screenFrame.maxY - size.height,
            width: size.width,
            height: size.height
        )
        return rect.insetBy(dx: -hoverPadding, dy: -hoverPadding)
    }
}
