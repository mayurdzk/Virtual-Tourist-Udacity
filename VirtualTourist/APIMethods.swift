//
//  APIMethods.swift
//  VirtualTourist
//
//  Created by Mayur on 31/10/16.
//  Copyright © 2016 Mayur. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct APIMethods{
    static let shared = APIMethods()
    //MARK: Flickr specific API calls
    //TODO: Documentation pending.
    func getPhotos(for pin: Pin, completionHandler: @escaping(_ success: Bool, _ message:  String?, _ data: AnyObject?)-> Void){
        let parameters = [
            ParameterKeys.apiKey : FlickrKeys.Key,
            ParameterKeys.method : URLComponents.SearchMethod,
            ParameterKeys.format : ParameterValues.json,
            ParameterKeys.noJsonCallback: ParameterValues.noJsonCallBackOn,
            ParameterKeys.bbox : ModelHelperMethods.shared.convertToBBoxCoordinates(from: pin),
            ParameterKeys.sort: ParameterValues().randomSortValue(),
            ParameterKeys.safeSearch: ParameterValues.safeSearchOn,
            ParameterKeys.perPage: ParameterValues.perPageValue,
            ParameterKeys.extras: ParameterValues.urlM
        ]
        let _ = get(url: URLComponents.FlickrBaseURL, parameters: parameters as [String : AnyObject], parse: true) { (data, error) in
            if error != nil {
                print(error!)
                completionHandler(false, "Couldn't download new images for that location. Please try later.", nil)
            }
            else{
                completionHandler(true, nil, data)
            }
        }
    }
    
    /// This function fecthes an image from a provided URL and passes the Data via the completion handler provided Data can be converted to a UIImage. If the conversion is not possible, the completion handler gets called with the success parameter set to false.
    ///
    /// - Parameters:
    ///   - url: URL for the image.
    ///   - completionHandler: Called with a success value decided by whether data was revcieved and if the recieved Data can be converted to a UIImage.
    func getImage(from photo: Picture, completionHandler: @escaping(_ success: Bool, _ message:  String?)-> Void) -> Void{
        //let testURL = "https://farm3.staticflickr.com/2158/2211771368_a063bfe0d1.jpg"
        
        let _ = get(url: photo.remoteImageURL!, parameters: nil, parse: false) { (data, error) in
            if error != nil {
                completionHandler(false, "Image could not be downloaded.")
            }
            else{
                if let _ = UIImage(data: data as! Data) {
                    DispatchQueue.main.async {
                        let fileName = (photo.remoteImageURL! as NSString).lastPathComponent
                        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                        let pathArray = [path, fileName]
                        let fileURL = NSURL.fileURL(withPathComponents: pathArray)!
                        FileManager.default.createFile(atPath: fileURL.path, contents: (data as! Data), attributes: nil)
                        photo.localImageURL = fileURL.path
                        //MARK: Saved image as binary data as per the Rubric.
                        photo.imageBinary = data as! NSData
                        completionHandler(true, nil)
                    }
                }
                else{
                    completionHandler(false, "The data was not an image.")
                }
            }
        }
    }
}

//MARK: Generalised API call.
extension APIMethods{
    /// Performs a GET request on the given URL. Calls the completionHandler with nil as the error parameter on a successful call.
    ///
    /// - Parameters:
    ///   - url: The URL for performing the request.
    ///   - parameters: An optional dictionary to be appended against the URL
    ///   - parse: Flag whether you would like to parse the data recieved by the API
    ///   - completionHandler: Run when the get method completes execution.
    /// - Returns: Returns the data task
    fileprivate func get(url: String, parameters: [String : AnyObject]?, parse: Bool, completionHandler: @escaping(_ data: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
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
            //When we're getting a list of links for pictures from Flickr, we want to parse the JSON
            if parse{
                ModelHelperMethods.shared.parse(rawJSON: data, completionHandler: completionHandler)
            }
            //parse is nil when we make a call for images as we require that data in its raw form.
            else {
                completionHandler(data as AnyObject?, nil)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
}
