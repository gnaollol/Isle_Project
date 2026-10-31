//  Controller that knows what's playing and can control it
//  NowPlayingSource.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 10/31/26.
//

import Foundation

struct NowPlayingInfo{
    var title: String?
    var artist: String?
    var isPlaying: Bool
    var appName: String
    
    protocol NowPlayingSource: AnyObject {
        var onChange: ((NowPlayingInfo) -> Void) { get set }
        
        func start()
        func stop()
        
        func currentInfo() async -> NowPlayingInfo?
        
        func currentPosition() async -> (position: TimeInterval, duration: TimeInterval)?
        
        func artworkData() async -> Data?
        
        func playPause()
        func nextTrack()
        func previousTrack()
        func seek(to seconds: TimeInterval)
    }
}
