//
//  Untitled.swift
//  MyApp
//
//  Created by Gian Lardizabal on 10/26/26.
//
import SwiftUI

struct IslandView: View {
    let state: IslandState

    var body: some View {
        VStack {
            NotchShape(radius: state.isExpanded ? 24 : 10)
                .fill(.black)
                .frame(width: state.currentSize.width, height: state.currentSize.height)

            Spacer() 
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    IslandView(state: IslandState(notchSize: CGSize(width: 200, height: 32)))
        .frame(width: 640, height: 240)
        .background(.gray)
}
