//
//  SettingsView.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 11/1/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKeys.useExtendedMediaSupport) private var isExtendedMediaEnabled = false
    
    var body: some View{
        Form{
            Section("Media"){
                Toggle("Extended Media Support", isOn: $isExtendedMediaEnabled)
                Text("Will look for a wider array of multimedia activity like podcasts or videos. (EXPERIMENTAL: May fail when Apple updates)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 420)
    }
}

#Preview{
    SettingsView()
}


