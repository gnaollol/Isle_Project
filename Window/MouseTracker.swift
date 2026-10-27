//
//  MouseTracker.swift
//  MyApp
//
//  Created by Gian Lardizabal on 10/27/26.
//

import AppKit

final class MouseTracker {
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private let onMove: (NSPoint) -> Void
    
    init(onMove: @escaping (NSPoint) -> Void) {
        self.onMove = onMove
    }
    
    func start(){
        let events: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDragged]
        
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: events)
        { [weak self] _ in
            self?.onMove(NSEvent.mouseLocation)
        }
        
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: events) { [weak self] event in
            self?.onMove(NSEvent.mouseLocation)
            return event
        }
    }
    
    func stop() {
        if let globalMonitor { NSEvent.removeMonitor(globalMonitor) }
        if let localMonitor { NSEvent.removeMonitor(localMonitor) }
        globalMonitor = nil
        localMonitor = nil
    }
    
    deinit {
        stop()
    }
}
