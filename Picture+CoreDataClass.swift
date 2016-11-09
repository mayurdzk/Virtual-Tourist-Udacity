//
//  Picture+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Mayur on 01/11/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import UIKit
import CoreData


public class Picture: NSManagedObject {
    convenience init(remoteImageURL: String?, localImageURL: String?, associatedPin: Pin?, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context){
            self.init(entity: entity, insertInto: context)
            self.remoteImageURL = remoteImageURL
            self.localImageURL = localImageURL
            self.associatedPin = associatedPin
        }
        else{
            fatalError("Unable to find Pin entity")
        }
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    var image: UIImage? {
//        if localImageURL != nil {
//            let fileURL = getFileURL()
//            return UIImage(contentsOfFile: fileURL.path!)
//        }
        //MARK: Changed to comply with Udacity's rubric.
        if let imageBin = imageBinary as? Data{
            return UIImage(data: imageBin)
        }
        else{
            return nil
        }
    }
    
    func getFileURL() -> NSURL {
        let fileName = (localImageURL! as NSString).lastPathComponent
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let pathArray:[String] = [dirPath, fileName]
        let fileURL = NSURL.fileURL(withPathComponents: pathArray)
        return fileURL! as NSURL
    }
    
    init(photoBinary: NSData, pin: Pin, context: NSManagedObjectContext){
        let entity = NSEntityDescription.entity(forEntityName: "Picture", in: context)!
        super.init(entity: entity, insertInto: context)
        
        self.remoteImageURL = nil
        self.localImageURL = nil
        self.imageBinary = photoBinary
        self.associatedPin = pin
    }
    
    init(photoURL: String, pin: Pin, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Picture", in: context)!
        super.init(entity: entity, insertInto: context)
        
        self.remoteImageURL = photoURL
        self.localImageURL = nil
        self.associatedPin = pin
    }
}
