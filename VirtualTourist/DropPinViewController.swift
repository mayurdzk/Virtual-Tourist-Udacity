//
//  DropPinViewController.swift
//  VirtualTourist
//
//  Created by Mayur on 13/05/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DropPinViewController: UIViewController, MKMapViewDelegate{
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tapPinsToDeleteLabel: UILabel!
    @IBOutlet var editButton: UIButton!
    
    let coreDataSharedContext = CoreDataStack.sharedInstance().managedObjectContext
    let coreDataSharedInstance = CoreDataStack.sharedInstance()
    
    let apis = APIMethods.shared
    
    let loadingDialog = ProgressHUD(text: "Loading...")
    
    var message: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        tapPinsToDeleteLabel.isHidden = true
        addDroppingPinOnTapAndHold()
    }
    
    override func viewDidLayoutSubviews() {
        mapView.addAnnotations(fetchAllPins())
    }
    
    @IBAction func editButtonPressed(_ sender: AnyObject) {
        toggleDeletionState()
    }
}

extension DropPinViewController{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Pin {
            let identifier = "Pin"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
                view.animatesDrop = true
                view.isDraggable = false
            }
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = view.annotation as! Pin
        if  tapPinsToDeleteLabel.isHidden{
            //Download URLs for the Pin
        }
        else{
            delete(pin: pin)
        }
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
            let pin = Pin(coordinate: newCoordinates, context: coreDataSharedContext)
            coreDataSharedInstance.saveContext()
            self.getURLs(for: pin)
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
    
    
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        var pins:[Pin] = []
        do {
            let results = try coreDataSharedContext.fetch(fetchRequest)
            pins = results as! [Pin]
        } catch let error as NSError {
            print("An error occured accessing managed object context \(error.localizedDescription)")
        }
        return pins
    }
    
    func delete(pin: Pin) {
        mapView.removeAnnotation(pin)
        coreDataSharedContext.delete(pin)
        coreDataSharedInstance.saveContext()
    }
    
    func getURLs(for pin: Pin){
        message = nil
        
        apis.getPhotos(for: pin, completionHandler: { (success, message, data) in
            if success{
                if let photosDictionary = data?["photos"] as? [String: AnyObject]{
                    if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]]{
                        var pictures = [Picture]()
                        for eachPhotoDictionary in photosArray{
                            let photoURLString = eachPhotoDictionary["url_m"] as! String
                            let picture = Picture(remoteImageURL: photoURLString, localImageURL: nil, associatedPin: pin, context: self.coreDataSharedContext)
                            pictures.append(picture)
                        }
                        pin.pictures = pictures
                    }
                    else{
                        self.message = "Flickr didn't return the appropriate data."
                        return
                    }
                }
                else{
                    self.message = "Flickr didn't return the appropriate data."
                    return
                }
            }
            self.message = message
        })
    }
}
