//
//  RecordFolder.swift
//  Recorder
//
//  Created by Grif on 14/02/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation

@objc public enum FolderColor : Int {
    case blue = 0
    case red
    case purple
    case green
}


public class RecordFolder: NSObject, NSCoding {
    @objc public var title: String!
    @objc public var id: String!
    @objc public var created: String!
    @objc public var folderOrder:Int = 0
    @objc public var password: String!
    @objc public var passwordHint: String!
    @objc public var type:StorageType = StorageType.keepLocally
    @objc public var recordedItems = [RecordItem]()
    @objc public var isStar:Bool = false
    @objc public var color:FolderColor = FolderColor.blue
    
    override public init() {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder){
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
        if let value = aDecoder.decodeObject(forKey: "password") as? String {
            self.password = value
        }
        if let value = aDecoder.decodeObject(forKey: "passwordHint") as? String {
            self.passwordHint = value
        }
        if let data = aDecoder.decodeObject(forKey: "recordItems") as? Data {
            recordedItems = NSKeyedUnarchiver.unarchiveObject(with: data) as! Array<RecordItem>
        }
        if let value = aDecoder.decodeObject(forKey: "is_star") as? String {
            self.isStar = value == "1"
        }
        if let value = aDecoder.decodeObject(forKey: "folder_color") as? NSNumber, let color = FolderColor(rawValue: value.intValue) {
            self.color = color
        }
    }
    
    public func encode(with aCoder: NSCoder) {
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
        if let value = self.password {
            aCoder.encode(value, forKey: "password")
        }

        if let value = self.passwordHint {
            aCoder.encode(value, forKey: "passwordHint")
        }
        
        aCoder.encode(isStar ? "1" : "0", forKey: "is_star")
        
        let data = NSKeyedArchiver.archivedData(withRootObject: recordedItems)
        aCoder.encode(data, forKey: "recordItems")
        
        aCoder.encode(color.rawValue, forKey: "folder_color")
    }
    
    public func keepOnlyItemsWithIds(_ ids:Array<String>) {
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
    
    public func update(_ item:RecordFolder) {
        self.title = item.title
        self.created = item.created
        self.folderOrder = item.folderOrder
        self.isStar = item.isStar
        self.color = item.color
    }
    
    public func folderNextAction(_ currentAction:Action!) -> Action! {
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

