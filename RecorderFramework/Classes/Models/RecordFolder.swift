//
//  RecordFolder.swift
//  Recorder
//
//  Created by Grif on 14/02/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation

class RecordFolder: NSObject, NSCoding {
    var title: String!
    var id: String!
    var created: String!
    var folderOrder:Int = 0
    //var linkedActionId: String!
    
    var type:StorageType = StorageType.keepLocally
    var recordedItems = [RecordItem]()
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let value = aDecoder.decodeObject(forKey: "title") as? String {
            self.title = value
        }
        if let value = aDecoder.decodeObject(forKey: "id") as? String {
            self.id = value
        }
        if let value = aDecoder.decodeObject(forKey: "created") as? String {
            self.created = value
        }
        if let value = aDecoder.decodeObject(forKey: "folder_order") as? String {
            self.folderOrder = Int(value)!
        }
        
//        if let value = aDecoder.decodeObjectForKey("linkedActionId") as? String {
//            self.linkedActionId = value
//        }

        if let data = aDecoder.decodeObject(forKey: "recordItems") as? Data {
            recordedItems = NSKeyedUnarchiver.unarchiveObject(with: data) as! Array<RecordItem>
        }
    }
    
    func encode(with aCoder: NSCoder) {
        if let value = self.title {
            aCoder.encode(value, forKey: "title")
        }
        if let value = self.id {
            aCoder.encode(value, forKey: "id")
        }
        if let value = self.created {
            aCoder.encode(value, forKey: "created")
        }
        
        aCoder.encode(String(folderOrder), forKey: "folder_order")
        
//        if let value = self.linkedActionId {
//            aCoder.encodeObject(value, forKey: "linkedActionId")
//        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: recordedItems)
        aCoder.encode(data, forKey: "recordItems")
    }
    
    func keepOnlyItemsWithIds(_ ids:Array<String>) {
        var local = [RecordItem]()
        
        for item in recordedItems {
            for id in ids {
                if item.id == id {
                    local.append(item)
                    break;
                }
            }
        }
        recordedItems = local
    }
    
    func update(_ item:RecordFolder) {
        self.title = item.title
        self.created = item.created
        self.folderOrder = item.folderOrder
    }
    
    func folderNextAction(_ currentAction:Action!) -> Action! {
        var currentFound = currentAction == nil
        for action in ActionsSyncManager.sharedInstance.actions {
            if action.arg1 == self.id {
                if currentFound {
                    return action
                }
                else if currentAction == action {
                    currentFound = true
                }
            }
        }
        return nil
    }

}
