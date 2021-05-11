//
//  RecordItem.swift
//  Recorder
//
//  Created by Grif on 24/01/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation

@objc public enum StorageType : Int {
    case auto = 0
    case keepLocally
    case deleteFromLocalStorage
}

public class RecordItem: NSObject, NSSecureCoding {
    @objc public var folderId: String! = ""
    @objc public var text: String! = ""
    @objc public var id:String! = ""
    @objc public var accessNumber:String! = ""
    @objc public var phone:String! = ""
    @objc public var url:String! = ""
    @objc public var credits:String! = ""
    @objc public var duration:String! = ""
    @objc public var time:String! = ""
    @objc public var lastAccessedTime:String! = ""
    @objc public var fileDownloaded = false
    @objc public var localFile:String! = ""
    @objc public var fileSize:String! = ""
    @objc public var localMetadataFile:String! = ""
    @objc public var metadataFilePath:String! = ""
    @objc public var fromTrash = false
    @objc public var waveRenderVals:NSArray!
    @objc public var shareUrl:String! = ""
    @objc public var firstName: String! = ""
    @objc public var lastName: String! = ""
    @objc public var phoneNumber: String! = ""
    @objc public var email: String! = ""
    @objc public var notes: String! = ""
    @objc public var tags: String = ""
    @objc public var isStar = false
    @objc public var isFree = false
    @objc public var fileData: Data! // for airdrop
    @objc public var storageType:StorageType = StorageType.auto
    @objc public var audioFileTags:NSMutableArray!
    fileprivate var audioFilePath:String!
    fileprivate var audioMetadataFilePath:String!
    @objc public var metaFileId: String!
    @objc public var remindDate:String! = ""
    @objc public var remindDays:String! = ""
    @objc public var updated:String! = ""
    @objc public var fileOrder:Int = 0
    @objc public var created:String! = ""
    @objc public var chanels:Int = 0
    @objc public var sampleRate:Int = 0
    
