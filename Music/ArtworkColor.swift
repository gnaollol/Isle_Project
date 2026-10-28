// Detects colors of album
//  ArtworkColor.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 10/28/26.
//

import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins

enum ArtworkColor {
    private static let context = CIContext(options: [.workingColorSpace: NSNull()])

    static func from(_ data: Data) -> NSColor? {
        guard let image = CIImage(data: data) else { return nil }

        let filter = CIFilter.areaAverage()
        filter.inputImage = image
        filter.extent = image.extent
        guard let output = filter.outputImage else { return nil }

        var pixel = [UInt8](repeating: 0, count: 4)
        context.render(
            output,
            toBitmap: &pixel,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)
        )
        let average = NSColor(
            srgbRed: CGFloat(pixel[0]) / 255,
            green: CGFloat(pixel[1]) / 255,
            blue: CGFloat(pixel[2]) / 255,
            alpha: 1
        )

        
        return NSColor(
            hue: average.hueComponent,
            saturation: min(average.saturationComponent * 1.4, 1),
            brightness: max(average.brightnessComponent, 0.8),
            alpha: 1
        )
    }
}
