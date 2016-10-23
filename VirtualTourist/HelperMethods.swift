//
//  HelperMethods.swift
//  VirtualTourist
//
//  Created by Mayur on 17/10/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import Foundation

struct HelperMethods{
    
    /// The signature of this function is subject to change. Given a coordinate in (lat,long) format, this function outputs a square across space that is defined by its lower-left corner and top-right corner in the [(lat,Long), (lat,long)] format, such that the given coordinate is the center of that square.
    ///
    /// - parameter coordinates: The coordinates you want to convert in the BBox format provided in the (lat, long) format.
    ///
    /// - returns: An array of two elements in the (lat,long) format that corresponds to the BBox dimensions.
    func convertToBBoxCoordinates(from coordinates: (Float, Float)) -> Array<(Float, Float)>{
        return []
    }
}
