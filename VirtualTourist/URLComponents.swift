//
//  URLComponents.swift
//  VirtualTourist
//
//  Created by Mayur on 17/10/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import Foundation

struct URLComponents{
    static let FlickrBaseURL = "https://api.flickr.com/services/rest/"
    
    static let SearchMethod = "flickr.photos.search"
}

struct ParameterKeys{
    static let apiKey     =  "api_key"
    static let method           = "method"
    static let safeSearch      = "safe_search"
    static let extras           = "extras"
    static let format           = "format"
    static let noJsonCallback = "nojsoncallback"
    static let bbox             = "bbox"
    //static let page             = "page"
    static let perPage         = "per_page"
    static let sort             = "sort"
}

struct ParameterValues{
    static let json = "json"
    static let urlM = "url_m"
    static let safeSearchOn = "1"
    static let noJsonCallBackOn = "1"
    static let perPageValue = "21"
    
    
    func randomSortValue() -> String{
        let sortValues = ["date-posted-desc", "date-posted-asc", "date-taken-desc", "date-taken-asc", "interstingness-desc", "interestingness-asc" , "relevance"]
        
        return sortValues[Int(arc4random_uniform(UInt32(sortValues.count)))]
    }
}
