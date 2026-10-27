//
//  AppDelegate.swift
//  MyApp
//
//  Created by Gian Lardizabal on 10/26/26.
//
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: NotchPanel?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupPanel()
        
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.setupPanel() }
    }
    
    private func setupPanel() {
        panel?.close()
        
        guard let screen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0})
                
                ?? NSScreen.main else { return }
        
        panel = NotchPanel(screen: screen)
        panel?.orderFrontRegardless()
    }
}
