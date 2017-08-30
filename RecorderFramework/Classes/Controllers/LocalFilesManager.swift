//
//  LocalFilesManager.swift
//  Recorder
//
//  Created by Grif on 18/06/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


public class LocalFilesManager: NSObject {
    public static let sharedInstance = LocalFilesManager()
    
    public var updateInProgress = false
    public var remainingFileSize = 0
    public var handleFileSize = false
    
    public var itemsToDownload = [RecordItem]()
    public var itemsToDelete = [RecordItem]()
    
    public func updateLocalFiles() {
        if updateInProgress {
            return
        }
        updateInProgress = true
        
        itemsToDownload = [RecordItem]()
        itemsToDelete = [RecordItem]()

        var storageDaysOn = false
        //
        // handle last days
        if NSString(string: UserDefaults.standard.object(forKey: "localStorageDaysOn") as! String).boolValue {
            storageDaysOn = true
            let numberOfDays = UserDefaults.standard.integer(forKey: "localStorageDays")
            
            let recList = getAllFiles(1)
            
            for item in recList {
                if item.lastAccessedTime.isEmpty {
                    continue
                }
                let interval = TimeInterval(Int(item.lastAccessedTime)!)
                let date = Date(timeIntervalSince1970: interval)
                let components = (Calendar.current as NSCalendar).components(NSCalendar.Unit.day, from: date, to: Date(), options: NSCalendar.Options())
                if components.day < numberOfDays {
                    if !item.fileDownloaded {
                        // download file
                        itemsToDownload.append(item)
                    }
                }
                else {
                    if item.fileDownloaded {
                        // delete file
                        itemsToDelete.append(item)
                    }
                }
            }
        }
        //
        
        //
        // handle manual actions
        if NSString(string: UserDefaults.standard.object(forKey: "localStorageManualOn") as! String).boolValue {
            let recList = getAllFiles(0)
            
            for item in recList {
                if item.storageType == StorageType.keepLocally {
                    if !itemsToDownload.contains(item) {
                        itemsToDownload.append(item)
                    }
                    if itemsToDelete.contains(item) {
                        if let foundIndex = itemsToDelete.index(of: item) {
                            itemsToDelete.remove(at: foundIndex)
                        }
                   }
                }
                else if item.storageType == StorageType.deleteFromLocalStorage {
                    // add unique to delete list
                    if !itemsToDelete.contains(item) {
                        itemsToDelete.append(item)
                    }
                    if itemsToDownload.contains(item) {
                        if let foundIndex = itemsToDownload.index(of: item) {
                            itemsToDownload.remove(at: foundIndex)
                        }
                    }

                }
            }
        }
        //
        
        
        handleFileSize = NSString(string: UserDefaults.standard.object(forKey: "localStorageMaxSizeOn") as! String).boolValue
        if handleFileSize {
            remainingFileSize = UserDefaults.standard.integer(forKey: "localStorageMaxSize") * 1000000
            // fill the download list with items starting with the most accessed. the download process will stop when the max size is reached
            let recList = getAllFiles(1)
            for item in recList {
                if item.storageType == StorageType.auto && !itemsToDownload.contains(item) {
                    itemsToDownload.append(item)
                }
            }
            itemsToDelete = [RecordItem]()
        }
        else {
            // delete files
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
            
            for item in itemsToDelete {
                let itemPath = path + item.localFile
                item.fileDownloaded = false
                item.localFile = nil
                
                if FileManager.default.fileExists(atPath: itemPath) {
                    do {
                        try FileManager.default.removeItem(atPath: itemPath)
                    }
                    catch{
                        
                    }
                }
            }
            itemsToDelete.removeAll(keepingCapacity: false)
        }
        
        if !storageDaysOn && !handleFileSize {
            let recList = getAllFiles(0)
            for item in recList {
                if item.storageType == StorageType.auto && !itemsToDownload.contains(item) {
                    itemsToDownload.append(item)
                }
            }
        }
        
        // download files
        downloadFiles(itemsToDownload)
    }
    
    public func downloadFiles(_ workingFiles:[RecordItem]){
        if workingFiles.count == 0  {
            updateInProgress = false
            // delete files
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
            
            for item in itemsToDelete {
                item.fileDownloaded = false
                var itemPath = path + item.localFile
                
                if FileManager.default.fileExists(atPath: itemPath) {
                    do {
                        try FileManager.default.removeItem(atPath: itemPath)
                    }
                    catch {
                        
                    }
                }
                
                itemPath = path + item.metadataFilePath
                
                if FileManager.default.fileExists(atPath: itemPath) {
                    do {
                        try FileManager.default.removeItem(atPath: itemPath)
                    }
                    catch {
                        
                    }
                }
                
                //item.localFile = nil
            }
            return
        }
        
        let item = workingFiles.first
        var newFiles = workingFiles
        newFiles.remove(at: 0)
        
        var folder:RecordFolder! = nil
        
        for iterate in RecordingsManager.sharedInstance.recordFolders {
            if iterate.id == "-99" {
                continue
            }
            for recItem in iterate.recordedItems {
                if recItem == item {
                    folder = iterate
                    break
                }
            }
            if folder != nil {
                break
            }
        }
        if folder == nil {
            self.downloadFiles(newFiles)
        }
        else if !item!.fileDownloaded {
            if handleFileSize && remainingFileSize <= 0 && item!.storageType != StorageType.keepLocally {
                self.downloadFiles(newFiles)
            }
            else {
                APIClient.sharedInstance.downloadAudioFile(item!, toFolder: folder.id, completionHandler: { (success) -> Void in
                    var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
                    path += item!.localFile
                    
                    if FileManager.default.fileExists(atPath: path) {
                        self.remainingFileSize -= (try! Data(contentsOf: URL(fileURLWithPath: path))).count
                    }

//                    APIClient.sharedInstance.downloadFile(item!.metadataFilePath, localPath:item!.localMetadataFile, completionHandler: { (Bool success) -> Void in
//                        if success {
//
//                        }
                        self.downloadFiles(newFiles)
//                    })
                })
            }
        }
        else {
            if handleFileSize && remainingFileSize <= 0 && item!.fileDownloaded && item!.storageType != StorageType.keepLocally {
                itemsToDelete.append(item!)
            }
            else {
                var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
                path += item!.localFile
                
                if FileManager.default.fileExists(atPath: path) {
                    remainingFileSize -= (try! Data(contentsOf: URL(fileURLWithPath: path))).count
                }
            }
            self.downloadFiles(newFiles)
        }
    }
    
    public func getAllFiles(_ mode:Int) -> [RecordItem]{
        var recList = [RecordItem]()
        for folder in RecordingsManager.sharedInstance.recordFolders {
            if folder.id == "-99" {
                continue
            }
            for recItem in folder.recordedItems {
                recList.append(recItem)
            }
        }

        if mode != 0 {
            recList = recList.sorted(by: { (obj1:RecordItem, obj2:RecordItem) -> Bool in
                return mode == 1 ? Int(obj1.lastAccessedTime) < Int(obj2.lastAccessedTime) : Int(obj1.time) < Int(obj2.time)
            })
//            recList = recList.sort() { (RecordItem obj1, RecordItem obj2) -> Bool in
//                return mode == 1 ? obj1.lastAccessedTime.Int() < obj2.lastAccessedTime.Int() : obj1.time.Int() < obj2.time.Int()
//            }
        }
        
        return recList
    }
}
