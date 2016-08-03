//
//  PathOverlay.swift
//  Observe
//
//  Created by Robert Stewart on 7/26/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import Foundation
import MapKit

class PathOverlay : NSObject, MKOverlay {
    
    @objc var coordinate: CLLocationCoordinate2D
    @objc var boundingMapRect: MKMapRect
    var coordinate2: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D, boundingMapRect: MKMapRect, point2: CLLocationCoordinate2D){
        self.coordinate = coordinate
        self.boundingMapRect = boundingMapRect
        self.coordinate2 = point2
    }
    
}
