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
    @IBOutlet var editButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapPinsToDeleteLabel.isHidden = true
        addDroppingPinOnTapAndHold()
    }
    
    @IBAction func editButtonPressed(_ sender: AnyObject) {
        toggleDeletionState()
    }
    
}
extension DropPinViewController{
    func addDroppingPinOnTapAndHold(){
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(DropPinViewController.addAnnotation(_:)))
        uilgr.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(uilgr)
    }
    func addAnnotation(_ gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            mapView.addAnnotation(annotation)
            print(["name":annotation.title,"latitude":"\(newCoordinates.latitude)","longitude":"\(newCoordinates.longitude)"])
        }
    }
}
extension DropPinViewController{
    
    /// Toggles editButton's title property between 'Edit' and 'Done' depending on whether tapPinsToDeleteLabel is hidden or not. This function then toggles the isHidden property of the tapPinsToDeleteLabel label.
    func toggleDeletionState(){
        if tapPinsToDeleteLabel.isHidden{
            editButton.setTitle("Done", for: .normal)
        }
        else{
            editButton.setTitle("Edit", for: .normal)
        }
        tapPinsToDeleteLabel.isHidden = !tapPinsToDeleteLabel.isHidden
    }
}
