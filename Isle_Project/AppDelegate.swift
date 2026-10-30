//
//  AppDelegate.swift
//  MyApp
//
//  Created by Gian Lardizabal on 10/26/26.
//
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: NotchPanel?
    private let music = MusicController()
    private let calendar = CalendarService()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        music.refresh()
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
        
        panel = NotchPanel(screen: screen, music: music, calendar: calendar)
        panel?.orderFrontRegardless()
    }
}
