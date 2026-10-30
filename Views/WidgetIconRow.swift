// Icon widgets
//  WidgetIconRow.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 10/29/26.
//

import SwiftUI

struct WidgetIconRow: View {
    let state: IslandState

    var body: some View {
        HStack(spacing: 6) {
            ForEach(IslandPage.allCases, id: \.self) { page in
                let isSelected = state.page == page

                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        state.page = page
                    }
                } label: {
                    Image(systemName: page.icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(isSelected ? 1 : 0.45))
                        .frame(width: 30, height: 22)
                        .background(Color.white.opacity(isSelected ? 0.15 : 0), in: Capsule())
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
