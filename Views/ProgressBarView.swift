// Music progress bar
//  ProgressBarView.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 10/28/26.
//

import SwiftUI

struct ProgressBarView: View{
    let music: MusicController
    
    @State private var dragProgress: Double?
    @State private var isHovering = false
    
    private var isActive: Bool {
        isHovering || dragProgress != nil
    }
    
    var body: some View{
        TimelineView(.animation(minimumInterval: 0.5, paused: !music.isPlaying)) { context in
            let duration = music.duration
            let elapsed = dragProgress.map { $0 * duration } ??
            music.currentPosition(at: context.date)
            let progress = duration > 0 ? min(max(elapsed / duration, 0), 1) : 0
            
            HStack(spacing: 10){
                timeLabel(format(elapsed))
                
                GeometryReader { geometry in
                    ZStack(alignment:.leading){
                        Capsule()
                            .fill(.white.opacity(0.2))
                        Capsule()
                            .fill(.white)
                            .frame(width: geometry.size.width * progress)
                    }
                    .frame(height: isActive ? 7 : 4)
                    .frame(maxHeight: .infinity)
                    .contentShape(Rectangle())
                    
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { drag in dragProgress = min(max(drag.location.x/geometry.size.width,0),1)
                            }
                            .onEnded { _ in
                                if let dragProgress {
                                    music.seek(to: dragProgress * duration)
                                }
                                dragProgress = nil
                            }
                    )
                }
                .frame(height: 14)
                timeLabel("-" + format(duration - elapsed))
            }
        }
        .onHover{ isHovering = $0 }
        .animation(.easeOut(duration: 0.15), value: isActive)
        .allowsHitTesting(music.activeApp != nil)
    }
    
    private func timeLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium).monospacedDigit())
            .foregroundStyle(.white.opacity(0.55))
            .frame(minWidth:34)
    }
    
    private func format(_ seconds: TimeInterval) -> String {
        let total = max(Int(seconds), 0)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

