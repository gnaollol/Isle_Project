//
//  StatusMenu.swift
//  MyApp
//
//  Created by Gian Lardizabal on 10/26/26.
//
import SwiftUI
import AppKit


struct StatusMenu: View {
    var body: some View {
        Button("Quit App") {
            NSApplication.shared.terminate(nil)
        }
        Button("Settings"){
           // NSApplication.shared
        }
        Button("Launch at Login"){
            //
        }
        .keyboardShortcut("q")
    }
}
