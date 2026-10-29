//
//  MusicBarView.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 10/27/26.
//  Edited by Claude Code on 10/28/26 @ 10:34PM

import SwiftUI

struct MusicBarsView: View {
    let isPlaying: Bool
    let color: Color?

    private let speeds: [Double] = [5.1, 6.7, 4.3, 7.9]
    private let offsets: [Double] = [0, 1.7, 3.1, 4.6]

    var body: some View {
        TimelineView(.animation(paused: !isPlaying)) { context in
            let time = context.date.timeIntervalSinceReferenceDate

            GeometryReader { geometry in
                HStack(alignment: .center, spacing: 3) {
                    ForEach(speeds.indices, id: \.self) { index in
                        Capsule()
                            .fill(color ?? .white.opacity(0.85))
                            .frame(width: 2, height: barHeight(index, time: time, maxHeight: geometry.size.height))
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: isPlaying)
        .animation(.easeInOut(duration: 0.4), value: color)
    }

    private func barHeight(_ index: Int, time: Double, maxHeight: CGFloat) -> CGFloat {
        guard isPlaying else { return 3 }
        let wave = abs(cos(time * speeds[index] + offsets[index]))
        return maxHeight * (0.3 + 0.7 * wave)
    }
}
