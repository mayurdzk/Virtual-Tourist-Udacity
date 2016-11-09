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
    var tappedPin: Pin? = nil
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.SegueFromDropPinVCToViewPinVC{
            let viewPinVC = segue.destination as! ViewPinViewController
            
            viewPinVC.pin = tappedPin!
        }
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
        mapView.deselectAnnotation(pin, animated: false)
        if  tapPinsToDeleteLabel.isHidden{
            //If pin's URLs are nil, display Loading dialog and fetch urls
            // If pin's URLs are present but the count is 0, fetch urls, check for count, display dialog with 'Flickr doesn't have any images for that location'
            //If count > 0, segue.
            tappedPin = pin
            performSegue(withIdentifier: SegueIdentifiers.SegueFromDropPinVCToViewPinVC, sender: nil)
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
            
            print(["name":annotation.title,"latitude":"\(newCoordinates.latitude)","longitude":"\(newCoordinates.longitude)"])
            let pin = Pin(coordinate: newCoordinates, context: coreDataSharedContext)
            mapView.addAnnotation(pin)
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
    
    /// Returns an array of all pins saved in CoreData
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
    
    /// Takes a pin as a parameter and deletes that pin.
    /// pin: The pin you;d like to delete.
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
                    print("photosDictionary: \(photosDictionary)")
                    if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]]{
                        print("photosArray \(photosArray)")
                        DispatchQueue.main.sync {
                            for eachPhotoDictionary in photosArray{
                                let photoURLString = eachPhotoDictionary["url_m"] as! String
                                print(photoURLString)
                                _ = Picture(photoURL: photoURLString, pin: pin, context: self.coreDataSharedContext)
                            }
                            self.coreDataSharedInstance.saveContext()
                        }
                        //This line is not necessary since CoreData automatically manages this side of the relationship given that the relationship is set from the Picture Entity.
                        //pin.pictures = pictures
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
