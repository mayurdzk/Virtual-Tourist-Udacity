//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Mayur on 01/11/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import Foundation
import CoreData


public class Pin: NSManagedObject {
    convenience init(latitude: Double, longitude: Double, pictures: NSSet?, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context){
            self.init(entity: entity, insertInto: context)
            self.laltitude = latitude
            self.longitude = longitude
            self.pictures = pictures
        }
        else{
            fatalError("Unable to find Pin entity")
        }
    }
}