    override public init() {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder){
        if let value = aDecoder.decodeObject(forKey: "folderId") as? String {
            self.folderId = value
        }
        if let value = aDecoder.decodeObject(forKey: "title") as? String {
            self.text = value
        }
        if let value = aDecoder.decodeObject(forKey: "id") as? String {
            self.id = value
        }
        if let value = aDecoder.decodeObject(forKey: "accessNumber") as? String {
            self.accessNumber = value
        }
        if let value = aDecoder.decodeObject(forKey: "phone") as? String {
            self.phone = value
        }
        if let value = aDecoder.decodeObject(forKey: "url") as? String {
            self.url = value
        }
        if let value = aDecoder.decodeObject(forKey: "credits") as? String {
            self.credits = value
        }
        if let value = aDecoder.decodeObject(forKey: "duration") as? String {
            self.duration = value
        }
        if let value = aDecoder.decodeObject(forKey: "time") as? String {
            self.time = value
        }
        if let value = aDecoder.decodeObject(forKey: "lastAccessedTime") as? String {
            self.lastAccessedTime = value
        }
        else {
            self.lastAccessedTime = self.time
        }
        if let value = aDecoder.decodeObject(forKey: "localFile") as? String {
            self.localFile = value
        }
        if let value = aDecoder.decodeObject(forKey: "fileDownloaded") as? String {
            self.fileDownloaded = NSString(string: value).boolValue
        }
        if let value = aDecoder.decodeObject(forKey: "fromTrash") as? String {
            self.fromTrash = NSString(string: value).boolValue
        }
        if let value = aDecoder.decodeObject(forKey: "isStar") as? String {
            self.isStar = NSString(string: value).boolValue
        }
        if let data = aDecoder.decodeObject(forKey: "waveRenderVals") as? Data {
            if data.count > 0{
                waveRenderVals = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSArray
            }
        }
        if let value = aDecoder.decodeObject(forKey: "shareUrl") as? String {
            self.shareUrl = value
        }
        if let value: AnyObject = aDecoder.decodeObject(forKey: "storageType") as? NSNumber{
            self.storageType = StorageType(rawValue: value.intValue)!
        }
        if let value = aDecoder.decodeObject(forKey: "firstName") as? String {
            self.firstName = value
        }
        if let value = aDecoder.decodeObject(forKey: "lastName") as? String {
            self.lastName = value
        }
        if let value = aDecoder.decodeObject(forKey: "phoneNumber") as? String {
            self.phoneNumber = value
        }
        if let value = aDecoder.decodeObject(forKey: "email") as? String {
            self.email = value
        }
        if let value = aDecoder.decodeObject(forKey: "notes") as? String {
            self.notes = value
        }
        if let value = aDecoder.decodeObject(forKey: "tags") as? String {
            self.tags = value
        }
        if let value = aDecoder.decodeObject(forKey: "fileData") as? Data {
            self.fileData = value
        }
        if let value = aDecoder.decodeObject(forKey: "metaFileId") as? String {
            self.metaFileId = value
        }
        if let value = aDecoder.decodeObject(forKey: "remind_date") as? String {
            self.remindDate = value
        }
        if let value = aDecoder.decodeObject(forKey: "remind_days") as? String {
            self.remindDays = value
        }
        if let value = aDecoder.decodeObject(forKey: "fileSize") as? String {
            self.fileSize = value
        }
        if let value = aDecoder.decodeObject(forKey: "isFree") as? String {
            self.isFree = NSString(string: value).boolValue
        }
        if let value = aDecoder.decodeObject(forKey: "updated") as? String {
            self.updated = value
        }
        if let value = aDecoder.decodeObject(forKey: "text") as? String {
            self.text = value
        }
        if let value = aDecoder.decodeObject(forKey: "fileOrder") as? Int {
            self.fileOrder = value
        }
        if let value = aDecoder.decodeObject(forKey: "created") as? String {
            self.created = value
        }
        if let value = aDecoder.decodeObject(forKey: "chanels") as? Int {
            self.chanels = value
        }
        if let value = aDecoder.decodeObject(forKey: "sampleRate") as? Int {
            self.sampleRate = value
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        if let value = self.folderId {
            aCoder.encode(value, forKey: "folderId")
        }
        if let value = self.text {
            aCoder.encode(value, forKey: "title")
        }
        if let value = self.id {
            aCoder.encode(value, forKey: "id")
        }
        if let value = self.accessNumber {
            aCoder.encode(value, forKey: "accessNumber")
        }
        if let value = self.url {
            aCoder.encode(value, forKey: "url")
        }
        if let value = self.credits {
            aCoder.encode(value, forKey: "credits")
        }
        if let value = self.duration {
            aCoder.encode(value, forKey: "duration")
        }
        if let value = self.time {
            aCoder.encode(value, forKey: "time")
        }
        if let value = self.updated {
            aCoder.encode(value, forKey: "updated")
        }
        if let value = self.lastAccessedTime {
            aCoder.encode(value, forKey: "lastAccessedTime")
        }
        if let value = self.localFile {
            aCoder.encode(value, forKey: "localFile")
        }
        if waveRenderVals != nil {
            let data = NSKeyedArchiver.archivedData(withRootObject: waveRenderVals)
            aCoder.encode(data, forKey: "waveRenderVals")
        }
        if let value = self.shareUrl {
            aCoder.encode(value, forKey: "shareUrl")
        }
        if let value = self.firstName {
            aCoder.encode(value, forKey: "firstName")
        }
        if let value = self.lastName {
            aCoder.encode(value, forKey: "lastName")
        }
        if let value = self.phoneNumber {
            aCoder.encode(value, forKey: "phoneNumber")
        }
        if let value = self.email {
            aCoder.encode(value, forKey: "email")
        }
        if let value = self.notes {
            aCoder.encode(value, forKey: "notes")
        }
        if let value = self.fileData {
            aCoder.encode(value, forKey: "fileData")
        }
        if let value = self.metaFileId {
            aCoder.encode(value, forKey: "metaFileId")
        }
        if let value = self.fileSize {
            aCoder.encode(value, forKey: "fileSize")
        }
        if let value = self.text {
            aCoder.encode(value, forKey: "text")
        }
        if let value = self.created {
            aCoder.encode(value, forKey: "created")
        }
        aCoder.encode(fileDownloaded ? "true" : "false", forKey: "fileDownloaded")
        aCoder.encode(fromTrash ? "true" : "false", forKey: "fromTrash")
        aCoder.encode(isStar ? "true" : "false", forKey: "isStar")
        aCoder.encode( NSNumber(value:self.storageType.rawValue), forKey: "storageType")
        aCoder.encode(tags, forKey: "tags")
        aCoder.encode(isFree ? "true" : "false", forKey: "isFree")
        aCoder.encode(self.fileOrder, forKey: "fileOrder")
        aCoder.encode(self.chanels, forKey: "chanels")
        aCoder.encode(self.sampleRate, forKey: "sampleRate")
    }
    
    static public  var supportsSecureCoding : Bool {
        return true
    }
    
    public func update(_ item:RecordItem) {
        if item.fileSize != nil && !item.fileSize.isEmpty {
            self.fileSize = item.fileSize
        }
        if item.time != nil && !item.time.isEmpty {
            self.time = item.time
        }
        if item.updated != nil && !item.updated.isEmpty {
            self.updated = item.updated
        }
        self.folderId = item.folderId
        self.text = item.text
        self.accessNumber = item.accessNumber
        self.url = item.url
        self.credits = item.credits
        self.duration = item.duration
        self.firstName = item.firstName
        self.lastName = item.lastName
        self.phoneNumber = item.phoneNumber
        self.email = item.email
        self.notes = item.notes
        self.tags = item.tags
        self.fromTrash = item.fromTrash
        self.isStar = item.isStar
        self.remindDays = item.remindDays
        self.remindDate = item.remindDate
        self.isFree = item.isFree
        self.text = item.text
        self.fileOrder = item.fileOrder
        self.created = item.created
        self.chanels = item.chanels
        self.sampleRate = item.sampleRate
    }
    
    public func recordingNextAction(_ currentAction:Action!) -> Action! {
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
    
    public func securelyArchiveRootObject() -> Data {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.requiresSecureCoding = true
        
        let fileManager = FileManager.default
        var path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)!.path
        path += self.localFile
        if FileManager.default.fileExists(atPath: path) {
            self.fileData = try? Data(contentsOf: URL(fileURLWithPath: path))
        }
        
        archiver.encode(self, forKey: "AirDropRecording")
        archiver.finishEncoding()
        
        return data as Data
    }
    
    public class func securelyUnarchiveProfileWithFile(_ filePath:String) -> RecordItem {
        let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        let unarchiver = NSKeyedUnarchiver(forReadingWith: fileData!)
        
        unarchiver.requiresSecureCoding = true
        if let recItem = unarchiver.decodeObject(of: RecordItem.self, forKey: "AirDropRecording"){
            if let retRecItem = recItem as? RecordItem {
                return retRecItem
            }
        }
        
        return RecordItem()
    }
    
    public func setupWithFile(_ filePath:String) {
        audioFilePath = filePath
        if filePath.components(separatedBy: ".").count >= 2{
            let components = filePath.components(separatedBy: ".").dropLast()
            audioMetadataFilePath = components.joined(separator: ".") + "_metadata.json"
        }
        else{
            return
        }
        
        audioFileTags = NSMutableArray()
        if filePath.components(separatedBy: ".").count == 3{
            return
        }
        if(FileManager.default.fileExists(atPath: audioMetadataFilePath)) {
            do {
                let jsonData: Data = try Data(contentsOf: URL(fileURLWithPath: audioMetadataFilePath))
                if jsonData.count == 0{
                    return
                }
                let dict = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                
                audioFileTags = NSMutableArray()
                
                if (dict.object(forKey: "tags") != nil){
                    let tags = dict.object(forKey: "tags") as! NSArray
                    for tag in tags {
                        let newTag = AudioTag()
                        if let timeStamp = (tag as AnyObject).object(forKey: "timeStamp") as? TimeInterval
                        {
                            newTag.timeStamp = timeStamp
                        }else{
                            continue
                        }
                        if let duration = (tag as AnyObject).object(forKey: "duration") as? TimeInterval{
                            newTag.duration = duration
                        }else{
                            continue
                        }
                        
                        if let arg = (tag as AnyObject).object(forKey:"arg") as? AnyObject{
                            newTag.arg = arg
                        }else{
                            continue
                        }
                        
                        if let arg2 = (tag as AnyObject).object(forKey:"arg2") as? AnyObject{
                            newTag.arg2 = arg2
                        }else{
                            continue
                        }
                        
                        if let value = (tag as AnyObject).object(forKey: "type") as? String
                        {
                            if let type = TagType(rawValue: value.lowercased()) {
                                newTag.type = type
                                audioFileTags.add(newTag) //add tag only if valid tag type
                            }
                        }
                    }
                }
            } catch  {
                
            }
        }
    }
    
    @objc public func saveToFile(){
        let tags = NSMutableArray()
        for tag in audioFileTags {
            let newDict = NSMutableDictionary()
            if((tag as! AudioTag).timeStamp != nil){
                newDict.setObject((tag as! AudioTag).timeStamp, forKey: "timeStamp" as NSCopying)
            }
            if((tag as! AudioTag).duration != nil){
                newDict.setObject((tag as! AudioTag).duration, forKey: "duration" as NSCopying)
            }
            if((tag as! AudioTag).arg != nil){
                newDict.setObject((tag as! AudioTag).arg, forKey: "arg" as NSCopying)
            }
            if((tag as! AudioTag).arg2 != nil){
                newDict.setObject((tag as! AudioTag).arg2, forKey: "arg2" as NSCopying)
            }
            newDict.setObject((tag as! AudioTag).type.rawValue, forKey: "type" as NSCopying)
            
            tags.add(newDict);
        }
        
        let myDict = NSMutableDictionary()
        myDict.setObject(tags, forKey: "tags" as NSCopying)
        
        if(self.waveRenderVals != nil){
            myDict.setObject(self.waveRenderVals, forKey: "waveRenderVals" as NSCopying)
        }
        
        let outputStream = OutputStream(toFileAtPath: audioMetadataFilePath, append: false)
        outputStream?.open()
        
        JSONSerialization.writeJSONObject(myDict, to: outputStream!, options: JSONSerialization.WritingOptions.prettyPrinted, error: nil)
        
        outputStream?.close()
    }
}
