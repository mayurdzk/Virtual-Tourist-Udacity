//
//  ViewPinViewController.swift
//  VirtualTourist
//
//  Created by Mayur on 03/10/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewPinViewController: UIViewController, NSFetchedResultsControllerDelegate{
    @IBOutlet var topMapView: MKMapView!
    @IBOutlet var bottomCollectionView: UICollectionView!
    @IBOutlet var newCollectionButton: UIBarButtonItem!
    
    let coreDataSharedContext = CoreDataStack.sharedInstance().managedObjectContext
    let coreDataSharedInstance = CoreDataStack.sharedInstance()
    
    let apis = APIMethods.shared
    
    var pin: Pin!
    
    //Flag to avoid a crash when deleting a single cell.
    var callForReload = true
    
    var itemsCount = 0{
        didSet{
            //This flag is put in place to avoid a reloadData() caused by deleting of once cell.
            if callForReload{
                bottomCollectionView.reloadData()
            }
        }
    }
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths : [NSIndexPath]!
    var updatedIndexPaths : [NSIndexPath]!
    
    var message: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomCollectionView.delegate = self
        bottomCollectionView.dataSource = self
        fetchedResultsController.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
            print(error!)
        }
        setMapRegion()
        getImagesForPin()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Picture")
       fetchRequest.predicate = NSPredicate(format: "associatedPin == %@", argumentArray: [self.pin])
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataSharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    @IBAction func newCollectionButtonTouchUpInside(_ sender: UIBarButtonItem) {
        deletePicturesWith {
            //Run the routine for getting new Photos mapped to the Pin.
            apis.getPhotos(for: pin, completionHandler: { (success, message, data) in
                self.message = nil
                self.apis.getPhotos(for: self.pin, completionHandler: { (success, message, data) in
                    if success{
                        if let photosDictionary = data?["photos"] as? [String: AnyObject]{
                            print("photosDictionary: \(photosDictionary)")
                            if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]]{
                                print("photosArray \(photosArray)")
                                DispatchQueue.main.sync {
                                    for eachPhotoDictionary in photosArray{
                                        let photoURLString = eachPhotoDictionary["url_m"] as! String
                                        print(photoURLString)
                                        _ = Picture(photoURL: photoURLString, pin: self.pin, context: self.coreDataSharedContext)
                                    }
                                    self.coreDataSharedInstance.saveContext()
                                    self.getImagesForPin()
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
            })
        }
    }
    
}

extension ViewPinViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            //return currentSection.numberOfObjects
            return itemsCount
        }
        return 0

    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrImageCell", for: indexPath) as! FlickrImageCell
        let photo = fetchedResultsController.object(at: indexPath) as! Picture
        
        if photo.localImageURL != nil {
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
            cell.flickrImageImageView.image = photo.image
        }
        else{
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.isHidden = false
            cell.flickrImageImageView.image = nil
            cell.flickrImageImageView.backgroundColor = UIColor.blue
        }
        
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let sections = fetchedResultsController.sections {
            //return itemsCount
            return sections.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        //One line = 10 points. Our cells should be of the form Cell|Cell|Cell
        let lineWidth: CGFloat = 10.0
        let numberOfLines: CGFloat = 2.0
        
        let numberOfCellsInOneLine: CGFloat = 3.0
        
        let widthWithAdjustment = (view.frame.width) - (lineWidth * numberOfLines)
        
        return CGSize(width: widthWithAdjustment/numberOfCellsInOneLine, height: widthWithAdjustment/numberOfCellsInOneLine)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath) as! Picture
        bottomCollectionView.deselectItem(at: indexPath, animated: true)
        coreDataSharedContext.delete(photo)
        //collectionView.deleteItems(at: [indexPath]) This line won't work becuase the fetchedResultsController still thinks there are n number of entries
        //We can't make a bottomCollectionView.reloadData at this point since that won't work.
        callForReload = false
        itemsCount -= 1
        callForReload = true
        print("Deleting indexPath: section: \(indexPath.section), item: \(indexPath.item)")
        collectionView.deleteItems(at: [indexPath])
        coreDataSharedInstance.saveContext()
    }
    
    /*
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
        case .update:
            updatedIndexPaths.append(indexPath!)
        case .delete:
            deletedIndexPaths.append(indexPath!)
        default:
            break
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths  = [NSIndexPath]()
        updatedIndexPaths  = [NSIndexPath]()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
        bottomCollectionView.performBatchUpdates({
            for indexPath in self.insertedIndexPaths {
                self.bottomCollectionView.insertItems(at: [indexPath as IndexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.bottomCollectionView.deleteItems(at: [indexPath as IndexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.bottomCollectionView.reloadItems(at: [indexPath as IndexPath])
            }
        }, completion: nil)
    }*/
}

extension ViewPinViewController{
    func setMapRegion(){
        topMapView.addAnnotation(pin)
        topMapView.isUserInteractionEnabled = false
        topMapView.isScrollEnabled = false
        topMapView.isZoomEnabled = false
        
        let span = MKCoordinateSpan(latitudeDelta: topMapView.region.span.latitudeDelta / 2, longitudeDelta: topMapView.region.span.latitudeDelta  / 2)
        
        // Create a new MKMapRegion with the new span, using the center we want.
        let region = MKCoordinateRegion(center: pin.coordinate, span: span)
        
        topMapView.setRegion(region, animated: false)
    }
    func deletePicturesWith(_ completionHandler: () -> Void){
        newCollectionButton.isEnabled = false
        itemsCount = 0
        for eachPicture in fetchedResultsController.fetchedObjects as![Picture]{
            coreDataSharedContext.delete(eachPicture)
        }
        bottomCollectionView.reloadData()
        coreDataSharedInstance.saveContext()
        completionHandler()
        bottomCollectionView.reloadData()
        newCollectionButton.isEnabled = true
    }
    func getImagesForPin(){
        itemsCount = (fetchedResultsController.fetchedObjects?.count)!
        for eachPhoto in fetchedResultsController.fetchedObjects as! [Picture]{
            if eachPhoto.localImageURL == nil && eachPhoto.remoteImageURL != nil{
                apis.getImage(from: eachPhoto, completionHandler: { (success, message) in
                    if success{
                        self.coreDataSharedInstance.saveContext()
                        self.itemsCount = (self.fetchedResultsController.fetchedObjects?.count)!
                        self.bottomCollectionView.reloadData()
                    }
                    else{
                        //TODO: Handle error
                    }
                })
            }
        }
    }
}
