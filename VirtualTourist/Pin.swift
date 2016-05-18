//
//  Pin.swift
//  VirtualTourist
//
//  Created by Mayur on 18/05/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import UIKit
import CoreData

class Pin: NSManagedObject{
    @NSManaged var lattitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var associatedPictures: [Picture]?
}
