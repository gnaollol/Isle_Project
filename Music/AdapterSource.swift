//  Reads whats playing from any app through media-remote adapter.
//  AdapterSource.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 11/11/26.
//

import AppKit

final class AdapterSource: NowPlayingSource {
    var onChange: ((NowPlayingInfo?) -> Void)?
    var onFailure: (() -> Void)?

    private var process: Process?
    private var buffer = Data()
    private var latest: [String: Any] = [:]

    nonisolated private static let scriptURL = Bundle.main.url(forResource: "mediaremote-adapter", withExtension: "pl")
    nonisolated private static let frameworkURL = Bundle.main.url(forResource: "MediaRemoteAdapter", withExtension: "framework")
    nonisolated private static let testClientURL = Bundle.main.url(forResource: "MediaRemoteAdapterTestClient", withExtension: nil)

    static func isAvailable() async -> Bool {
        guard let testClient = testClientURL?.path else { return false }
        return await run([testClient, "test"])?.status == 0
    }

    func start() {
        guard process == nil else { return }
        guard let script = Self.scriptURL?.path, let framework = Self.frameworkURL?.path else {
            onFailure?()
            return
        }
        Self.killOrphanedStreams(script: script)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/perl")
        process.arguments = [script, framework, "stream", "--no-diff", "--no-artwork", "--micros", "--debounce=100"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if data.isEmpty { handle.readabilityHandler = nil; return }
            DispatchQueue.main.async { MainActor.assumeIsolated { self?.receive(data) } }
        }
        process.terminationHandler = { [weak self] process in
            let status = process.terminationStatus
            DispatchQueue.main.async { MainActor.assumeIsolated { self?.streamEnded(status: status) } }
        }
        do { try process.run() } catch { onFailure?(); return }
        self.process = process
    }
    
    private static func killOrphanedStreams(script: String){
        let pkill = Process()
        pkill.executableURL = URL(fileURLWithPath: "/usr/bin/pkill")
        pkill.arguments = ["-P", "1", "-f", NSRegularExpression.escapedPattern(for: script)]
        
        try? pkill.run()
        pkill.waitUntilExit()
    }

    func stop() {
        process?.terminationHandler = nil
        process?.terminate()
        process = nil
        buffer.removeAll()
        latest = [:]
    }

    private func receive(_ data: Data) {
        buffer.append(data)
        while let newline = buffer.firstIndex(of: UInt8(ascii: "\n")) {
            let line = Data(buffer[..<newline])
            buffer.removeSubrange(...newline)
            handleLine(line)
        }
    }

    private func streamEnded(status: Int32) {
        process = nil
        if status != 0 { onFailure?() }
    }

    private func handleLine(_ line: Data) {
        guard let object = try? JSONSerialization.jsonObject(with: line) as? [String: Any],
              let payload = object["payload"] as? [String: Any] else { return }
        latest = payload
        onChange?(info(from: payload))
    }

    private func info(from payload: [String: Any]) -> NowPlayingInfo? {
        guard let title = payload["title"] as? String, let bundleID = Self.bundleID(in: payload) else { return nil }
        let appName = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).first?.localizedName ?? bundleID
        return NowPlayingInfo(
            title: title,
            artist: payload["artist"] as? String,
            isPlaying: payload["playing"] as? Bool ?? false,
            appName: appName,
            playbackRate: Self.playbackRate(in: payload)
        )
    }

    private static func bundleID(in payload: [String: Any]) -> String? {
        payload["parentApplicationBundleIdentifier"] as? String ?? payload["bundleIdentifier"] as? String
    }
    
    private static func playbackRate(in payload: [String: Any]) -> Double {
            guard let rate = payload["playbackRate"] as? Double, rate > 0 else { return 1 }
            return rate
        }

    func currentInfo() async -> NowPlayingInfo? {
        guard let payload = await Self.get(["--no-artwork", "--micros"]) else { return nil }
        latest = payload
        return info(from: payload)
    }

    func currentPosition() async -> (position: TimeInterval, duration: TimeInterval)? {
        guard let elapsed = latest["elapsedTimeMicros"] as? Double,
              let duration = latest["durationMicros"] as? Double else { return nil }
        var position = elapsed / 1_000_000
        if latest["playing"] as? Bool == true, let timestamp = latest["timestampEpochMicros"] as? Double {
            position += max(Date().timeIntervalSince1970 - timestamp / 1_000_000, 0) * Self.playbackRate(in: latest)        }
        return (position, duration / 1_000_000)
    }

    func artworkData() async -> Data? {
        for attempt in 0..<3 {
            if attempt > 0 { try? await Task.sleep(for: .milliseconds(500)) }
            if let base64 = await Self.get([])?["artworkData"] as? String,
               let data = Data(base64Encoded: base64) {
                return data
            }
        }
        return appIconData()
    }

    private func appIconData() -> Data? {
        guard let bundleID = Self.bundleID(in: latest),
              let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else { return nil }
        return NSWorkspace.shared.icon(forFile: appURL.path).tiffRepresentation
    }

    func playPause() { send(2) }
    func nextTrack() { send(4) }
    func previousTrack() { send(5) }

    func seek(to seconds: TimeInterval) {
        Task { _ = await Self.run(["seek", String(Int(seconds * 1_000_000))]) }   // microseconds
    }

    private func send(_ command: Int) {
        Task { _ = await Self.run(["send", String(command)]) }
    }

    nonisolated private static func get(_ flags: [String]) async -> [String: Any]? {
        guard let output = await run(["get"] + flags)?.output else { return nil }
        return try? JSONSerialization.jsonObject(with: output) as? [String: Any]
    }

    nonisolated private static func run(_ arguments: [String]) async -> (status: Int32, output: Data)? {
        guard let script = scriptURL?.path, let framework = frameworkURL?.path else { return nil }
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/perl")
                process.arguments = [script, framework] + arguments
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = FileHandle.nullDevice
                do { try process.run() } catch {
                    continuation.resume(returning: nil)
                    return
                }
                let output = pipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                continuation.resume(returning: (process.terminationStatus, output))
            }
        }
    }
}
