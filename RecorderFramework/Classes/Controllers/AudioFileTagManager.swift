//
//  AudioFileTagManager.swift
//  Recorder
//
//  Created by Grif on 15/08/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import UIKit

public enum TagType : Int {
    case label
    case important
    case note
    case photo
}

public class AudioTag: NSObject {
    var type:TagType = TagType.label
    var timeStamp:TimeInterval!
    var duration:TimeInterval!
    var arg:AnyObject!
}

public class AudioFileTagManager: NSObject {
    public static let sharedInstance = AudioFileTagManager()

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
    
    func setupWithFile(_ filePath:String) {
        audioFilePath = filePath
        audioMetadataFilePath = filePath.components(separatedBy: ".")[filePath.components(separatedBy: ".").count - 2] + "_metadata.json"
        
        audioFileTags = NSMutableArray()
//        definedLabels = NSMutableArray()
        
        //check if file exists
        if(!FileManager.default.fileExists(atPath: audioMetadataFilePath)) {
            let file = NSDictionary();
            file.write(toFile: audioMetadataFilePath, atomically: true);
            
            var error:NSError
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
                    newTag.arg = (tag as AnyObject).object(forKey: "arg") as! AnyObject
                    if((tag as AnyObject).object(forKey: "type") as! String == "Label")
                    {
                        newTag.type = TagType.label
                    }
                    else if((tag as AnyObject).object(forKey: "type") as! String == "Important")
                    {
                        newTag.type = TagType.important
                    }
                    else if((tag as AnyObject).object(forKey: "type") as! String == "Note")
                    {
                        newTag.type = TagType.note
                    }
                    else if((tag as AnyObject).object(forKey: "type") as! String == "Photo")
                    {
                        newTag.type = TagType.photo
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
    
    func saveToFile(){
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
            
            switch (tag as! AudioTag) .type
            {
                case TagType.label:
                newDict.setObject("Label", forKey: "type" as NSCopying)
                break
                
                case TagType.important:
                newDict.setObject("Important", forKey: "type" as NSCopying)
                break
                
                case TagType.note:
                newDict.setObject("Note", forKey: "type" as NSCopying)
                break
                
                case TagType.photo:
                newDict.setObject("Photo", forKey: "type" as NSCopying)
                break
                
                default:
                break
            }
            tags.add(newDict);
        }
        
        let myDict = NSMutableDictionary()
        myDict.setObject(tags, forKey: "tags" as NSCopying)
        
        if(self.waveRenderVals != nil){
            myDict.setObject(self.waveRenderVals, forKey: "waveRenderVals" as NSCopying)
        }
        
        var error:NSError
        let outputStream = OutputStream(toFileAtPath: audioMetadataFilePath, append: false)
        outputStream?.open()
        
        JSONSerialization.writeJSONObject(myDict, to: outputStream!, options: JSONSerialization.WritingOptions.prettyPrinted, error: nil)
        
        outputStream?.close()
    }
    
    func updateWaveRenderVals(_ waveRenderVals:NSArray){
        self.waveRenderVals = waveRenderVals
        saveToFile();
    }
    
    func addLabel(_ timeStamp:TimeInterval, duration:TimeInterval, label:String!) {
        let newTag = AudioTag()
        newTag.type = TagType.label
        newTag.timeStamp = timeStamp
        newTag.duration = duration
        newTag.arg = label as AnyObject
        
        audioFileTags.add(newTag)
        saveToFile();
    }
    
    func addImportant(_ timeStamp:TimeInterval, duration:TimeInterval) {
        let newTag = AudioTag()
        newTag.type = TagType.important
        newTag.timeStamp = timeStamp
        newTag.duration = duration
        
        audioFileTags.add(newTag)
        saveToFile();
    }
    
    func addNote(_ timeStamp:TimeInterval, duration:TimeInterval, note:String!) {
        let newTag = AudioTag()
        newTag.type = TagType.note
        newTag.timeStamp = timeStamp
        newTag.duration = duration
        newTag.arg = note as AnyObject
        
        audioFileTags.add(newTag)
        saveToFile();
    }

    
    func addPhoto(_ timeStamp:TimeInterval, duration:TimeInterval, path:String!) {
        let newTag = AudioTag()
        newTag.type = TagType.photo
        newTag.timeStamp = timeStamp
        newTag.duration = duration
        newTag.arg = path as AnyObject
        
        audioFileTags.add(newTag)
        saveToFile();
    }
}
