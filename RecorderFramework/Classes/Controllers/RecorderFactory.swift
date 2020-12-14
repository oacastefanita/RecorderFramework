//
//  RecorderFactory.swift
//  Pods
//
//  Created by Stefanita Oaca on 01/11/2017.
//

public class RecorderFactory: NSObject {
    
    public class func createUserFromDict(_ dict: NSDictionary) -> User{
        let object = User()
        
        if let value:String = dict.object(forKey: "f_name") as? String {
            object.firstName = value.decodedString()
        }
        if let value:String = dict.object(forKey: "l_name") as? String {
            object.lastName = value.decodedString()
        }
        if let value:String = dict.object(forKey: "email") as? String {
            object.email = value
        }
        if let value:String = dict.object(forKey: "max_length") as? String {
            object.maxLenght = value
        }
        if let value:String = dict.object(forKey: "pic") as? String {
            object.imagePath = value
        }
        if let stringValue:String = dict.object(forKey: "play_beep") as? String {
            object.playBeep = (stringValue == "yes" || stringValue == "true" || stringValue == "1")
            
        }
        if let stringValue:String = dict.object(forKey: "is_public") as? String {
            object.isPublic  = (stringValue == "yes" || stringValue == "true" || stringValue == "1") 
        }
        if let value:Int = dict.object(forKey: "plan") as? Int {
            object.plan = value
        }
        if let value:Int = dict.object(forKey: "time") as? Int {
            object.time = value
        }
        if let value:String = dict.object(forKey: "pin_code") as? String {
            object.pin = value
        }
        return object
    }
    
    public class func createDictFromUser(_ user: User) -> NSMutableDictionary{
        let dictNew = NSMutableDictionary(dictionary: ["l_name":user.lastName ?? "", "f_name":user.firstName ?? "", "email":user.email ?? "", "max_length":user.maxLenght ?? ""])
        dictNew["time_zone"] = user.timeZone
        dictNew["is_public"] = user.isPublic ?? ""
        dictNew["play_beep"] = user.playBeep ?? ""
        dictNew["pic"] = user.imagePath ?? ""
        dictNew["pin_code"] = user.pin ?? ""
        let dict = NSMutableDictionary(dictionary: ["data":dictNew])
        return dict
    }

    public class func createRecordFolderFromDict(_ dict: NSDictionary) -> RecordFolder{
        let object = RecordFolder()
        
        if let value:String = dict.object(forKey: "name") as? String {
            object.title = value.decodedString()
        }
        if let value:String = dict.object(forKey: "id") as? String {
            object.id  = value
        }
        if let value:String = dict.object(forKey: "created") as? String {
            object.created  = value
        }
        if let value:String = dict.object(forKey: "pass") as? String {
            object.password  = value
        }
        if let value:String = dict.object(forKey: "pass_hint") as? String {
            object.passwordHint  = value
        }
        if let value:String = dict.object(forKey: "order_id") as? String {
            object.folderOrder  = Int(value)!
        }
        if let value:String = dict.object(forKey: "is_star") as? String {
            object.isStar = value == "1"
        }
        if let value = dict.object(forKey: "color") as? NSNumber, let color = FolderColor(rawValue: value.intValue) {
            object.color  = color
        }
        else if let strValue = dict.object(forKey: "color") as? String, let value = Int(strValue), let color = FolderColor(rawValue: value) {
            object.color  = color
        }
        object.recordedItems = [RecordItem]()
        if let values:Array<NSDictionary> = dict.object(forKey: "recordedItems") as? Array<NSDictionary> {
            for dict in values{
                object.recordedItems.append(RecorderFactory.createRecordItemFromDict(dict))
            }
        }
        return object
    }
    
    public class func createDictFromRecordFolder(_ folder: RecordFolder) -> NSMutableDictionary{
        let dict = NSMutableDictionary(dictionary: ["id":folder.id ?? "", "name":folder.title.encodedString() ?? "", "created":folder.created ?? ""])
        dict["folder_order"] = folder.folderOrder ?? ""
        dict["pass"] = folder.password ?? ""
        dict["pass_hint"] = folder.passwordHint ?? ""
        dict["is_star"] = folder.isStar ? "1" : "0"
        dict["color"] = folder.color.rawValue
        var array = [NSDictionary]()
        for file in folder.recordedItems{
            array.append(RecorderFactory.createDictFromRecordItem(file))
        }
        dict.setValue(array, forKey: "recordedItems")
        return dict
    }
    
