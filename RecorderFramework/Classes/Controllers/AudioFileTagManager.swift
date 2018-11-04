//
//  AudioFileTagManager.swift
//  Recorder
//
//  Created by Grif on 15/08/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

class AudioFileTagManager: NSObject {
    static let sharedInstance = AudioFileTagManager()
    
    var waveRenderVals:NSArray!
    var definedLabels:NSMutableArray!
    var audioFileTags:NSMutableArray!
    
    fileprivate var audioFilePath:String!
    fileprivate var audioMetadataFilePath:String!
    
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
        var newFilePath = filePath
        if filePath.contains(RecorderFrameworkManager.sharedInstance.containerName){
            newFilePath = filePath.replacingOccurrences(of: RecorderFrameworkManager.sharedInstance.containerName, with: "#$#$")
        }
        let seconds = Int(time)
        let milisec = Int((Float(time) - Float(seconds)) * 1000)
        let newpath = String(format:"__%d_%d.png",seconds, milisec)
        
        var path = newFilePath.components(separatedBy: ".")[newFilePath.components(separatedBy: ".").count - 2] + newpath
        if path.contains("#$#$"){
            path = path.replacingOccurrences(of: "#$#$", with: RecorderFrameworkManager.sharedInstance.containerName)
        }
        return path
    }
    
    func getPhotoFilePath(_ filePath:String,time:TimeInterval, index: Int) -> String{
        var newFilePath = filePath
        if filePath.contains(RecorderFrameworkManager.sharedInstance.containerName){
            newFilePath = filePath.replacingOccurrences(of: RecorderFrameworkManager.sharedInstance.containerName, with: "#$#$")
        }
        let seconds = Int(time)
        let milisec = Int((Float(time) - Float(seconds)) * 1000)
        let newpath = String(format:"__%d_%d_%d.png",seconds, milisec, index)
        
        var path = newFilePath.components(separatedBy: ".")[newFilePath.components(separatedBy: ".").count - 2] + newpath
        if path.contains("#$#$"){
            path = path.replacingOccurrences(of: "#$#$", with: RecorderFrameworkManager.sharedInstance.containerName)
        }
        return path
    }
    
    func setupWithFile(_ filePath:String) {
        audioFilePath = filePath
        audioMetadataFilePath = filePath.components(separatedBy: ".")[filePath.components(separatedBy: ".").count - 2] + "_metadata.json"
        audioFileTags = NSMutableArray()
        checkAndCreateAudioMetadataFile()
        
        let jsonData: Data = try! Data(contentsOf: URL(fileURLWithPath: audioMetadataFilePath))
        if jsonData.count == 0{
            return
        }
        
        do {
            let dict = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
            if (dict.object(forKey: "tags") != nil){
                let tags = dict.object(forKey: "tags") as! NSArray
                for tag in tags {
                    let newTag = RecorderFactory.createAudioTagFromDict(tag as! NSDictionary)
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
    
    func checkAndCreateAudioMetadataFile(){
        //check if file exists
        if(!FileManager.default.fileExists(atPath: audioMetadataFilePath)) {
            writeDictAtPath(dict: NSDictionary(), path: audioMetadataFilePath)
        } else {
            print("file already exits at path.")
        }
    }
    
    public func saveToFile(){
        let tags = NSMutableArray()
        for tag in audioFileTags {
            let newDict = RecorderFactory.createDictFromAudioTag(tag as! AudioTag)
            tags.add(newDict);
        }
        
        let myDict = NSMutableDictionary()
        myDict.setObject(tags, forKey: "tags" as NSCopying)
        
        if(self.waveRenderVals != nil){
            myDict.setObject(self.waveRenderVals, forKey: "waveRenderVals" as NSCopying)
        }
        
        writeDictAtPath(dict: myDict, path: audioMetadataFilePath)
    }
    
    func writeDictAtPath(dict: NSDictionary, path: String){
        let outputStream = OutputStream(toFileAtPath: path, append: false)
        outputStream?.open()
        JSONSerialization.writeJSONObject(dict, to: outputStream!, options: JSONSerialization.WritingOptions.prettyPrinted, error: nil)
        outputStream?.close()
    }
    
    func updateWaveRenderVals(_ waveRenderVals:NSArray){
        self.waveRenderVals = waveRenderVals
        saveToFile();
    }
}
