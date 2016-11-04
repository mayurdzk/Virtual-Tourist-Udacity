//
//  Picture+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Mayur on 01/11/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import Foundation
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
}
