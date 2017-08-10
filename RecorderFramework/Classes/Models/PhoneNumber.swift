//
//  PhoneNumber.swift
//  Recorder
//
//  Created by Grif on 26/04/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation

public class PhoneNumber: NSObject, NSCoding {
    var number: String!
    var friendlyNumber:String!
    var phoneNumber: String!
    var prefix: String!
    var flag: String!
    var country: String!
    var isDefault = false
    
    override init() {
        super.init()
        self.number = ""
        self.friendlyNumber = ""
        self.phoneNumber = ""
        self.prefix = ""
        self.flag = ""
        self.country = ""
        self.isDefault = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
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
        
        aCoder.encode(isDefault ? "true" : "false", forKey: "isDefault")
    }
}
