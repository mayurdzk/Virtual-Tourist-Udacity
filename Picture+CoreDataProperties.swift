//
//  Picture+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Mayur on 09/11/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import Foundation
import CoreData


extension Picture {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Picture> {
        return NSFetchRequest<Picture>(entityName: "Picture");
    }

    @NSManaged public var localImageURL: String?
    @NSManaged public var remoteImageURL: String?
    @NSManaged public var imageBinary: NSData?
    @NSManaged public var associatedPin: Pin?
}
