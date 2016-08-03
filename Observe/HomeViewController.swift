//
//  HomeViewController.swift
//  Observe
//
//  Created by Robert Stewart on 7/25/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit
import MapKit
import CoreGraphics

class HomeViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {

    let apiUrl: String = "https://observerestapi.azurewebsites.net/api/users/"
    
    @IBOutlet var idField: UITextField!
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.idField.delegate = self
        self.map.delegate = self
    }

    func getResponseHandler(data: NSData?, response: NSURLResponse?, error: NSError?){
        var previousCoordinate: CLLocationCoordinate2D?
        
        do{
            let dataArray: NSArray = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSArray
            let userObject: NSDictionary = dataArray.firstObject! as! NSDictionary
            let locationArray: [NSDictionary] = userObject["locations"] as! [NSDictionary]
            for locationObject: NSDictionary in locationArray {
                let longitude: Double = locationObject["lon"] as! Double
                let latitude: Double = locationObject["lat"] as! Double
                let name: String = locationObject["name"] as! String
                let date: String = locationObject["datetime"] as! String
                
                
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                dropPin(coordinate, name: name, date: date)
                if isCheckIn(name){
                    if let previousCoordinateUnwrapped: CLLocationCoordinate2D = previousCoordinate {
                        addOverlay(coordinate, coordinate2: previousCoordinateUnwrapped)
                    }
                    previousCoordinate = coordinate
                }
            }
            
        }
        catch _{
            print("Serialization error occurred.")
        }
    }
    
    func isCheckIn(name: String) -> Bool {
        return name != "home" && name != "school"
    }
    
    func getGETRequest(phoneNumber: Int) -> NSMutableURLRequest{
        let requestUrlString = apiUrl + "?phoneNumber=" + String(phoneNumber)
        let requestUrl = NSURL(string: requestUrlString)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: requestUrl)
        request.HTTPMethod = "GET"
        return request
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        idField.resignFirstResponder()
        
        if let phoneNumber: Int = Int(idField!.text!) {
            let request: NSMutableURLRequest = getGETRequest(phoneNumber)
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: configuration)
            
            session.dataTaskWithRequest(request, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                self.getResponseHandler(data, response: response, error: error)
            }).resume()
            
        }
        return false
    }

    func dropPin(coordinate: CLLocationCoordinate2D, name: String, date: String){
        let pin: MKPointAnnotation = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = name
        pin.subtitle = String(date)
        pin
        map.addAnnotation(pin)
    }
    
    // Draw the path between two points on the map
    func addOverlay(coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D){
        let mapRect: MKMapRect = getMapRect(coordinate1, coordinate2: coordinate2)
        let overlay: MKOverlay = PathOverlay(coordinate: coordinate1, boundingMapRect: mapRect, point2: coordinate2)
        dispatch_async(dispatch_get_main_queue(), {
            self.map.addOverlay(overlay)
        })
    }
    
    // Based off of two coordinates, created a MapKit rect that surrounds them
    func getMapRect(coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) -> MKMapRect{
        let mapPoint1: MKMapPoint = MKMapPointForCoordinate(coordinate1)
        let mapPoint2: MKMapPoint = MKMapPointForCoordinate(coordinate2)
        
        let width = fabs(mapPoint1.x - mapPoint2.x)
        let height = fabs(mapPoint1.y - mapPoint2.y)
        
        let size: MKMapSize = MKMapSize(width: width, height: height)
        let origin: MKMapPoint = getUpperLeftCorner(mapPoint1, mapPoint2: mapPoint2)
        return MKMapRectMake(origin.x, origin.y, size.width, size.height)
    }
    
    // Given two MapKit points, return a MapKit point that corresponds to the third point in a right triangle
    // formed with the other two points
    func getUpperLeftCorner(mapPoint1: MKMapPoint, mapPoint2: MKMapPoint) -> MKMapPoint{
        var result: MKMapPoint = MKMapPoint(x: mapPoint1.x, y: mapPoint1.y)
        if mapPoint2.x < mapPoint1.x { result.x = mapPoint2.x }
        if mapPoint2.y < mapPoint1.y { result.y = mapPoint2.y }
        return result
    }
    
    // Return a renderer for the overlays
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if let pathOverlay = overlay as? PathOverlay {
        let renderer: MapOverlayRenderer = MapOverlayRenderer(overlay: overlay, coordinate1: pathOverlay.coordinate, coordinate2: pathOverlay.coordinate2)
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    // For the house and school, turn the pin into a building image
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let _ = annotation as? MKUserLocation{
            return nil
        }
        else{
            let annotationView = MKAnnotationView()
            
            // We need to unwrap the double option
            if let temp = annotation.title, let title = temp{
                if isCheckIn(title) {
                    return nil
                }
            }
            annotationView.annotation = annotation
            annotationView.image = UIImage(named: "House.png")
            annotationView.frame = CGRectMake(0, 0, 30, 30)
            return annotationView
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

