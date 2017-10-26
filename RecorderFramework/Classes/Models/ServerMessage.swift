//
//  ServerMessage.swift
//  Recorder
//
//  Created by Adelina on 7/31/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation

public class ServerMessage: NSObject, NSCoding {
    @objc public var id: String! = ""
    @objc public var title:String! = ""
    @objc public var body:String! = ""
    @objc public var time:String! = ""
    @objc public var read: Bool = false
    
    override public init() {
        super.init()
    }
    
    public func getDate() -> Date
    {
        //Create Date Formatter
        let dateFormatter = DateFormatter()
        
        //Specify Format of String to Parse
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        //Parse into NSDate
        let dateFromString : Date = dateFormatter.date(from: self.time)!
        
        //Return Parsed Date
        return dateFromString
    }
    
    public required init?(coder aDecoder: NSCoder){
        if let value = aDecoder.decodeObject(forKey: "id") as? String {
            self.id = value
        }
        if let value = aDecoder.decodeObject(forKey: "title") as? String {
            self.title = value
        }
        if let value = aDecoder.decodeObject(forKey: "body") as? String {
            self.body = value
        }
        if let value = aDecoder.decodeObject(forKey: "time") as? String {
            self.time = value
        }
        if let value = aDecoder.decodeObject(forKey: "read") as? String {
            self.read = NSString(string: value).boolValue
        }
    }
    
     public func encode(with aCoder: NSCoder) {
        if let value = self.id {
            aCoder.encode(value, forKey: "id")
        }
        if let value = self.title {
            aCoder.encode(value, forKey: "title")
        }
        if let value = self.body {
            aCoder.encode(value, forKey: "body")
        }
        if let value = self.time {
            aCoder.encode(value, forKey: "time")
        }
        aCoder.encode(read ? "true" : "false", forKey: "read")
    }
}

