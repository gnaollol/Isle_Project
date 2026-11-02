import AppKit
import SwiftUI

@MainActor
@Observable
final class MusicController {
    var title: String?
    var artist: String?
    var isPlaying = false
    private(set) var activeApp: String?
    var artwork: NSImage?
    var artworkColor: Color?
    var duration: TimeInterval = 0
    private(set) var position: TimeInterval = 0
    private(set) var positionDate = Date()

    @ObservationIgnored
    private let source: NowPlayingSource

    @ObservationIgnored
    private var artworkTrack: String?

    @ObservationIgnored
    private var pendingPlayState: (isPlaying: Bool, deadline: Date)?

    init() {
        source = AppleScriptSource()
        source.onChange = { [weak self] info in
            self?.handle(info)
        }
        source.start()
    }


    func refresh() {
        Task {
            if let info = await source.currentInfo() {
                apply(info)
            }
        }
    }

    private func handle(_ info: NowPlayingInfo?) {
        guard let info else {
            clear()
            return
        }

        if let pending = pendingPlayState, info.appName == activeApp {
            if pending.isPlaying != info.isPlaying, Date() < pending.deadline {
                return
            }
            pendingPlayState = nil
        }

        apply(info)
    }

    private func apply(_ info: NowPlayingInfo) {
        freezePosition()
        title = info.title
        artist = info.artist
        isPlaying = info.isPlaying
        activeApp = info.appName
        syncPosition()

        if trackKey != artworkTrack {
            loadArtwork()
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
        duration = 0
        position = 0
    }


    private var trackKey: String {
        "\(title ?? "")|\(artist ?? "")"
    }

    private func loadArtwork() {
        let key = trackKey
        artworkTrack = key
        artwork = nil

        Task {
            let data = await source.artworkData()
            guard trackKey == key, let data else { return }
            artwork = NSImage(data: data)
            artworkColor = ArtworkColor.from(data).map { Color(nsColor: $0) }
        }
    }


    func currentPosition(at date: Date = Date()) -> TimeInterval {
        guard isPlaying else { return position }
        let sinceLastCheck = max(date.timeIntervalSince(positionDate), 0)
        return min(position + sinceLastCheck, duration)
    }

    private func freezePosition() {
        position = currentPosition()
        positionDate = Date()
    }

    func syncPosition() {
        guard let app = activeApp else { return }
        Task {
            guard let result = await source.currentPosition(), app == activeApp else { return }
            position = result.position
            duration = result.duration
            positionDate = Date()
        }
    }

    private func syncPositionSoon() {
        Task {
            try? await Task.sleep(for: .seconds(1))
            syncPosition()
        }
    }


    func playPause() {
        freezePosition()
        isPlaying.toggle()
        pendingPlayState = (isPlaying, Date().addingTimeInterval(1))
        source.playPause()
    }

    func nextTrack() {
        source.nextTrack()
    }

    func previousTrack() {
        if currentPosition() > 3 {
            position = 0
            positionDate = Date()
        }
        source.previousTrack()
        syncPositionSoon()
    }

    func seek(to seconds: TimeInterval) {
        guard activeApp != nil else { return }
        position = seconds
        positionDate = Date()
        source.seek(to: seconds)
    }
}
