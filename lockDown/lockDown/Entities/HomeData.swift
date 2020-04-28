//
//  HomeData.swift
//  lockDown
//
//  Created by Ahmed Mh on 28/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit
import ObjectMapper

class HomeData:   Mappable {
    
    var lastUpdateTs: String?
    var value: Any?
    var key: String?
   
    required init?(map: Map) {

    }

    // Mappable
    func mapping(map: Map) {
        
        lastUpdateTs <- map["lastUpdateTs"]
        value <- map["value"]
        key <- map["key"]
       
    }
}

