//
//  TagsInterfaceController.swift
//  RecorderFramework-WatchExample Extension
//
//  Created by Stefanita Oaca on 05/12/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import WatchKit
import Foundation
import RecorderFramework

class TagsInterfaceController: WKInterfaceController {
    
    @IBOutlet var lblNoData: WKInterfaceLabel!
    @IBOutlet var table: WKInterfaceTable!
    
    var file: RecordItem!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        file = (context as! RecordItem)
        table.setNumberOfRows(file.audioFileTags.count, withRowType: "tagsRow")
        for index in 0..<file.audioFileTags.count {
            if let controller = table.rowController(at: index) as? TagsRowController {
                controller.item = file.audioFileTags[index] as! AudioTag
            }
        }
        
        lblNoData.setHidden(file.audioFileTags.count != 0)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
    }
}
