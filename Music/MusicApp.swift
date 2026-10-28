//  Information about music & Spotify
//  MusicApp.swift
//  MyApp
//
//  Created by Gian Lardizabal on 10/27/26.
//

import AppKit

enum MusicApp: String, CaseIterable {
    case appleMusic = "Music"
    case spotify = "Spotify"
    
    var bundleID: String {
        switch self {
        case .appleMusic: "com.apple.Music"
        case .spotify: "com.spotify.client"
        }
    }
    
    var notificationName: Notification.Name {
        switch self {
        case .appleMusic: Notification.Name("com.apple.Music.playerInfo")
        case .spotify: Notification.Name("com.spotify.client.PlaybackStateChanged")
        }
    }
    
    var isRunning: Bool {
        !NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).isEmpty
    }
    
    // AppleScript doesn't allow a statement to continue onto the next line,
    // so the `return` line must stay on one line.
    var statusScript: String {
        """
        tell application "\(rawValue)"
            if player state is stopped then return ""
            set trackInfo to (name of current track) & linefeed & (artist of current track)
            return trackInfo & linefeed & (player state as string)
        end tell
        """
    }
}
