//
//  ArtworkView.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 10/27/26.
//

import SwiftUI

struct ArtworkView: View{
    let image: NSImage?
    let cornerRadius: CGFloat
    
    var body: some View{
        ZStack {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.white.opacity(0.15)
                Image(systemName: "music.note")
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
