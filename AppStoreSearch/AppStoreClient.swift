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
    var searchResult = [SearchResult]()
    static let sharedInstance = AppStoreClient()

    func performSearch(term: String, entity: String?, searchCompletionHandler: (error: String?) -> Void){
        var method = [AppStoreClient.ParametersKey.SearchTerm: term]
        if entity != nil {
            method[AppStoreClient.ParametersKey.Entity] = entity
        }
        
        taskForGetMethod(method) { (results, error) -> Void in
            guard error == nil else {
                searchCompletionHandler(error: error!)
                return
            }
            self.parseResults(results!)
            searchCompletionHandler(error: nil)
        }
    }
    
    func parseResults(results: AnyObject){
        let dictionary = results as! [String: AnyObject]
        if let dicArray = dictionary["results"] as? [[String: AnyObject]] {
            for dic in dicArray {
                let result = SearchResult()
                result.name = dic["trackName"] as! String
                result.artistName = dic["artistName"] as! String
                result.artworkURL60 = dic["artworkUrl60"] as! String
                result.artworkURL100 = dic["artworkUrl100"] as! String
                result.storeURL = dic["trackViewUrl"] as! String
                result.kind = dic["kind"] as! String
                result.currency = dic["currency"] as! String
                
                if let price = dic["trackPrice"] as? Double {
                    result.price = price
                }
                if let genre = dic["primaryGenreName"] as? String {
                    result.genre = genre
                }
                searchResult.append(result)
            }
        }else{
            print("cannot find the key: results")
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

    func taskForImage(url: NSURL, downloadImageCompletionHandler: (data: NSData?, error: String?) -> Void) -> NSURLSessionTask{
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                downloadImageCompletionHandler(data: nil, error: error!.description)
                return
            }
            downloadImageCompletionHandler(data: data, error: nil)
        }
        task.resume()
        return task
    }
}