//
//  AppStoreClient.swift
//  AppStoreSearch
//
//  Created by ying yang on 5/23/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import Foundation

class AppStoreClient {
    lazy var session = NSURLSession.sharedSession()

    static let sharedInstance = AppStoreClient()

    func performSearch(term: String, entity: String?) {
        var method = [AppStoreClient.ParametersKey.SearchTerm: term]
        if entity != nil {
            method[AppStoreClient.ParametersKey.Entity] = entity
        }
        
        taskForGetMethod(method) { (results, error) -> Void in
            guard error == nil else {
                print(error!)
                return
            }
            print(results)
        }
    }
    
    func taskForGetMethod(method: [String: String], completionHandlerForGet: (results: AnyObject?, error: String?) -> Void) -> NSURLSessionDataTask{
        let url = urlFromMethod(method)
        print(url)
        
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                completionHandlerForGet(results: nil, error: error!.description)
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForGet(results: nil, error: "Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                completionHandlerForGet(results: nil, error: "No data returned with your request")
                return
            }
            self.parseData(data, completionHandler: completionHandlerForGet)
        }
        
        task.resume()
        return task
    }

    func parseData(data: NSData, completionHandler: (results: AnyObject?, error: String?) -> Void) {
        let parseResults: AnyObject?
        do {
            try parseResults = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            completionHandler(results: parseResults, error: nil)
        }catch {
            completionHandler(results: nil, error: "Could not parse data as JSON: '\(data)'")
        }
    }
    
    func urlFromMethod(method: [String: String]) -> NSURL{
        let urlComponent = NSURLComponents()
        urlComponent.scheme = AppStoreClient.Constants.ApiSchem
        urlComponent.host = AppStoreClient.Constants.ApiHost
        urlComponent.path = AppStoreClient.Constants.ApiPath
        var queryItems = [NSURLQueryItem]()
        for (key, value) in method {
            let queryItem = NSURLQueryItem(name: key, value: value)
            queryItems.append(queryItem)
        }
        urlComponent.queryItems = queryItems
        let url = urlComponent.URL!
        return url
    }

}