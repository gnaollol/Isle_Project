// Detects music changes
// Gets song title & artist
// Determies if  music is playing or paused
// Updates interface
// Controls (play, pause, next, previous)
// Clears song info when music app closes
//
//  MusicController.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 10/27/26.
//

import AppKit
import SwiftUI

@Observable
final class MusicController {
    var title: String?
    var artist: String?
    var isPlaying = false
    private(set) var activeApp: MusicApp?
    @ObservationIgnored
    private var observers: [(center: NotificationCenter, token: NSObjectProtocol)] = []

    init() {
        for app in MusicApp.allCases {
            let center = DistributedNotificationCenter.default()
            
            let token = center.addObserver(
                forName: app.notificationName,
                object: nil,
                queue: .main
            ) { [ weak self ] notification in
                self?.handle(notification.userInfo, from: app)
            }
            
            observers.append((center,token))
        }
        let workspaceCenter = NSWorkspace.shared.notificationCenter
        
        let workspaceToken = workspaceCenter.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil,
            queue: .main
        ) { [ weak self ] notification in
            let quitApp = notification.userInfo?[
                NSWorkspace.applicationUserInfoKey
            ] as? NSRunningApplication
            if quitApp?.bundleIdentifier == self?.activeApp?.bundleID {
                self?.clear()
            }
        }
        observers.append((workspaceCenter,workspaceToken))
    }
        deinit {
            for(center, token) in observers {
                center.removeObserver(token)
        }
    }


    func refresh() {
        for app in MusicApp.allCases where app.isRunning {
            guard let result = runScript(app.statusScript) else { continue }
            let lines = result.components(separatedBy: "\n")
            guard lines.count == 3 else { continue }

            apply(title: lines[0], artist: lines[1], playing: lines[2] == "playing", from: app)
            if isPlaying { break }
        }
    }

    private func handle(_ info: [AnyHashable: Any]?, from app: MusicApp) {
        let state = info?["Player State"] as? String

        if state == "Stopped" {
            if activeApp == app { clear() }
            return
        }

        apply(
            title: info?["Name"] as? String,
            artist: info?["Artist"] as? String,
            playing: state == "Playing",
            from: app
        )
    }

    private func apply(title: String?, artist: String?, playing: Bool, from app: MusicApp) {
        if !playing, let activeApp, activeApp != app, isPlaying { return }

        self.title = title
        self.artist = artist
        self.isPlaying = playing
        self.activeApp = app
    }

    private func clear() {
        title = nil
        artist = nil
        isPlaying = false
        activeApp = nil
    }

    func playPause() { send("playpause") }
    func nextTrack() { send("next track") }
    func previousTrack() { send("previous track") }

    private func send(_ command: String) {
        guard let app = activeApp, app.isRunning else { return }
        runScript("tell application \"\(app.rawValue)\" to \(command)")
    }

    @discardableResult
    private func runScript(_ source: String) -> String? {
        var error: NSDictionary?
        let result = NSAppleScript(source: source)?.executeAndReturnError(&error)
        if let error { print("AppleScript error:", error) }
        return result?.stringValue
    }
}
