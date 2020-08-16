//
//  Extensions.swift
//  RECCALL
//
//  Created by Marius Avram on 8/14/20.
//  Copyright © 2020 Codapper Software. All rights reserved.
//

import UIKit

extension String {
    func encodedString() -> String {
        if let cstring = NSString.init(utf8String: self.cString(using: String.Encoding.utf8)!) {
            if let msgData = cstring.data(using:String.Encoding.nonLossyASCII.rawValue) {
                if let encoded = NSString(data: msgData, encoding: String.Encoding.utf8.rawValue) {
                    return encoded as String
                }
            }
        }
        return self
    }
    
    func decodedString() -> String {
        if let newData = self.data(using: String.Encoding.utf8) {
            if let decoded = NSString(data: newData, encoding: String.Encoding.nonLossyASCII.rawValue) {
                return decoded as String
            }
        }
        return self
    }
}
