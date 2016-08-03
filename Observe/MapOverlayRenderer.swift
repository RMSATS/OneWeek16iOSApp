//
//  MapOverlayRenderer.swift
//  Observe
//
//  Created by Robert Stewart on 7/26/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation
import MapKit


class MapOverlayRenderer : MKOverlayRenderer {
    
    var coordinate1: CGPoint?
    var coordinate2: CGPoint?
    
    init(overlay: MKOverlay, coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D){
        super.init(overlay: overlay)
        self.coordinate1 = self.pointForMapPoint(MKMapPointForCoordinate(coordinate1))
        self.coordinate2 = self.pointForMapPoint(MKMapPointForCoordinate(coordinate2))
    }
    
    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
        let rect: CGRect = self.rectForMapRect(self.overlay.boundingMapRect)
        let relativePoint1 = calculateRelativePoint(rect, point: coordinate1!)
        let relativePoint2 = calculateRelativePoint(rect, point: coordinate2!)
        
        let cgPath: CGMutablePathRef = CGPathCreateMutable()
        CGPathMoveToPoint(cgPath, nil, relativePoint1.x, relativePoint1.y)
        CGPathAddLineToPoint(cgPath, nil, relativePoint2.x, relativePoint2.y)//rect.width, rect.height)
        CGPathCloseSubpath(cgPath)
 
        CGContextScaleCTM(context, 1.0, 1.0)
        CGContextSetLineWidth(context, 100000)
        CGContextSetStrokeColorWithColor(context, UIColor.greenColor().CGColor)
        CGContextSetFillColorWithColor(context, UIColor.purpleColor().CGColor)
        CGContextAddPath(context, cgPath)
        
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
    }
    
    func calculateRelativePoint(rect: CGRect, point: CGPoint) -> CGPoint {
        let newX: CGFloat = fabs(rect.origin.x - point.x)
        let newY: CGFloat = fabs(rect.origin.y - point.y)
        return CGPointMake(newX, newY)
    }
}
