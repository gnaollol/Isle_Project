//
//  StatusMenu.swift
//  MyApp
//
//  Created by Gian Lardizabal on 10/26/26.
//
import SwiftUI
import AppKit


struct StatusMenu: View {
    @Environment(\.openSettings) private var openSettings
    
    var body: some View {
        Button("Settings") {
            NSApplication.shared.activate()
            openSettings()
        }
        .keyboardShortcut(",")
        Divider()
        
        Button("Quit App"){
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
        
    }
}

