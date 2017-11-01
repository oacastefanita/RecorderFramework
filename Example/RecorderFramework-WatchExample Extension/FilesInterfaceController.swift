//
//  FilesInterfaceController.swift
//  RecorderFramework-WatchExample Extension
//
//  Created by Stefanita Oaca on 01/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import WatchKit
import Foundation
import RecorderFramework

class FilesInterfaceController: WKInterfaceController {
    
    @IBOutlet var lblNoData: WKInterfaceLabel!
    @IBOutlet var table: WKInterfaceTable!
    
    var array: [RecordItem]!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        array = (context as! RecordFolder).recordedItems
        table.setNumberOfRows(array.count, withRowType: "filesRow")
        for index in 0..<array.count {
            if let controller = table.rowController(at: index) as? FilesRowController {
                controller.item = array[index]
            }
        }
        
        lblNoData.setHidden(array.count != 0)
        
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
