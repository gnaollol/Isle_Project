//
//  NotchPanel.swift
//  MyApp
//
//  Created by Gian Lardizabal on 10/26/26.
//

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
    private var scrollMonitor: Any?

    private var swipeDistance: CGFloat = 0
    private let swipeThreshold: CGFloat = 60
    
    private let hoverPadding: CGFloat = 8
    
    init(screen: NSScreen, music: MusicController, calendar: CalendarService) {
        state = IslandState(notchSize: screen.notchSize, music: music)
        screenFrame = screen.frame
        
        let canvas = NSSize(width: 640, height: 280)
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
        
        contentView = IslandHostingView(rootView: IslandView(state: state, music: music, calendar: calendar))
        
        tracker = MouseTracker { [weak self] point in
            self?.mouseMoved(to: point)
        }
        tracker?.start()

       
        scrollMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [weak self] event in
            self?.handleScroll(event)
            return event
        }
    }
    
    override var canBecomeKey: Bool { true }
    
    override func close(){
        tracker?.stop()
        tracker = nil
        if let scrollMonitor {
            NSEvent.removeMonitor(scrollMonitor)
        }
        scrollMonitor = nil
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
    
   
    private func handleScroll(_ event: NSEvent) {
        guard state.isExpanded else { return }

        guard !event.phase.isEmpty, event.momentumPhase.isEmpty else { return }

        switch event.phase {
        case .began:
            swipeDistance = 0
        case .changed:
            let fingerDelta = event.isDirectionInvertedFromDevice ? event.scrollingDeltaX : -event.scrollingDeltaX
            swipeDistance += fingerDelta
            state.pageDragOffset = resisted(swipeDistance)
        case .ended, .cancelled:
            finishSwipe()
        default:
            break
        }
    }


    private func resisted(_ distance: CGFloat) -> CGFloat {
        let isFirst = state.page.rawValue == 0
        let isLast = state.page.rawValue == IslandPage.allCases.count - 1
        if (isFirst && distance > 0) || (isLast && distance < 0) {
            return distance * 0.25
        }
        return distance
    }

    private func finishSwipe() {
        var index = state.page.rawValue
        if swipeDistance < -swipeThreshold { index += 1 }
        if swipeDistance > swipeThreshold { index -= 1 }
        index = min(max(index, 0), IslandPage.allCases.count - 1)

        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            state.page = IslandPage.allCases[index]
            state.pageDragOffset = 0
        }
        swipeDistance = 0
    }

    private func islandRect() -> NSRect {
        let size = state.currentSize
        let width = size.width + state.topRadius * 2
        let rect = NSRect(
            x: screenFrame.midX - width / 2,
            y: screenFrame.maxY - size.height,
            width: width,
            height: size.height
        )
        return rect.insetBy(dx: -hoverPadding, dy: -hoverPadding)
    }
}

final class IslandHostingView<Content: View>: NSHostingView<Content>{
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}
