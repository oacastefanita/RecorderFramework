//
//  TagsRowController.swift
//  RecorderFramework-WatchExample Extension
//
//  Created by Stefanita Oaca on 05/12/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import WatchKit
import RecorderFramework

class TagsRowController: NSObject {
    @IBOutlet var separator: WKInterfaceSeparator!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    
    var item: AudioTag? {
        
        didSet {
            if let item = item {
                titleLabel.setText(item.type.rawValue)
            }
        }
    }
}
