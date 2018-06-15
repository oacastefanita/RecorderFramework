//
//  User.swift
//  Pods
//
//  Created by Stefanita Oaca on 19/09/2017.
//
//

import Foundation

public class User: NSObject, NSCoding {
    public var firstName: String! = ""
    public var lastName:String! = ""
    public var email:String! = ""
    public var isPublic:Bool! = false
    public var playBeep:Bool! = false
    public var maxLenght:String! = ""
    public var imagePath:String! = ""
    public var timeZone:String! = ""
    public var plan:String! = ""
    public var time:Int! = 0
    public var pin:String! = ""
    
    override public init() {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder){
        if let value = aDecoder.decodeObject(forKey: "firstName") as? String {
            self.firstName = value
        }
        if let value = aDecoder.decodeObject(forKey: "lastName") as? String {
            self.lastName = value
        }
        if let value = aDecoder.decodeObject(forKey: "email") as? String {
            self.email = value
        }
        if let value = aDecoder.decodeObject(forKey: "isPublic") as? Bool {
            self.isPublic = value
        }
        if let value = aDecoder.decodeObject(forKey: "playBeep") as? Bool {
            self.playBeep = value
        }
        if let value = aDecoder.decodeObject(forKey: "maxLenght") as? String {
            self.maxLenght = value
        }
        if let value = aDecoder.decodeObject(forKey: "imagePath") as? String {
            self.imagePath = value
        }
        if let value = aDecoder.decodeObject(forKey: "timeZone") as? String {
            self.timeZone = value
        }
        if let value = aDecoder.decodeObject(forKey: "plan") as? String {
            self.plan = value
        }
        if let value = aDecoder.decodeObject(forKey: "time") as? Int {
            self.time = value
        }
        if let value = aDecoder.decodeObject(forKey: "pin") as? String {
            self.pin = value
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        if let value = self.firstName {
            aCoder.encode(value, forKey: "firstName")
        }
        
        if let value = self.lastName {
            aCoder.encode(value, forKey: "lastName")
        }
        
        if let value = self.email {
            aCoder.encode(value, forKey: "email")
        }
        
        if let value = self.isPublic {
            aCoder.encode(value, forKey: "isPublic")
        }
        
        if let value = self.playBeep {
            aCoder.encode(value, forKey: "playBeep")
        }
        
        if let value = self.maxLenght {
            aCoder.encode(value, forKey: "maxLenght")
        }
        
        if let value = self.imagePath {
            aCoder.encode(value, forKey: "imagePath")
        }
        
        if let value = self.timeZone {
            aCoder.encode(value, forKey: "timeZone")
        }
        
        if let value = self.plan {
            aCoder.encode(value, forKey: "plan")
        }
        
        if let value = self.time {
            aCoder.encode(value, forKey: "time")
        }
        
        if let value = self.pin {
            aCoder.encode(value, forKey: "pin")
        }
    }
}