    public class func createRecordItemFromDict(_ dict: NSDictionary) -> RecordItem{
        let object = RecordItem()
        if let value:String = dict.object(forKey: "folderId") as? String {
            object.folderId = value
        }
        if let value:String = dict.object(forKey: "name") as? String {
            object.text = value.decodedString()
        }
        if let value:String = dict.object(forKey: "id") as? String {
            object.id = value
        }
        if let value:String = dict.object(forKey: "phone") as? String {
            object.phone = value
        }
        if let value:String = dict.object(forKey: "access_number") as? String {
            object.accessNumber = value
        }
        if let value:String = dict.object(forKey: "url") as? String {
            object.url = value
        }
        if let value:String = dict.object(forKey: "share_url") as? String {
            object.shareUrl = value
        }
        if let value:String = dict.object(forKey: "credits") as? String {
            object.credits = value
        }
        if let value:String = dict.object(forKey: "duration") as? String {
            object.duration = value
        }
        if let value:Int = dict.object(forKey: "time") as? Int {
            object.time = "\(value)"
            object.lastAccessedTime = "\(value)"
        }
        if let value:String = dict.object(forKey: "f_name") as? String {
            object.firstName = value.decodedString()
        }
        if let value:String = dict.object(forKey: "l_name") as? String {
            object.lastName = value.decodedString()
        }
        if let value:String = dict.object(forKey: "phone") as? String {
            object.phoneNumber = value
        }
        if let value:String = dict.object(forKey: "email") as? String {
            object.email = value
        }
        if let value:String = dict.object(forKey: "notes") as? String {
            object.notes = value.decodedString()
        }
        
        if let value:String = dict.object(forKey: "tags") as? String {
            object.tags = value.decodedString()
        }
        if let value:String = dict.object(forKey: "is_star") as? String {
            object.isStar = value == "1"
        }
        if let value:String = dict.object(forKey: "remind_days") as? String {
            object.remindDays = value
        }
        if let value:String = dict.object(forKey: "remind_date") as? String {
            var timeInterval = 0
//            if let timezone = Int(AppPersistentData.sharedInstance.user.timeZone){
//                timeInterval = timezone * -60
//            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let newDate = dateFormatter.date(from: value)?.addingTimeInterval(TimeInterval(timeInterval))
            if newDate != nil{
                object.remindDate = dateFormatter.string(from: newDate!)
            }else{
                object.remindDate = ""
            }
        }
        if let value:String = dict.object(forKey: "is_star") as? String {
            object.isStar = value == "1"
        }
        if let value:String = dict.object(forKey: "free") as? String {
            object.isFree = value == "1"
        }
        if let value:Int = dict.object(forKey: "updated") as? Int {
            object.updated = "\(value)"
        }
        if let value:String = dict.object(forKey: "text") as? String {
            object.text = value.decodedString()
        }
        if let value:String = dict.object(forKey: "order_id") as? String {
            object.fileOrder  = Int(value)!
        }
        return object
    }
    
    public class func createDictFromRecordItem(_ file: RecordItem) -> NSMutableDictionary{
        let dict = NSMutableDictionary(dictionary: ["folderId":file.folderId, "name":file.text.encodedString(), "id":file.id, "access_number":file.accessNumber, "url":file.url, "share_url":file.shareUrl, "credits":file.credits, "duration":file.duration, "time":file.time,"f_name":file.firstName.encodedString(), "l_name":file.lastName.encodedString(), "email":file.email, "notes":file.notes.encodedString(), "phone":file.phoneNumber, "tags":file.tags.encodedString(), "remind_date":file.remindDate, "remind_days":file.remindDays, "free":file.isFree ? "1":"0","text":file.text.encodedString(), "order_id":file.fileOrder, "is_star":file.isStar ? "1" : "0"])
        return dict
    }
    
