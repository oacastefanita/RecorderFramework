//
//  Language.swift
//  Recorder
//
//  Created by Adelina on 7/12/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation

class Language: NSObject {
    var code: String! = ""
    var name:String! = ""

    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        if let value = aDecoder.decodeObject(forKey: "code") as? String {
            self.code = value
        }
        if let value = aDecoder.decodeObject(forKey: "name") as? String {
            self.name = value
        }
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        if let value = self.code {
            aCoder.encode(value, forKey: "code")
        }
        
        if let value = self.name {
            aCoder.encode(value, forKey: "name")
        }
    }
}
