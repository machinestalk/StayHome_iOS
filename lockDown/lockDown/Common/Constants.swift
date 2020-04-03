//
//  Constants.swift
//  MotornaSwift
//
//  Created by Aymen HECHMI on 26/03/2020.
//  Copyright © 2020 IN:TIME Solutions. All rights reserved.
//

import Foundation
var language = String()

struct LockDown {
    
    struct ProductionServer {
        static let baseURL = "http://ci.thingstalk.io/"
        static let identityServerURL = "https://auth.motorna.sa/v21"
    }
    struct DeveloppementServer {
        static let baseURL = "http://37.224.62.114:19501/api/v1"
        static let identityServerURL = "http://37.224.62.114:19506"
    }
    struct QAServer {
        static let baseURL = "http://qa.motorna.sa/v21/api/v1"
        static let identityServerURL = "http://37.224.62.114:19403"
    }
    struct UATServer {
        static let baseURL = "http://uat.motorna.sa/api/v1"
        static let identityServerURL = "http://37.224.62.114:19403"
    }
    
    struct GoogleMaps {
        static let key = "AIzaSyBhIvUAZ8WTsmSUehqhgYplev2ZVdLkPbk"
    }

    struct APIParameterKey {
        
        static let phoneOtp = "phoneOtp"
        static let phoneUdid = "phoneUdid"
        static let phoneNumber = "phoneNumber"
        static let iscomplaint = "compliant"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let radius = "radius"

    }
}

enum HTTPHeaderField: String {
    case authentication = "X-Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}

enum ContentType: String {
    case json = "application/json"
}
