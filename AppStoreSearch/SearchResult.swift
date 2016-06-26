//
//  SearchResult.swift
//  AppStoreSearch
//
//  Created by ying yang on 5/15/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import CoreData

class SearchResult: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var artistName: String?
    @NSManaged var artworkURL60: String
    @NSManaged var artworkURL100: String
    @NSManaged var storeURL: String
    @NSManaged var kind: String
    @NSManaged var currency: String
    @NSManaged var price: Double
    @NSManaged var genre: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext){
        let entity = NSEntityDescription.entityForName("SearchResult", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        name = dictionary["trackName"] as! String
        artistName = dictionary["artistName"] as? String
        artworkURL60 = dictionary["artworkUrl60"] as! String
        artworkURL100 = dictionary["artworkUrl100"] as! String
        storeURL = dictionary["trackViewUrl"] as! String
        kind = dictionary["kind"] as! String
        currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            self.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            self.genre = genre
        }
    }
}