//
//  FilesRowController.swift
//  RecorderFramework-WatchExample Extension
//
//  Created by Stefanita Oaca on 01/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import WatchKit
import RecorderFramework

class FilesRowController: NSObject {
    @IBOutlet var separator: WKInterfaceSeparator!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    
    var item: RecordItem? {
        
        didSet {
            if let item = item {
                if item.text != nil && !item.text.isEmpty {
                    titleLabel.setText(item.text)
                }
                else if item.accessNumber != nil && !item.accessNumber.isEmpty {
                    titleLabel.setText(item.accessNumber)
                }
                else {
                    titleLabel.setText("Untitled".localized)
                }
            }
        }
    }
}
