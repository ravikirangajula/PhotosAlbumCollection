/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Utility functions for helping display the user interface.
*/

import UIKit

extension CGRect {
    func dividedIntegral(fraction: CGFloat, from fromEdge: CGRectEdge) -> (first: CGRect, second: CGRect) {
        let dimension: CGFloat
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            dimension = self.size.width
        case .minYEdge, .maxYEdge:
            dimension = self.size.height
        }
        
        let distance = (dimension * fraction).rounded(.up)
        var slices = self.divided(atDistance: distance, from: fromEdge)
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            slices.remainder.origin.x += 5
            slices.remainder.size.width -= 5
        case .minYEdge, .maxYEdge:
            slices.remainder.origin.y += 5
            slices.remainder.size.height -= 5
        }
        
        return (first: slices.slice, second: slices.remainder)
    }
    func dividedIntegral4(fraction: CGFloat, from fromEdge: CGRectEdge) -> (first: CGRect, second: CGRect,third: CGRect) {
        let dimension: CGFloat
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            dimension = self.size.width
        case .minYEdge, .maxYEdge:
            dimension = self.size.height
        }
        
        
        let distance = (dimension * fraction).rounded(.up)
        var slices = self.divided(atDistance: distance, from: fromEdge)
        
        let fromEdge2 = slices.slice.maxX
        let secndSlice = CGRect(x: fromEdge2 + 5, y: slices.slice.minY, width: distance - 5, height: height)

        let fromEdge3 = secndSlice.maxX
        let secndSlice3 = CGRect(x: fromEdge3 + 5, y: slices.slice.minY, width: distance - 5, height: height)
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            slices.remainder.origin.x += 5
            slices.remainder.size.width -= 5
        case .minYEdge, .maxYEdge:
            slices.remainder.origin.y += 5
            slices.remainder.size.height -= 5
        }
        
        return (first: slices.slice, second: secndSlice, third: secndSlice3)
    }

}

extension UIColor {
    static let appBackgroundColor = #colorLiteral(red: 0.05882352941, green: 0.09019607843, blue: 0.1098039216, alpha: 1)
}
