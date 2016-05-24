//
//  AppStoreConstants.swift
//  AppStoreSearch
//
//  Created by ying yang on 5/23/16.
//  Copyright © 2016 ying yang. All rights reserved.
//

import Foundation

extension AppStoreClient {
    
    struct Constants {
        static let ApiSchem = "https"
        static let ApiHost = "itunes.apple.com"
        static let ApiPath = "/search"
    }
    
    struct ParametersKey {
        static let SearchTerm = "term"
        static let Entity = "entity"
    }
    
    struct ParameterValue {
        static let Song = "song"
        static let Movie = "movie"
        static let Software = "software"
    }
}