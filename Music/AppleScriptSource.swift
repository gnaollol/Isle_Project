//  Gets music info from Apple Music & Spotify
//  AppleScriptSource.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 10/31/26.
//

import AppKit

final class AppleScriptSource: NowPlayingSource {
    var onChange: ((NowPlayingInfo?) -> Void)?

    private var activeApp: MusicApp?
    private var activeIsPlaying = false

    private var observers: [(center: NotificationCenter, token: NSObjectProtocol)] = []

    nonisolated private static let scriptQueue = DispatchQueue(label: "AppleScriptSource.scripts")


    func start() {
        guard observers.isEmpty else { return }

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
                guard let self, bundleID == self.activeApp?.bundleID else { return }
                self.activeApp = nil
                self.activeIsPlaying = false
                self.onChange?(nil)
            }
        }
        observers.append((workspace, token))
    }

    func stop() {
        for (center, token) in observers {
            center.removeObserver(token)
        }
        observers.removeAll()
    }

    deinit {
        for (center, token) in observers {
            center.removeObserver(token)
        }
    }

    private func handle(_ userInfo: [AnyHashable: Any]?, from app: MusicApp) {
        let state = userInfo?["Player State"] as? String

        if state == "Stopped" {
            if activeApp == app {
                activeApp = nil
                activeIsPlaying = false
                onChange?(nil)
            }
            return
        }

        let info = NowPlayingInfo(
            title: userInfo?["Name"] as? String,
            artist: userInfo?["Artist"] as? String,
            isPlaying: state == "Playing",
            appName: app.rawValue
        )
        report(info, from: app)
    }

    private func report(_ info: NowPlayingInfo, from app: MusicApp) {
        if !info.isPlaying, let activeApp, activeApp != app, activeIsPlaying { return }
        activeApp = app
        activeIsPlaying = info.isPlaying
        onChange?(info)
    }


    func currentInfo() async -> NowPlayingInfo? {
        var paused: (app: MusicApp, info: NowPlayingInfo)?

        for app in MusicApp.allCases where app.isRunning {
            guard let output = await Self.runScript(app.statusScript)?.text else { continue }
            let lines = output.components(separatedBy: "\n")
            guard lines.count == 3 else { continue }

            let info = NowPlayingInfo(title: lines[0], artist: lines[1], isPlaying: lines[2] == "playing", appName: app.rawValue)

            if info.isPlaying {
                activeApp = app
                activeIsPlaying = true
                return info
            }
            paused = paused ?? (app, info)
        }

        guard let paused else { return nil }
        activeApp = paused.app
        activeIsPlaying = false
        return paused.info
    }

    func currentPosition() async -> (position: TimeInterval, duration: TimeInterval)? {
        guard let app = activeApp, app.isRunning,
              let output = await Self.runScript(app.positionScript)?.text else { return nil }
        let values = output.split(separator: "\n").compactMap { Double($0) }
        guard values.count == 2 else { return nil }
        return (values[0] / 1000, values[1] / 1000)
    }

    func artworkData() async -> Data? {
        guard let app = activeApp, app.isRunning else { return nil }
        switch app {
        case .appleMusic:
            return await Self.runScript("tell application \"Music\" to get raw data of artwork 1 of current track")?.data
        case .spotify:
            guard let link = await Self.runScript("tell application \"Spotify\" to get artwork url of current track")?.text,
                  let url = URL(string: link),
                  let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
            return data
        }
    }


    func playPause() { send("playpause") }
    func nextTrack() { send("next track") }
    func previousTrack() { send("previous track") }
    func seek(to seconds: TimeInterval) { send("set player position to \(Int(seconds))") }

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