    public class func createAudioTagFromDict(_ dict: NSDictionary) -> AudioTag{
        let newTag = AudioTag()
        newTag.timeStamp = dict.object(forKey: "timeStamp") as! TimeInterval
        newTag.duration = dict.object(forKey: "duration") as! TimeInterval
        newTag.arg = dict.object(forKey:"arg") as AnyObject
        newTag.arg2 = dict.object(forKey:"arg2") as AnyObject
        if let value = dict.object(forKey: "type") as? String
        {
            newTag.type = TagType(rawValue: value)!
        }
        return newTag
    }
    
    public class func createDictFromAudioTag(_ tag: AudioTag) -> NSMutableDictionary{
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
        
        return newDict
    }
    
    public class func createPhoneNumberFromDict(_ number: NSDictionary) -> PhoneNumber{
        let phoneNumber = PhoneNumber()
        if let value:String = number.object(forKey: "phone_number") as? String {
            phoneNumber.phoneNumber = value
        }
        if let value:String = number.object(forKey: "number") as? String {
            phoneNumber.number = value
        }
        if let value:String = number.object(forKey: "prefix") as? String {
            phoneNumber.prefix = value
        }
        if let value:String = number.object(forKey: "friendly_name") as? String {
            phoneNumber.friendlyNumber = value
        }
        if let value:String = number.object(forKey: "flag") as? String {
            phoneNumber.flag = value
        }
        if let value:String = number.object(forKey: "country") as? String {
            phoneNumber.country = value
        }
        if let value:String = number.object(forKey: "city") as? String {
            phoneNumber.city = value
        }
        return phoneNumber
    }
    
    public class func createLanguageFromDict(_ language: NSDictionary) -> Language{
        let item:Language = Language()
        
        if let value:String = language.object(forKey: "name") as? String {
            item.name = value
        }
        if let value:String = language.object(forKey: "code") as? String {
            item.code = value
        }
        return item
    }
    
    public class func createMessageFromDict(_ msg: NSDictionary) -> ServerMessage{
        let item:ServerMessage = ServerMessage()
        
        if let value:String = msg.object(forKey: "id") as? String {
            item.id = value
        }
        if let value:String = msg.object(forKey: "title") as? String {
            item.title = value.decodedString()
        }
        if let value:String = msg.object(forKey: "body") as? String {
            item.body = value.decodedString()
        }
        if let value:String = msg.object(forKey: "time") as? String {
            item.time = value
        }
        
        var found = false
        for msg in AppPersistentData.sharedInstance.serverMessages{
            if msg.id == item.id{
                found = true
                break
            }
        }
        let defaults = UserDefaults.standard
        let lastTime = defaults.object(forKey: "messageTime")

        if !found{
            item.read = false
            if lastTime == nil{
                item.read = true
            }
            AppPersistentData.sharedInstance.serverMessages.append(item)
        }
        return item
    }
    
    public class func fillAppPersistentDataFromDict(_ dict: NSDictionary){
        if let profile:NSDictionary = dict["profile"] as? NSDictionary {
            AppPersistentData.sharedInstance.user = RecorderFactory.createUserFromDict(profile)
            AppPersistentData.sharedInstance.user.timeZone = "\(TimeZone.current.secondsFromGMT() / 60)"
            #if os(iOS)
            WatchKitController.sharedInstance.sendUser()
            #endif
        }
        if let value:String = dict.object(forKey: "play_beep") as? String {
            AppPersistentData.sharedInstance.user.playBeep = value == "no" ? false:true
        }
        if let value:String = dict.object(forKey: "files_permission") as? String {
            AppPersistentData.sharedInstance.filePermission = value
        }
        if let value:Int = dict["credits"] as? Int {
            AppPersistentData.sharedInstance.credits = value
        }
        if let value:String = dict["app"] as? String {
            AppPersistentData.sharedInstance.app = value
        }
        if let url:String = dict["share_url"] as? String {
            AppPersistentData.sharedInstance.shareUrl = url
        }
        if let url:String = dict["rate_url"] as? String {
            AppPersistentData.sharedInstance.rateUrl = url
        }
        if let value = dict["phone"] as? String {
            AppPersistentData.sharedInstance.phone = value
        }
        if let value = dict["api_key"] as? String {
            AppPersistentData.sharedInstance.apiKey = value
        }
        if let value = dict["code"] as? String {
            AppPersistentData.sharedInstance.verificationCode = value
        }
        AppPersistentData.sharedInstance.saveData()
    }
}
