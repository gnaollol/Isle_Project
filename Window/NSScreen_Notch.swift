//
//  NSScreen_Notch.swift
//  MyApp
//
//  Created by Gian Lardizabal on 10/26/26.
//
import AppKit

extension NSScreen {
    var notchSize: CGSize {
        guard safeAreaInsets.top > 0,
              let leftWidth = auxiliaryTopLeftArea?.width,
              let rightWidth = auxiliaryTopRightArea?.width else {
            return CGSize(width: 200, height: 32)
        }

        return CGSize(
            width: frame.width - leftWidth - rightWidth,
            height: safeAreaInsets.top
        )
    }
}
