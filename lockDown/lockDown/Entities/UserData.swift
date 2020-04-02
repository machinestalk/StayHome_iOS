//
//  UserData.swift
//  lockDown
//
//  Created by Aymen HECHMI on 02/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit
import ObjectMapper

class UserData: Mappable {
    
    var token: String?
    var refreshToken: String?
    var deviceToken: String?
    var deviceID: String?

    required init?(map: Map) {

    }

    // Mappable
    func mapping(map: Map) {
        
        token <- map["token"]
        refreshToken <- map["refreshToken"]
        deviceToken <- map["deviceToken"]
        deviceID <- map["deviceId"]

    }
}
