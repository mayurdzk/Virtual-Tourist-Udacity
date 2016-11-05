//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Mayur on 01/11/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import Foundation
import CoreData
import MapKit


public class Pin: NSManagedObject, MKAnnotation {
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
    public var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(laltitude, longitude)
        }
        set {
            self.laltitude = newValue.latitude
            self.longitude = newValue.longitude
        }
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context)!
        super.init(entity: entity, insertInto: context)
        
        self.laltitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}
