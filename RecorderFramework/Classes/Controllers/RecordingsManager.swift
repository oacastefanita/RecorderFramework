//
//  RecordingsManager.swift
//  Recorder
//
//  Created by Grif on 10/02/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation

public class RecordingsManager : NSObject {
    @objc public static let sharedInstance = RecordingsManager()
    
    @objc public var recordFolders:Array<RecordFolder>!
    
    override public init() {
        super.init()
        recordFolders = Array<RecordFolder>()
    }
    
    func syncItem(_ recordFolder:RecordFolder) -> RecordFolder {
        for existingItem in recordFolders {
            if existingItem.id == recordFolder.id {
                existingItem.update(recordFolder)
                return existingItem
            }
        }
        
        recordFolders.append(recordFolder)
        RecorderFrameworkManager.sharedInstance.saveData()
        return recordFolder
    }
    
    @objc public func getFolderWithId(_ folderId:String!) -> RecordFolder! {
        for folder in recordFolders {
            if folder.id == folderId {
                return folder
            }
        }
        return nil
    }
    
    @objc public func folderForItem(_ itemId: String) -> RecordFolder{
        var folder:RecordFolder! = nil
        
        for iterate in RecordingsManager.sharedInstance.recordFolders {
            if iterate.id == "-99" {
                continue
            }
            for recItem in iterate.recordedItems {
                if recItem.id == itemId {
                    folder = iterate
                    break
                }
            }
            if folder != nil {
                break
            }
        }
        return folder
    }
    
