//
//  RecorderFactory.swift
//  Pods
//
//  Created by Stefanita Oaca on 01/11/2017.
//

class RecorderFactory: NSObject {
    
    class func createUserFromDict(_ dict: NSDictionary) -> User{
        let object = User()
        
        if let value:String = dict.object(forKey: "f_name") as? String {
            object.firstName = value
        }
        if let value:String = dict.object(forKey: "l_name") as? String {
            object.lastName = value
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
            if let value:Bool = (stringValue == "yes" || stringValue == "true" || stringValue == "1"){
                object.playBeep = value
            }
        }
        if let stringValue:String = dict.object(forKey: "is_public") as? String {
            if let value:Bool = (stringValue == "yes" || stringValue == "true" || stringValue == "1") {
                object.isPublic = value
            }
        }
        if let value:String = dict.object(forKey: "time_zone") as? String {
            object.timeZone = value
        }
        
        return object
    }
    
    class func createDictFromUser(_ user: User) -> NSDictionary{
        let dict = NSMutableDictionary(dictionary: ["l_name":user.lastName ?? "", "f_name":user.firstName ?? "", "email":user.email ?? "", "max_length":user.maxLenght ?? "", "pic":user.imagePath ?? "", "play_beep":user.playBeep ?? "", "is_public":user.isPublic ?? "", "time_zone": user.timeZone])
        return dict
    }

    class func createRecordFolderFromDict(_ dict: NSDictionary) -> RecordFolder{
        let object = RecordFolder()
        
        if let value:String = dict.object(forKey: "name") as? String {
            object.title = value
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
        if let value:String = dict.object(forKey: "folder_order") as? String {
            object.folderOrder  = Int(value)!
        }
        object.recordedItems = [RecordItem]()
        if let values:Array<NSDictionary> = dict.object(forKey: "recordedItems") as? Array<NSDictionary> {
            for dict in values{
                object.recordedItems.append(RecorderFactory.createRecordItemFromDict(dict))
            }
        }
        
        return object
    }
    
    class func createDictFromRecordFolder(_ folder: RecordFolder) -> NSDictionary{
        let dict = NSMutableDictionary(dictionary: ["id":folder.id ?? "", "name":folder.title ?? "", "created":folder.created ?? "", "pass":folder.password ?? "", "folder_order":folder.folderOrder ?? ""])
        var array = [NSDictionary]()
        for file in folder.recordedItems{
            array.append(RecorderFactory.createDictFromRecordItem(file))
        }
        dict.setValue(array, forKey: "recordedItems")
        return dict
    }
    
    class func createRecordItemFromDict(_ dict: NSDictionary) -> RecordItem{
        let object = RecordItem()
        if let value:String = dict.object(forKey: "folderId") as? String {
            object.folderId = value
        }
        if let value:String = dict.object(forKey: "name") as? String {
            object.text = value
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
        if let value:String = dict.object(forKey: "time") as? String {
            object.time = value
            object.lastAccessedTime = value
        }
        if let value:String = dict.object(forKey: "f_name") as? String {
            object.firstName = value
        }
        if let value:String = dict.object(forKey: "l_name") as? String {
            object.lastName = value
        }
        if let value:String = dict.object(forKey: "phone") as? String {
            object.phoneNumber = value
        }
        if let value:String = dict.object(forKey: "email") as? String {
            object.email = value
        }
        if let value:String = dict.object(forKey: "notes") as? String {
            object.notes = value
        }
        
        if let value:String = dict.object(forKey: "tags") as? String {
            object.tags = value
        }
        if let value:String = dict.object(forKey: "is_star") as? String {
            object.isStar = value == "1"
        }
        if let value:String = dict.object(forKey: "remind_days") as? String {
            object.remindDate = value
        }
        if let value:String = dict.object(forKey: "remind_date") as? String {
            object.remindDays = value
        }
        return object
    }
    
    class func createDictFromRecordItem(_ file: RecordItem) -> NSDictionary{
        let dict = NSDictionary(dictionary: ["folderId":file.folderId, "name":file.text, "id":file.id, "phone":file.phone, "access_number":file.accessNumber, "url":file.url, "share_url":file.shareUrl, "credits":file.credits, "duration":file.duration, "time":file.time,"f_name":file.firstName, "l_name":file.lastName, "email":file.email, "notes":file.notes, "phone":file.phoneNumber, "tags":file.tags, "remind_date":file.remindDate, "remind_days":file.remindDays])
        return dict
    }
}
