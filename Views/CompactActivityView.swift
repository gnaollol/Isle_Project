// Showcases current activity minimally
//  CompactActivityView.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 10/28/26.
//
import SwiftUI

struct CompactActivityView: View {
    let music: MusicController
    let notchWidth: CGFloat
    let height: CGFloat
    
    var body: some View{
        HStack(spacing: 0){
            ArtworkView(image: music.artwork, cornerRadius: 6)
                .frame(width: height - 10, height: height - 10)
            
            Spacer(minLength: notchWidth)
            
            MusicBarsView(isPlaying: music.isPlaying, color: music.artworkColor)
                .frame(width: height - 14, height: height - 16)
        }
        .padding(.horizontal, 8)
    }
}
