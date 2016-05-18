//
//  DropPinViewController.swift
//  VirtualTourist
//
//  Created by Mayur on 13/05/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import UIKit
import MapKit

class DropPinViewController: UIViewController, MKMapViewDelegate{
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tapPinsToDeleteLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapPinsToDeleteLabel.hidden = true
        addDroppingPinOnTapAndHold()
    }
    
    @IBAction func editButtonPressed(sender: AnyObject) {
        tapPinsToDeleteLabel.hidden = !tapPinsToDeleteLabel.hidden
    }
    
}
extension DropPinViewController{
    func addDroppingPinOnTapAndHold(){
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(DropPinViewController.addAnnotation(_:)))
        uilgr.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(uilgr)
    }
    
    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            mapView.addAnnotation(annotation)
            print(["name":annotation.title,"latitude":"\(newCoordinates.latitude)","longitude":"\(newCoordinates.longitude)"])
        }
        
    }
}