    func deleteRecord(_ recordItem:RecordItem) {
        for folder in recordFolders {
            var index = 0
            for item in folder.recordedItems {
                if item.id == recordItem.id {
                    if recordItem.fileDownloaded && recordItem.localFile != nil {
                        let fileManager = FileManager.default
                        var path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)!.path
                        path += recordItem.localFile
                        
                        if FileManager.default.fileExists(atPath: path) {
                            do {
                                try FileManager.default.removeItem(atPath: path)
                            }
                            catch {
                                
                            }
                        }
                    }
                    
                    folder.recordedItems.remove(at: index)
                    RecorderFrameworkManager.sharedInstance.saveData()
                    return
                }
                index += 1
            }
        }
    }
    
    
    @objc public func getRecordingById(_ id:String) -> RecordItem! {
        for folder in recordFolders {
            for item in folder.recordedItems {
                if item.id == id {
                    return item
                }
            }
        }
        return nil
    }
    
    func searchRecordings(_ name:String) -> Array<SearchResult> {
        var results = Array<SearchResult>()
        for folder in recordFolders {
            if folder.id == "-99"{
                continue
            }
            for item in folder.recordedItems {
                if (item.text.lowercased().range(of: name.lowercased()) != nil) {
                    let result = SearchResult()
                    result.recordItem = item
                    result.recordFolder = folder
                    result.isText = true
                    result.text = item.text
                    results.append(result)
                } else if (item.firstName.lowercased().range(of: name.lowercased()) != nil) {
                    let result = SearchResult()
                    result.recordItem = item
                    result.recordFolder = folder
                    result.text = item.firstName
                    results.append(result)
                } else if (item.lastName.lowercased().range(of: name.lowercased()) != nil) {
                    let result = SearchResult()
                    result.recordItem = item
                    result.recordFolder = folder
                    result.text = item.lastName
                    results.append(result)
                } else if (item.phoneNumber.lowercased().range(of: name.lowercased()) != nil) {
                    let result = SearchResult()
                    result.recordItem = item
                    result.recordFolder = folder
                    result.text = item.phoneNumber
                    results.append(result)
                } else if (item.email.lowercased().range(of: name.lowercased()) != nil) {
                    let result = SearchResult()
                    result.recordItem = item
                    result.recordFolder = folder
                    result.text = item.email
                    results.append(result)
                } else if (item.notes.lowercased().range(of: name.lowercased()) != nil) {
                    let result = SearchResult()
                    result.recordItem = item
                    result.recordFolder = folder
                    result.text = item.notes
                    results.append(result)
                } else if (item.tags.lowercased().range(of: name.lowercased()) != nil) {
                    let result = SearchResult()
                    result.recordItem = item
                    result.recordFolder = folder
                    result.text = item.notes
                    results.append(result)
                }
            }
        }
        return results
    }
    
    func syncRecordingItem(_ recordItem:RecordItem, folder:RecordFolder) -> RecordItem {
        folder.recordedItems.sort { $0.fileOrder > $1.fileOrder }
        var fileInOtherFolder: RecordItem? = nil
        var oldFolder:RecordFolder? = nil
        for recFolder in recordFolders {
            for existingItem in recFolder.recordedItems {
                if existingItem.id == recordItem.id{
                    if folder.id == recFolder.id  && existingItem.updated == recordItem.updated{
                        existingItem.update(recordItem)
                        return existingItem
                    }else{
                        fileInOtherFolder = existingItem
                        oldFolder = recFolder
                    }
                    
                }
            }
        }
        if fileInOtherFolder != nil && oldFolder != nil{
            deleteRecordingItem((fileInOtherFolder?.id)!)
            fileInOtherFolder!.update(recordItem)
        }
        folder.recordedItems.append(recordItem)
        folder.recordedItems.sort { $0.fileOrder > $1.fileOrder }
        RecorderFrameworkManager.sharedInstance.saveData()
        return recordItem
    }
    
    func deleteRecordingItem(_ recordItemId:String) {
        
        for recFolder in recordFolders {
            if recFolder.id == "-99"{
                continue
            }
            for existingItem in recFolder.recordedItems {
                if existingItem.id == recordItemId {
                    recFolder.recordedItems.remove(at: recFolder.recordedItems.index(of: existingItem)!)
                    RecorderFrameworkManager.sharedInstance.saveData()
                    return
                }
            }
        }
    }
    
    func updateAllFilesFolder() {
        if self.recordFolders.count < 2 {
            return
        }
        let allFilesFolder = self.recordFolders[1]
        allFilesFolder.recordedItems.removeAll(keepingCapacity: false)
        
        for recFolder in recordFolders {
            if recFolder.id == "-99" || recFolder.id == "trash" {
                continue
            }
            for existingItem in recFolder.recordedItems {
                allFilesFolder.recordedItems.append(existingItem)
            }
        }
    }
    
    func updateTrashFolder(){
        var trashFolder = RecordFolder()
        for recFolder in recordFolders {
            if recFolder.id == "trash"{
                trashFolder = recFolder
            }
        }
        if let index = self.recordFolders.index(of: trashFolder) {
            self.recordFolders.remove(at: index)
            self.recordFolders.append(trashFolder)
        }
    }
    
    // MARK: clear data
    func clearData() {
        let fileManager = FileManager.default
        var path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)!.path
        
        for recFolder in recordFolders {
            for existingItem in recFolder.recordedItems {
                if existingItem.fileDownloaded {
                    let itemPath = path + existingItem.localFile
                    if FileManager.default.fileExists(atPath: itemPath) {
                        do {
                            try FileManager.default.removeItem(atPath: itemPath)
                        }
                        catch {
                            
                        }
                    }
                }
            }
            recFolder.recordedItems.removeAll(keepingCapacity: false)
        }
        self.recordFolders.removeAll(keepingCapacity: false)
        
        let defaultFolder = RecordFolder()
        defaultFolder.id = "0"
        defaultFolder.title = "New Call Recordings".localized
        RecordingsManager.sharedInstance.recordFolders.insert(defaultFolder, at: 0)
        
        let allFilesFolder = RecordFolder()
        allFilesFolder.id = "-99"
        allFilesFolder.title = "All Files".localized
        RecordingsManager.sharedInstance.recordFolders.insert(allFilesFolder, at: 1)
    }
    
    func getFolderByLinkedAction(_ actionId:String!) -> RecordFolder! {
        for folder in recordFolders {
            var action:Action! = folder.folderNextAction(nil)
            while action != nil {
                if action.id == actionId {
                    return folder
                }
                action = folder.folderNextAction(action)
            }
        }
        return nil
    }
    
    func applyLocalActions() {
        //move actions:
        for folder in recordFolders {
            for var i in (0..<folder.recordedItems.count){
                let item = folder.recordedItems[i]
                var action:Action! = item.recordingNextAction(nil)
                while action != nil {
                    if action.type == ActionType.moveRecording {
                        if folder.id != action.arg2 {
                            for searchFolder in recordFolders {
                                if searchFolder.id == action.arg2 {
                                    searchFolder.recordedItems.append(item)
                                    folder.recordedItems.remove(at: i)
                                    i -= 1
                                }
                            }
                        }
                    }
                    else if action.type == ActionType.renameRecording {
                        item.text = action.arg2
                    }
                    action = item.recordingNextAction(action)
                }
            }
        }
    }
    
    func sortByFolderOrder() {
        recordFolders = recordFolders.sorted { (r1, r2) -> Bool in
            if r1.id == "0" {
                return true
            }
            if r2.id == "0" {
                return false
            }
            if r1.id == "-99" {
                return true
            }
            if r2.id == "-99" {
                return false
            }
            if r1.id == "trash" {
                return false
            }
            if r2.id == "trash" {
                return true
            }
            
            return r1.folderOrder < r2.folderOrder
        }
    }
    
    func keepOnlyItemsWithIds(_ ids:Array<String>) {
        var local = [RecordFolder]()
        
        for item in recordFolders {
            for id in ids {
                if item.id == id {
                    local.append(item)
                }
                else {
                    var action:Action! = item.folderNextAction(nil)
                    while action != nil {
                        if action.type == ActionType.createFolder {
                            local.append(item)
                            break
                        }
                        action = item.folderNextAction(action)
                    }
                }
            }
        }
        recordFolders = local
    }
    
    class func checkAndCreateDefaultFolders(){
        var foundDefault = false
        var foundAllFiles = false
//        var foundTrash = false
        for recordFolder in RecordingsManager.sharedInstance.recordFolders {
            if recordFolder.id == "0" {
                foundDefault = true
                if foundAllFiles && foundDefault && foundTrash{
                    break
                }
            }
            if recordFolder.id == "-99" {
                foundAllFiles = true
                if foundAllFiles && foundDefault && foundTrash{
                    break
                }
            }
//            if recordFolder.id == "trash" {
//                foundTrash = true
//                if foundAllFiles && foundDefault && foundTrash{
//                    break
//                }
//            }
        }
        
        if !foundDefault {
            let defaultFolder = RecordFolder()
            defaultFolder.id = "0"
            defaultFolder.title = "New Call Recordings".localized
            RecordingsManager.sharedInstance.recordFolders.insert(defaultFolder, at: 0)
        }
        if !foundAllFiles {
            let defaultFolder = RecordFolder()
            defaultFolder.id = "-99"
            defaultFolder.title = "All Files".localized
            RecordingsManager.sharedInstance.recordFolders.insert(defaultFolder, at: 1)
        }
//        if !foundTrash {
//            let defaultFolder = RecordFolder()
//            defaultFolder.id = "trash"
//            defaultFolder.title = "Trash".localized
//            RecordingsManager.sharedInstance.recordFolders.insert(defaultFolder, at: 2)
//        }
    }
} 
