//  Finds the next calendar events.
//  UpNextWidget.swift
//  Isle_Project
//
//  Created by Claude on 10/29/26 @ 10:39 PM
//

import SwiftUI

struct UpNextWidget: View {
    let calendar: CalendarService

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Up Next")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.55))

            if !calendar.hasAccess {
                note("Allow calendar access in System Settings → Privacy & Security → Calendars.")
            } else if calendar.upcoming.isEmpty {
                note("Nothing coming up this week.")
            } else {
                ForEach(calendar.upcoming) { event in
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(event.color)
                            .frame(width: 4)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text(event.subtitle)
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.55))
                                .lineLimit(1)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 4)
    }

    private func note(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundStyle(.white.opacity(0.55))
    }
}
