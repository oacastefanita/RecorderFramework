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
    
    @objc public var localMetadataFile:String! = ""
    @objc public var metadataFilePath:String! = ""
    
    @objc public var fromTrash = false
    
    @objc public var waveRenderVals:NSArray!
    
    //var linkedActionId: String!
    @objc public var shareUrl:String! = ""
    
    @objc public var firstName: String! = ""
    @objc public var lastName: String! = ""
    @objc public var phoneNumber: String! = ""
    @objc public var email: String! = ""
    @objc public var notes: String! = ""
    @objc public var tags: String = ""
    
    @objc public var isStar = false
    
    @objc public var fileData: Data! // for airdrop
    
    @objc public var storageType:StorageType = StorageType.auto
    
    @objc public var audioFileTags:NSMutableArray!
    fileprivate var audioFilePath:String!
    fileprivate var audioMetadataFilePath:String!
    @objc public var metaFileId: String!
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
        
        //        if let value = aDecoder.decodeObjectForKey("linkedActionId") as? String {
        //            self.linkedActionId = value
        //        }
        
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
        
        if let value = self.lastAccessedTime {
            aCoder.encode(value, forKey: "lastAccessedTime")
        }
        
        if let value = self.localFile {
            aCoder.encode(value, forKey: "localFile")
        }
        
        aCoder.encode(fileDownloaded ? "true" : "false", forKey: "fileDownloaded")
        aCoder.encode(fromTrash ? "true" : "false", forKey: "fromTrash")
        aCoder.encode(isStar ? "true" : "false", forKey: "isStar")
        
        if waveRenderVals != nil {
            let data = NSKeyedArchiver.archivedData(withRootObject: waveRenderVals)
            aCoder.encode(data, forKey: "waveRenderVals")
        }
        
        //        if let value = self.linkedActionId {
        //            aCoder.encodeObject(value, forKey: "linkedActionId")
        //        }
        
        if let value = self.shareUrl {
            aCoder.encode(value, forKey: "shareUrl")
        }
        
        aCoder.encode( NSNumber(value:self.storageType.rawValue), forKey: "storageType")
        
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
        
        aCoder.encode(tags, forKey: "tags")
        
        if let value = self.fileData {
            aCoder.encode(value, forKey: "fileData")
        }
        if let value = self.metaFileId {
            aCoder.encode(value, forKey: "metaFileId")
        }
    }
    
    static public  var supportsSecureCoding : Bool {
        return true
    }
    
    public func update(_ item:RecordItem) {
        self.folderId = item.folderId
        self.text = item.text
        self.accessNumber = item.accessNumber
        if self.url != item.url {
            fileDownloaded = false
            localFile = nil
        }
        self.url = item.url
        self.credits = item.credits
        self.time = item.time
        self.duration = item.duration
        self.firstName = item.firstName
        self.lastName = item.lastName
        self.phoneNumber = item.phoneNumber
        self.email = item.email
        self.notes = item.notes
        self.tags = item.tags
        self.fromTrash = item.fromTrash
        self.isStar = item.isStar
        self.metaFileId = item.metaFileId
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
        audioMetadataFilePath = filePath.components(separatedBy: ".")[filePath.components(separatedBy: ".").count - 2] + "_metadata.json"
        
        audioFileTags = NSMutableArray()
        //        definedLabels = NSMutableArray()
        
        //check if file exists
        if(!FileManager.default.fileExists(atPath: audioMetadataFilePath)) {
            let file = NSDictionary();
            file.write(toFile: audioMetadataFilePath, atomically: true);
            
            let outputStream = OutputStream(toFileAtPath: audioMetadataFilePath, append: false)
            outputStream?.open()
            
            JSONSerialization.writeJSONObject(file, to: outputStream!, options: JSONSerialization.WritingOptions.prettyPrinted, error: nil)
            
            outputStream?.close()
            
        } else {
            print("plist already exits at path.")
        }
        
        let jsonData: Data = try! Data(contentsOf: URL(fileURLWithPath: audioMetadataFilePath))
        if jsonData.count == 0{
            return
        }
        do {
            let dict = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
            
            audioFileTags = NSMutableArray()
            
            if (dict.object(forKey: "tags") != nil){
                let tags = dict.object(forKey: "tags") as! NSArray
                for tag in tags {
                    let newTag = AudioTag()
                    newTag.timeStamp = (tag as AnyObject).object(forKey: "timeStamp") as! TimeInterval
                    newTag.duration = (tag as AnyObject).object(forKey: "duration") as! TimeInterval
                    newTag.arg = (tag as AnyObject).object(forKey:"arg") as AnyObject
                    newTag.arg2 = (tag as AnyObject).object(forKey:"arg2") as AnyObject
                    if let value = (tag as AnyObject).object(forKey: "type") as? String
                    {
                        newTag.type = TagType(rawValue: value)!
                    }

                    audioFileTags.add(newTag)
                }
            }
            if (dict.object(forKey: "waveRenderVals") != nil){
                self.waveRenderVals = dict.object(forKey: "waveRenderVals") as! NSArray
            }
        }
        catch {
            
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
    
    //MARK: activity item
//    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
//        return Data()
//    }
//
//    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
//        return self.securelyArchiveRootObject();
//    }
//
//    public func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivityType?, suggestedSize size: CGSize) -> UIImage! {
//        return UIImage(named: "airdroppreview")
//    }
//
//    public func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivityType?) -> String {
//        return "com.werockapps.callrec"
//    }
}

