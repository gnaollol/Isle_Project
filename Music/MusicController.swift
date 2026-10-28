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

@MainActor
@Observable
final class MusicController {
    var title: String?
    var artist: String?
    var isPlaying = false
    private(set) var activeApp: MusicApp?
    var artwork: NSImage?
    var artworkColor: Color?
    @ObservationIgnored
    private var artworkTrack: String?
    
    @ObservationIgnored
    private var observers: [(center: NotificationCenter, token: NSObjectProtocol)] = []
    
    // After play/pause, Music first re-sends the OLD state, then the new one ~60ms later.
    // Until the expected state arrives (or the deadline passes), stale updates are ignored.
    @ObservationIgnored
    private var pendingPlayState: (isPlaying: Bool, deadline: Date)?
    
    
    nonisolated private static let scriptQueue = DispatchQueue(label: "MusicController.scripts")
    
    init() {
        
        let distributed = DistributedNotificationCenter.default()
        for app in MusicApp.allCases {
            let token = distributed.addObserver(
                forName: app.notificationName,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                let info = notification.userInfo
                MainActor.assumeIsolated {
                    self?.handle(info, from: app)
                }
            }
            observers.append((distributed, token))
        }
        
        
        let workspace = NSWorkspace.shared.notificationCenter
        let token = workspace.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let quitApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            let bundleID = quitApp?.bundleIdentifier
            MainActor.assumeIsolated {
                if bundleID == self?.activeApp?.bundleID {
                    self?.clear()
                }
            }
        }
        observers.append((workspace, token))
    }
    
    deinit {
        for (center, token) in observers {
            center.removeObserver(token)
        }
    }
    
    
    func refresh() {
        Task {
            var pausedResult: (app: MusicApp, lines: [String])?
            
            for app in MusicApp.allCases where app.isRunning {
                guard let output = await Self.runScript(app.statusScript)?.text else { continue }
                let lines = output.components(separatedBy: "\n")
                guard lines.count == 3 else { continue }
                
                // Prefer whichever app is actually playing
                if lines[2] == "playing" {
                    apply(title: lines[0], artist: lines[1], playing: true, from: app)
                    return
                }
                pausedResult = pausedResult ?? (app, lines)
            }
            
            if let pausedResult {
                apply(title: pausedResult.lines[0], artist: pausedResult.lines[1], playing: false, from: pausedResult.app)
            }
        }
    }
    
    private func handle(_ info: [AnyHashable: Any]?, from app: MusicApp) {
        let state = info?["Player State"] as? String
        
        if state == "Stopped" {
            if activeApp == app { clear() }
            return
        }
        
        let playing = state == "Playing"
        
        if let pending = pendingPlayState, app == activeApp {
            if pending.isPlaying != playing, Date() < pending.deadline {
                return // stale update from before the button press
            }
            pendingPlayState = nil
        }
        
        apply(
            title: info?["Name"] as? String,
            artist: info?["Artist"] as? String,
            playing: playing,
            from: app
        )
    }
    
    private func apply(title: String?, artist: String?, playing: Bool, from app: MusicApp) {
        if !playing, let activeApp, activeApp != app, isPlaying { return }
        
        self.title = title
        self.artist = artist
        self.isPlaying = playing
        self.activeApp = app
        
        if trackKey != artworkTrack {
            loadArtwork(from: app)
        }
    }
    
    private var trackKey: String {
        "\(title ?? "")|\(artist ?? "")"
    }
    
    private func loadArtwork(from app: MusicApp){
        let key = trackKey
        artworkTrack = key
        artwork = nil
        
        Task {
            let data = await Self.fetchArtworkData(from: app)
            guard trackKey == key, let data else { return }
            artwork = NSImage(data: data)
            artworkColor = ArtworkColor.from(data).map { Color(nsColor: $0 )}
        }
    }
    
    nonisolated private static func fetchArtworkData(from app: MusicApp) async -> Data? {
        switch app {
        case .appleMusic:
            return await runScript("tell application \"Music\" to get raw data of artwork 1 of current track")?.data
        case .spotify:
            guard let link = await runScript("tell application \"Spotify\" to get artwork url of current track")?.text,
                  let url = URL(string: link),
                  let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
            return data
        }
    }
    
    private func clear() {
        title = nil
        artist = nil
        isPlaying = false
        activeApp = nil
        artwork = nil
        artworkTrack = nil
        artworkColor = nil
    }
    
    
    func playPause() {
        isPlaying.toggle()
        pendingPlayState = (isPlaying, Date().addingTimeInterval(1))
        send("playpause")
    }
    
    func nextTrack() { send("next track") }
    func previousTrack() { send("previous track") }
    
    private func send(_ command: String) {
        guard let app = activeApp, app.isRunning else { return }
        let source = "tell application \"\(app.rawValue)\" to \(command)"
        Task { await Self.runScript(source) }
    }
    
    @discardableResult
    nonisolated private static func runScript(_ source: String) async -> (text: String?, data: Data)? {
        await withCheckedContinuation { continuation in
            scriptQueue.async {
                var error: NSDictionary?
                guard let result = NSAppleScript(source: source)?.executeAndReturnError(&error) else {
                    if let error { print("AppleScript error:", error) }
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: (result.stringValue, result.data))
            }
        }
    }
}
