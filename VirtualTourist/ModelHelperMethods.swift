//
//  HelperMethods.swift
//  VirtualTourist
//
//  Created by Mayur on 17/10/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import Foundation

struct ModelHelperMethods{
    static let shared = ModelHelperMethods()
    /// The signature of this function is subject to change. Given a coordinate in (lat,long) format, this function outputs a square across space that is defined by its lower-left corner and top-right corner in the [(lat,Long), (lat,long)] format, such that the given coordinate is the center of that square.
    ///
    /// - parameter coordinates: The coordinates you want to convert in the BBox format provided in the (lat, long) format.
    ///
    /// - returns: An array of two elements in the (lat,long) format that corresponds to the BBox dimensions.
    func convertToBBoxCoordinates(from coordinates: (Float, Float)) -> String{
        return ""
    }
    
    
    /// Given a dictionary of parameters, this function returns a URL String with the Key: Value pairs escaped in the form of a URL string.
    ///
    /// - Parameter parameters: A dictionary that contains a key, Value pair of parameters.
    /// - Returns: A String with all the paramters provided in an escaped format. A blank string is returned if no parameter was provided.
    func escape(parameters: [String : AnyObject]) -> String {
        var escapedURL = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            escapedURL += [key + "=" + "\(escapedValue!)"]
        }
        return (!escapedURL.isEmpty ? "?" : "") + escapedURL.joined(separator: "&")
    }
}
