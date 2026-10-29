// Shape of the notch
//  NotchShape.swift
//  MyApp
//
//  Created by Gian Lardizabal on 10/26/26.
//
import SwiftUI

struct NotchShape: Shape{
    var bottomRadius: CGFloat
    var topRadius: CGFloat
    
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(bottomRadius, topRadius)}
        set {
            bottomRadius = newValue.first
            topRadius = newValue.second
        }
    }
    
    
    func path(in rect: CGRect) -> Path {
        let left = rect.minX + topRadius
        let right = rect.maxX - topRadius
        
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        
        path.addQuadCurve(to: CGPoint(x: left, y: rect.minY + topRadius), control: CGPoint(x: left, y: rect.minY)
                          )
        path.addLine(to: CGPoint(x: left, y: rect.maxY - bottomRadius))
        
        path.addQuadCurve(to: CGPoint(x: left + bottomRadius, y: rect.maxY), control: CGPoint(x: left, y: rect.maxY))
        
        path.addLine(to: CGPoint(x: right - bottomRadius, y: rect.maxY))
        
        path.addQuadCurve(to: CGPoint(x: right, y: rect.maxY - bottomRadius), control: CGPoint(x: right, y: rect.maxY))
        
        path.addLine(to: CGPoint(x: right, y: rect.minY + topRadius))
        
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control: CGPoint(x: right, y: rect.minY))
        
        path.closeSubpath()
        return path
    }
}

#Preview {
    NotchShape(bottomRadius: 28, topRadius: 14)
        .fill(.black)
        .frame(width: 300, height: 120)
        .padding()
}
