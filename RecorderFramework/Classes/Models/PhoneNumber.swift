//
//  PhoneNumber.swift
//  Recorder
//
//  Created by Grif on 26/04/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation

public class PhoneNumber: NSObject, NSCoding {
    public var number: String!
    public var friendlyNumber:String!
    public var phoneNumber: String!
    public var prefix: String!
    public var flag: String!
    public var country: String!
    public var city: String!
    public var isDefault = false
    
    override public init() {
        super.init()
        self.number = ""
        self.friendlyNumber = ""
        self.phoneNumber = ""
        self.prefix = ""
        self.flag = ""
        self.country = ""
        self.city = ""
        self.isDefault = false
    }
    
    public required init?(coder aDecoder: NSCoder){
        if let value = aDecoder.decodeObject(forKey: "number") as? String {
            self.number = value
        }
        if let value = aDecoder.decodeObject(forKey: "friendlyNumber") as? String {
            self.friendlyNumber = value
        }
        if let value = aDecoder.decodeObject(forKey: "phoneNumber") as? String {
            self.phoneNumber = value
        }
        if let value = aDecoder.decodeObject(forKey: "prefix") as? String {
            self.prefix = value
        }
        if let value = aDecoder.decodeObject(forKey: "flag") as? String {
            self.flag = value
        }
        if let value = aDecoder.decodeObject(forKey: "country") as? String {
            self.country = value
        }
        if let value = aDecoder.decodeObject(forKey: "city") as? String {
            self.city = value
        }
        if let value = aDecoder.decodeObject(forKey: "isDefault") as? String {
            self.isDefault = NSString(string: value).boolValue
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        if let value = self.number {
            aCoder.encode(value, forKey: "number")
        }
        if let value = self.friendlyNumber {
            aCoder.encode(value, forKey: "friendlyNumber")
        }
        if let value = self.phoneNumber {
            aCoder.encode(value, forKey: "phoneNumber")
        }
        if let value = self.prefix {
            aCoder.encode(value, forKey: "prefix")
        }
        if let value = self.flag {
            aCoder.encode(value, forKey: "flag")
        }
        if let value = self.country {
            aCoder.encode(value, forKey: "country")
        }
        if let value = self.city {
            aCoder.encode(value, forKey: "city")
        }
        
        aCoder.encode(isDefault ? "true" : "false", forKey: "isDefault")
    }
}
