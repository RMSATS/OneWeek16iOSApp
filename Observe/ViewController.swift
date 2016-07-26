//
//  ViewController.swift
//  Observe
//
//  Created by Robert Stewart on 7/25/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITextFieldDelegate {

    let apiUrl: String = "https://observerestapi.azurewebsites.net/api/locations/"
    
    @IBOutlet var idField: UITextField!
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.idField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    func getResponseHandler(data: NSData?, response: NSURLResponse?, error: NSError?){
        print("Data received")
        
        do{
            let dataArray: NSArray = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSArray
            let longitude: Double = dataArray.lastObject!["lon"] as! Double
            let latitude: Double = dataArray.lastObject!["lat"] as! Double
            print(longitude)
            print(latitude)
            dropPin(longitude, latitude: latitude)
        }
        catch _{
            // Serialization error occurred
        }
    }
    
    
    func dropPin(longitude: Double, latitude: Double){
        let pin: MKPointAnnotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        pin.coordinate = coordinate
        map.addAnnotation(pin)
    }
    
    func getGETRequest(name: String) -> NSMutableURLRequest{
        let requestUrlString = apiUrl + "?name=" + name
        //print("Request string: " + requestUrlString)
        let requestUrl = NSURL(string: requestUrlString)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: requestUrl)
        request.HTTPMethod = "GET"
        return request
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        idField.resignFirstResponder()
        
        if let id: String = idField!.text!{
            print("Something")
            let request: NSMutableURLRequest = getGETRequest(id)
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: configuration)
            
            
            session.dataTaskWithRequest(request, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                self.getResponseHandler(data, response: response, error: error)
            }).resume()
            
            /* NSURLConnection.(request, queue: NSOperationQueue(),
             completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
             self.getResponseHandler(response, data: data, error: error)
             })*/
            
            
        }
        print("End of submitPressed")
        
        return false
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}

