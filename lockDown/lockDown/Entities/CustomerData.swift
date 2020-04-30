//
//  CustomerData.swift
//  lockDown
//
//  Created by Ahmed Mh on 29/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import Foundation
import ObjectMapper


class CustomerData : NSObject, NSCoding, Mappable{

    var cough : [Config]?
    var fever : [Config]?
    var headache : [Config]?
    var lastDay : [Config]?
    var latitude : [Config]?
    var longitude : [Config]?
    var noSuffer : [Config]?
    var radius : [Config]?
    var shortBreath : [Config]?


    class func newInstance(map: Map) -> Mappable?{
        return CustomerData()
    }
    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        cough <- map["cough"]
        fever <- map["fever"]
        headache <- map["headache"]
        lastDay <- map["lastDay"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        noSuffer <- map["noSuffer"]
        radius <- map["radius"]
        shortBreath <- map["shortBreath"]
        
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
         cough = aDecoder.decodeObject(forKey: "cough") as? [Config]
         fever = aDecoder.decodeObject(forKey: "fever") as? [Config]
         headache = aDecoder.decodeObject(forKey: "headache") as? [Config]
         lastDay = aDecoder.decodeObject(forKey: "lastDay") as? [Config]
         latitude = aDecoder.decodeObject(forKey: "latitude") as? [Config]
         longitude = aDecoder.decodeObject(forKey: "longitude") as? [Config]
         noSuffer = aDecoder.decodeObject(forKey: "noSuffer") as? [Config]
         radius = aDecoder.decodeObject(forKey: "radius") as? [Config]
         shortBreath = aDecoder.decodeObject(forKey: "shortBreath") as? [Config]

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
    {
        if cough != nil{
            aCoder.encode(cough, forKey: "cough")
        }
        if fever != nil{
            aCoder.encode(fever, forKey: "fever")
        }
        if headache != nil{
            aCoder.encode(headache, forKey: "headache")
        }
        if lastDay != nil{
            aCoder.encode(lastDay, forKey: "lastDay")
        }
        if latitude != nil{
            aCoder.encode(latitude, forKey: "latitude")
        }
        if longitude != nil{
            aCoder.encode(longitude, forKey: "longitude")
        }
        if noSuffer != nil{
            aCoder.encode(noSuffer, forKey: "noSuffer")
        }
        if radius != nil{
            aCoder.encode(radius, forKey: "radius")
        }
        if shortBreath != nil{
            aCoder.encode(shortBreath, forKey: "shortBreath")
        }

    }

}
