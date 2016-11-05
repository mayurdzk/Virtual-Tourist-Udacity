//
//  CoreDataCollectionViewController.swift
//  VirtualTourist
//
//  Created by Mayur on 04/11/16.
//  Copyright © 2016 Mayur. All rights reserved.
//
import UIKit
import CoreData

class CoreDataCollectionViewController: UICollectionViewController{
    
    // MARK:  - Properties
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?{
        didSet{
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            collectionView?.reloadData()
        }
    }
    
    init(forFetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>){
        fetchedResultsController = forFetchedResultsController
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    
    // Do not worry about this initializer. I has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}



// MARK:  - Subclass responsability
extension CoreDataCollectionViewController{
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("This method MUST be implemented by a subclass of CoreDatacollectionViewController")
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        fatalError("This method MUST be implemented by a subclass of CoreDatacollectionViewController")
    }
}

// MARK:  - Table Data Source
extension CoreDataCollectionViewController{
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fc = fetchedResultsController{
            return (fc.sections?.count)!;
        }else{
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController{
            return fc.sections![section].numberOfObjects;
        }else{
            return 0
        }
    }
    
/*    Not applicable to a UICollectionView
//    override func collectionView(_ collectionView: UICollectionView, titleForHeaderInSection section: Int) -> String? {
//        if let fc = fetchedResultsController{
//            return fc.sections![section].name;
//        }else{
//            return nil
//        }
//    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if let fc = fetchedResultsController{
            return fc.section(forSectionIndexTitle: title, at: index)
        }else{
            return 0
        }
    }
    
    override func sectionIndexTitlesForcollectionView(collectionView: UICollectionView) -> [String]? {
        if let fc = fetchedResultsController{
            return  fc.sectionIndexTitles
        }else{
            return nil
        }
    }*/
    
    
}

// MARK:  - Fetches
extension CoreDataCollectionViewController{
    
    func executeSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch let e as NSError{
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}


// MARK:  - Delegate
extension CoreDataCollectionViewController: NSFetchedResultsControllerDelegate{
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //collectionView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                    atIndex sectionIndex: Int,
                    forChangeType type: NSFetchedResultsChangeType) {
        
        let set = NSIndexSet(index: sectionIndex)
        
        switch (type){
            
        case .insert:
            collectionView?.insertSections(set as IndexSet)
            
        case .delete:
            collectionView?.deleteSections(set as IndexSet)
            
        default:
            // irrelevant in our case
            break
            
        }
    }
    
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChangeObject anObject: AnyObject,
                    atIndexPath indexPath: NSIndexPath?,
                    forChangeType type: NSFetchedResultsChangeType,
                    newIndexPath: NSIndexPath?) {
        
        
        
        switch(type){
            
        case .insert:
            collectionView?.insertItems(at: [newIndexPath! as IndexPath])
            
        case .delete:
            collectionView?.deleteItems(at: [newIndexPath! as IndexPath])
            
        case .update:
            collectionView?.reloadItems(at: [newIndexPath! as IndexPath])
            
        case .move:
            collectionView?.deleteItems(at: [newIndexPath! as IndexPath])
            collectionView?.insertItems(at: [newIndexPath! as IndexPath])
        }
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //collectionView?.endUpdates()
    }
}
















