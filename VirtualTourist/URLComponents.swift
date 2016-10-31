//
//  URLComponents.swift
//  VirtualTourist
//
//  Created by Mayur on 17/10/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import Foundation

struct URLComponents{
    static let FlickrBaseURL = "interestingness-asc"
    
    static let SearchMethod = "flickr.photos.search"
}

struct ParameterKeys{
    static let api     = "api_key"
    static let method           = "method"
    static let safeSearch      = "safe_search"
    static let extras           = "extras"
    static let format           = "format"
    static let jsonCallback = "nojsoncallback"
    static let bbox             = "bbox"
    static let page             = "page"
    //static let perPage         = "per_page"
    static let sort             = "sort"
}

struct ParameterValues{
    static let json = "json"
    static let urlM = "url_m"
}
