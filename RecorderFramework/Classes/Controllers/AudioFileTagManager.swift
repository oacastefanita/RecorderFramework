//
//  AudioFileTagManager.swift
//  Recorder
//
//  Created by Grif on 15/08/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//


public enum TagType : String {
    case note = "note"
    case todo = "todo"
    case date = "date"
    case alert = "alert"
    case images = "images"
    case audio = "audio"
    case video = "video"
    case tags = "tags"
    case beforeAfter = "beforeAfter"
    case panorama = "panorama"
    case productViewer = "productViewer"
    case pageFlip = "pageFlip"
    case location = "location"
    case phoneNumber = "phoneNumber"
    case socialMedia = "socialMedia"
    case imageURL = "imageURL"
    case htmlEmbed = "htmlEmbed"
}

public class AudioTag: NSObject {
    public var type:TagType = TagType.note
    public var timeStamp:TimeInterval!
    public var duration:TimeInterval!
    public var arg:AnyObject!
    public var arg2:AnyObject!
}

class AudioFileTagManager: NSObject {
    static let sharedInstance = AudioFileTagManager()

    var audioFileTags:NSMutableArray!
    fileprivate var audioFilePath:String!
    fileprivate var audioMetadataFilePath:String!
    var waveRenderVals:NSArray!
    
    var definedLabels:NSMutableArray!
    
    func removeMetadataFile(_ filePath:String){
        let metaPath = filePath.components(separatedBy: ".")[filePath.components(separatedBy: ".").count - 2] + "_metadata.json"
        if(FileManager.default.fileExists(atPath: metaPath)) {
            do {
                try FileManager.default.removeItem(atPath: metaPath)
            }
            catch {
                
            }
        }
    }
    
    func getMetadataFilePath(_ filePath:String) -> String{
        return filePath.components(separatedBy: ".")[filePath.components(separatedBy: ".").count - 2] + "_metadata.json"
    }
    
    func getPhotoFilePath(_ filePath:String,time:TimeInterval) -> String{
        
        let seconds = Int(time)
        let milisec = Int((Float(time) - Float(seconds)) * 1000)
        let newpath = String(format:"__%d_%d.png",seconds, milisec)
        return filePath.components(separatedBy: ".")[filePath.components(separatedBy: ".").count - 2] + newpath
    }
    
    func getPhotoFilePath(_ filePath:String,time:TimeInterval, index: Int) -> String{
        
        let seconds = Int(time)
        let milisec = Int((Float(time) - Float(seconds)) * 1000)
        let newpath = String(format:"__%d_%d_%d.png",seconds, milisec, index)
        return filePath.components(separatedBy: ".")[filePath.components(separatedBy: ".").count - 2] + newpath
    }
    
    func setupWithFile(_ filePath:String) {
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
    
    public func saveToFile(){
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
    
    func updateWaveRenderVals(_ waveRenderVals:NSArray){
        self.waveRenderVals = waveRenderVals
        saveToFile();
    }
    
//    func addLabel(_ timeStamp:TimeInterval, duration:TimeInterval, label:String!) {
//        let newTag = AudioTag()
//        newTag.type = TagType.label
//        newTag.timeStamp = timeStamp
//        newTag.duration = duration
//        newTag.arg = label as AnyObject
//        
//        audioFileTags.add(newTag)
//        saveToFile();
//    }
//    
//    func addImportant(_ timeStamp:TimeInterval, duration:TimeInterval) {
//        let newTag = AudioTag()
//        newTag.type = TagType.important
//        newTag.timeStamp = timeStamp
//        newTag.duration = duration
//        
//        audioFileTags.add(newTag)
//        saveToFile();
//    }
//    
//    func addNote(_ timeStamp:TimeInterval, duration:TimeInterval, note:String!) {
//        let newTag = AudioTag()
//        newTag.type = TagType.note
//        newTag.timeStamp = timeStamp
//        newTag.duration = duration
//        newTag.arg = note as AnyObject
//        
//        audioFileTags.add(newTag)
//        saveToFile();
//    }
//
//    
//    func addPhoto(_ timeStamp:TimeInterval, duration:TimeInterval, path:String!) {
//        let newTag = AudioTag()
//        newTag.type = TagType.photo
//        newTag.timeStamp = timeStamp
//        newTag.duration = duration
//        newTag.arg = path as AnyObject
//        
//        audioFileTags.add(newTag)
//        saveToFile();
//    }
}
