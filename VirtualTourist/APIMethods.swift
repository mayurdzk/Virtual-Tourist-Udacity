//
//  APIMethods.swift
//  VirtualTourist
//
//  Created by Mayur on 31/10/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import Foundation

struct APIMethods{
    
}

extension APIMethods{
    
    /// Performs a GET request on the fiven URL. Calls the completionHandler with nil as the error parameter on a successful call.
    ///
    /// - Parameters:
    ///   - url: The URL for performing the request.
    ///   - parameters: An optional dictionary to be appended against the URL
    ///   - parse: Flag whether you would like to parse the data recieved by the API
    ///   - completionHandler: Run when the get method completes execution.
    /// - Returns: Returns the data task
    func get(url: String, parameters: [String : AnyObject]?, parse: Bool, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var urlString = url
        if let parameters = parameters {
            urlString = urlString +  ModelHelperMethods.shared.escape(parameters: parameters)
        }
        
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        let session = URLSession.shared
        
        /* 4. Make the request */
        let task = session.dataTask(with: request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(nil, NSError(domain: "getTask", code: 2, userInfo: nil))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                var errorCode = 0 /* technical error */
                if let response = response as? HTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    errorCode = response.statusCode
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                completionHandler(nil, NSError(domain: "getTask", code: errorCode, userInfo: nil))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(nil, NSError(domain: "getTask", code: 3, userInfo: nil))
                return
            }
            
            /* 5/6. Success, parse the data*/
            if parse{
                
            } else {
                completionHandler(data as AnyObject?, nil)
            }
            
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
}
