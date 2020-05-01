//
//  Config.swift
//  lockDown
//
//  Created by Ahmed Mh on 29/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import Foundation
import ObjectMapper


class Config : NSObject, NSCoding, Mappable{

    var ts : Int?
    var value : String?


    class func newInstance(map: Map) -> Mappable?{
        return Config()
    }
    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        ts <- map["ts"]
        value <- map["value"]
        
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
         ts = aDecoder.decodeObject(forKey: "ts") as? Int
         value = aDecoder.decodeObject(forKey: "value") as? String

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
    {
        if ts != nil{
            aCoder.encode(ts, forKey: "ts")
        }
        if value != nil{
            aCoder.encode(value, forKey: "value")
        }

    }

}
