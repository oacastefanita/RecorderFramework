//
//  APIClient.swift
//  PPC
//
//  Created by Grif on 24/04/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation
import CoreTelephony

#if os(iOS)
    
#else
import Cocoa
#endif

class APIClient : NSObject {
    
    var manager = AFHTTPRequestOperationManager(baseURL: URL(string: "https://app2.virtualbrix.net/rapi"))//"https://virtualbrix.net/rapi"))
    var mainSyncInProgress:Bool = false
    var mainSyncErrors:Int = 0
    var currentViewController = UIViewController()
    
    public static let sharedInstance = APIClient()
    
    override init() {
        super.init()
        self.initalizeManager()
    }
    
    func initalizeManager()
    {
        AFHTTPRequestOperationLogger.shared().startLogging()
        AFHTTPRequestOperationLogger.shared().level = AFHTTPRequestLoggerLevel.AFLoggerLevelDebug
        manager?.requestSerializer = AFHTTPRequestSerializer()
        manager?.responseSerializer = AFJSONResponseSerializer()
        manager?.responseSerializer.acceptableContentTypes = NSSet(array:["text/html"]) as Set<NSObject>
        
        let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.none)
        securityPolicy?.allowInvalidCertificates = false
        manager?.securityPolicy = securityPolicy;
    }
    
    func register(_ number:NSString, completionHandler:((Bool, AnyObject?) -> Void)?)
    {
        var parameters = ["phone": number, "token": "55942ee3894f51000530894"]
        manager?.post("register_phone", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if let value:String = jsonDict.object(forKey: "phone") as? String  {
                        AppPersistentData.sharedInstance.phone = value
                    }
                    if let value:String = jsonDict.object(forKey: "api_key") as? String  {
                        AppPersistentData.sharedInstance.apiKey = value
                    }
                    if let value:String = jsonDict.object(forKey: "code") as? String  {
                        AppPersistentData.sharedInstance.verificationCode = value
                    }
                    AppPersistentData.sharedInstance.saveData()
                    
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
            if completionHandler != nil {
                completionHandler!(false, "Error parsing server result." as AnyObject)
            }
        }
        }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
            if completionHandler != nil {
                completionHandler!(false, operation.responseString as AnyObject)
            }
        }
    }
    
    func sendVerificationCode(_ code:NSString, completionHandler:((Bool, AnyObject?) -> Void)?)
    {
        let tn = CTTelephonyNetworkInfo();
        let carrier = tn.subscriberCellularProvider
        
#if CRFREE
        var appCode = "free"
#else
        var appCode = "pro"
#endif

        let mcc:String! = (carrier != nil && !carrier!.mobileCountryCode!.isEmpty) ? carrier!.mobileCountryCode : "310"
        let deviceToken =  AppPersistentData.sharedInstance.notificationToken == nil ? "Simulator" : AppPersistentData.sharedInstance.notificationToken
        let parameters = ["phone": AppPersistentData.sharedInstance.phone, "code": code, "mcc": mcc, "token": "55942ee3894f51000530894", "app": appCode, "device_token":deviceToken] as [String : Any]
//        var parameters = [("phone", AppPersistentData.sharedInstance.phone), ("code": code), ("mcc": (carrier != nil && !carrier!.mobileCountryCode!.isEmpty) ? carrier!.mobileCountryCode : "310"), ("token": "55942ee3894f51000530894"), ("app": appCode), ("device_token": AppPersistentData.sharedInstance.notificationToken == nil ? "Simulator" : AppPersistentData.sharedInstance.notificationToken)] //"226" "310" carrier.mobileCountryCode
        manager?.post("verify_phone", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if let value:String = jsonDict.object(forKey: "api_key") as? String  {
                        AppPersistentData.sharedInstance.apiKey = value
                        AppPersistentData.sharedInstance.invalidAPIKey = false
                        AppPersistentData.sharedInstance.saveData()
                        
                        if completionHandler != nil {
                            completionHandler!( true, nil)
                        }
                    } else{
                        if completionHandler != nil {
                            if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                                completionHandler!(false, strError.localized as AnyObject)
                            }
                            else {
                                completionHandler!(false, nil)
                            }
                        }
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            
        }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
            if completionHandler != nil {
                completionHandler!(false, operation.responseString as AnyObject)
            }
        }
    }
    
    func getRecordings(_ folderId:String!, completionHandler:((Bool, AnyObject?) -> Void)?)
    {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey]
        if folderId != nil {
            parameters.updateValue(folderId, forKey: "folder_id")
        }
        
//        if SwiftPreprocessor.sharedInstance().SWIFT_ISRECORDER{
//            parameters["source"] = "app2"
//        }
        
        manager?.post("get_files", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
            var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
            if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                if completionHandler != nil {
                    if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                        if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                            AppPersistentData.sharedInstance.invalidAPIKey = true
                        }

                        completionHandler!(false, strError.localized as AnyObject)
                    }
                    else {
                        completionHandler!(false, nil)
                    }
                }
            }
            else {
                if var calls:Array<NSDictionary> = jsonDict.object(forKey: "files") as? Array<NSDictionary> {
                
                    var allIds:Array<String> = Array<String>()
                    var recordFolder = RecordingsManager.sharedInstance.recordFolders[0]
                    for recFolder in RecordingsManager.sharedInstance.recordFolders {
                        if recFolder.id == folderId {
                            recordFolder = recFolder
                            break
                        }
                    }
                    for item in recordFolder.recordedItems {
                        var action:Action! = item.recordingNextAction(nil)
                        if action != nil {
                            allIds.append(item.id)
                        }
                    }
                    
                    for call in calls {
                        var item:RecordItem = RecordItem()
                        if folderId == "trash"{
                            item.fromTrash = true
                        }

                        if var value:String = call.object(forKey: "name") as? String {
                            item.text = value
                        }
                        if var value:String = call.object(forKey: "id") as? String {
                            item.id = value
                        }
                        if var value:String = call.object(forKey: "phone") as? String {
                            item.phone = value
                        }
                        if var value:String = call.object(forKey: "access_number") as? String {
                            item.accessNumber = value
                        }
                        if var value:String = call.object(forKey: "url") as? String {
                            item.url = value
                        }
                        if var value:String = call.object(forKey: "share_url") as? String {
                            item.shareUrl = value
                        }
                        if var value:String = call.object(forKey: "credits") as? String {
                            item.credits = value
                        }
                        if var value:String = call.object(forKey: "duration") as? String {
                            item.duration = value
                        }
                        if var value:String = call.object(forKey: "time") as? String {
                            item.time = value
                            item.lastAccessedTime = value
                        }
                        if var value:String = call.object(forKey: "f_name") as? String {
                            item.firstName = value
                        }
                        if var value:String = call.object(forKey: "l_name") as? String {
                            item.lastName = value
                        }
                        if var value:String = call.object(forKey: "phone") as? String {
                            item.phoneNumber = value
                        }
                        if var value:String = call.object(forKey: "email") as? String {
                            item.email = value
                        }
                        if var value:String = call.object(forKey: "notes") as? String {
                            item.notes = value
                        }
                        
                        allIds.append(item.id)
                        
                        var synchedItem = RecordingsManager.sharedInstance.syncRecordingItem(item, folder:recordFolder)
                        
                        var on = UserDefaults.standard.object(forKey: "3GSync") as? Bool
                        if(on == nil){
                            on = true
                        }
//                        
//                        if AFNetworkReachabilityManager.sharedManager().reachableViaWiFi || on! {
//                            if synchedItem.url != nil && !synchedItem.url.isEmpty && !synchedItem.fileDownloaded {
//                                APIClient.sharedInstance.downloadAudioFile(synchedItem, toFolder:recordFolder.title, completionHandler:{ (Bool success) -> Void in
//                                    AppPersistentData.sharedInstance.saveData()
//                                });
//                            }
//                        }
                    }
                    
                    recordFolder.keepOnlyItemsWithIds(allIds);
                    
                    AppPersistentData.sharedInstance.saveData()
                }
                
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
        }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
            if completionHandler != nil {
                completionHandler!(false, operation.debugDescription as AnyObject)
            }
        }
    }
    
    func getPhoneNumbers(_ completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey]
        var defaultPhone = " "
        for phoneNumber in AppPersistentData.sharedInstance.phoneNumbers{
            if phoneNumber.isDefault{
                defaultPhone = phoneNumber.phoneNumber
                break
            }
        }
        AppPersistentData.sharedInstance.phoneNumbers.removeAll(keepingCapacity: false)
        manager?.post("get_phones", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
            if let jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options: JSONSerialization.ReadingOptions.mutableLeaves) as? NSDictionary {
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }

                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
            }
            else {
                if var numbers:Array<NSDictionary> = try JSONSerialization.jsonObject(with: operation.responseData, options: JSONSerialization.ReadingOptions.mutableLeaves) as? Array<NSDictionary> {
                    
                    for number in numbers {
                        var phoneNumber = PhoneNumber()
                        if var value:String = number.object(forKey: "phone_number") as? String {
                            phoneNumber.phoneNumber = value
                        }
                        if var value:String = number.object(forKey: "number") as? String {
                            phoneNumber.number = value
                        }
                        if var value:String = number.object(forKey: "prefix") as? String {
                            phoneNumber.prefix = value
                        }
                        if var value:String = number.object(forKey: "friendly_name") as? String {
                            phoneNumber.friendlyNumber = value
                        }
                        if var value:String = number.object(forKey: "flag") as? String {
                            phoneNumber.flag = value
                        }
                        if var value:String = number.object(forKey: "country") as? String {
                            phoneNumber.country = value
                        }
                        
                        AppPersistentData.sharedInstance.phoneNumbers.append(phoneNumber)
                    }
                }
                if AppPersistentData.sharedInstance.phoneNumbers.count > 0{
                    var found = false
                    for phoneNumber in AppPersistentData.sharedInstance.phoneNumbers{
                        if phoneNumber.phoneNumber == defaultPhone{
                            phoneNumber.isDefault = true
                            found = true
                            break
                        }
                    }
                    
                    if !found{
                        AppPersistentData.sharedInstance.phoneNumbers.first!.isDefault = true
                    }
                }
                var downloadsCompleted = 0
                for phoneNumber in  AppPersistentData.sharedInstance.phoneNumbers {
                    var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    path = path.appendingFormat("/" + "flags" + "/");
                    if !FileManager.default.fileExists(atPath: path) {
                        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                    }
                    path = path.appendingFormat(phoneNumber.flag.components(separatedBy: "/").last!)
                    if !FileManager.default.fileExists(atPath: path) {
                        APIClient.sharedInstance.downloadFile(phoneNumber.flag! as NSString, localPath:path as NSString, completionHandler: { (success) -> Void in
                            downloadsCompleted += 1
                            if(downloadsCompleted == AppPersistentData.sharedInstance.phoneNumbers.count){
                                if completionHandler != nil {
                                    completionHandler!( true, nil)
                                }
                            }
                        })
                    }
                    else{
                        downloadsCompleted += 1
                        if(downloadsCompleted == AppPersistentData.sharedInstance.phoneNumbers.count){
                            if completionHandler != nil {
                                completionHandler!( true, nil)
                            }
                        }
                    }
                }
            }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
                if completionHandler != nil {
                    completionHandler!(false, operation.responseString as AnyObject)
                }
        }
    }

    func getFolders(_ completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        if AppPersistentData.sharedInstance.apiKey == nil {
            if completionHandler != nil {
                completionHandler!(false, nil)
            }
            
            return
        }
        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey]
        manager?.post("get_folders", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            var error: NSError?
            var foundDefault = false
            var foundAllFiles = false
            var foundTrash = false
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
                if recordFolder.id == "trash" {
                    foundTrash = true
                    if foundAllFiles && foundDefault && foundTrash{
                        break
                    }
                }
            }
            
            if !foundDefault {
                var defaultFolder = RecordFolder()
                defaultFolder.id = "0"
                defaultFolder.title = "New Call Recordings".localized
                RecordingsManager.sharedInstance.recordFolders.insert(defaultFolder, at: 0)
            }
            if !foundAllFiles {
                var defaultFolder = RecordFolder()
                defaultFolder.id = "-99"
                defaultFolder.title = "All Files".localized
                RecordingsManager.sharedInstance.recordFolders.insert(defaultFolder, at: 1)
            }
            if !foundTrash {
                var defaultFolder = RecordFolder()
                defaultFolder.id = "trash"
                defaultFolder.title = "Trash".localized
                RecordingsManager.sharedInstance.recordFolders.insert(defaultFolder, at: 2)
            }
            
            do {
             var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options: JSONSerialization.ReadingOptions.mutableLeaves)
                if ((jsonDict as AnyObject).count == 0 || ((jsonDict as AnyObject).count > 0 && (jsonDict as AnyObject).object(forKey: "status") != nil && !((jsonDict as AnyObject).object(forKey:"status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = (jsonDict as AnyObject).object(forKey:"msg") as? String  {
                            if (jsonDict as AnyObject).object(forKey:"msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }

                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    
                    if var folders:Array<NSDictionary> = (jsonDict as! AnyObject).object(forKey:"folders") as? Array<NSDictionary> {
                        var ids:Array<String> = Array<String>()
                        ids.append("0")
                        ids.append("-99")
                        ids.append("trash")
                        for folder in folders {
                            var recordFolder = RecordFolder()
                            
                            if var value:String = folder.object(forKey: "name") as? String {
                                recordFolder.title = value
                            }
                            if var value:String = folder.object(forKey: "id") as? String {
                                recordFolder.id  = value
                            }
                            if var value:String = folder.object(forKey: "created") as? String {
                                recordFolder.created  = value
                            }
                            
                            if var value:String = folder.object(forKey: "folder_order") as? String {
                                recordFolder.folderOrder  = Int(value)!
                            }
                            ids.append(recordFolder.id)
                            
                            RecordingsManager.sharedInstance.syncItem(recordFolder)
                        }
                        RecordingsManager.sharedInstance.keepOnlyItemsWithIds(ids);
                        RecordingsManager.sharedInstance.updateTrashFolder()
                        RecordingsManager.sharedInstance.sortByFolderOrder()
                    }
                    
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
                if completionHandler != nil {
                    completionHandler!(false, operation.responseString as AnyObject)
                }
        }
    }
    
    func createFolder(_ name:NSString, localID:NSString, completionHandler:((Bool, AnyObject?) -> Void)?)
    {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey, "name" : name] as [String : Any]
        
        manager?.post("create_folder", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }

                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    
                    var recordFolder = RecordingsManager.sharedInstance.getFolderWithId(localID as String)
                    if recordFolder == nil {
                        recordFolder = RecordFolder()
                    }
                    
                    if let value:String = jsonDict.object(forKey: "name") as? String {
                        recordFolder?.title = value
                    }
                    else {
                        recordFolder?.title = name as String
                    }
                    if let value:NSNumber = jsonDict.object(forKey: "id") as? NSNumber {
                        recordFolder?.id = value.stringValue
                        for action in ActionsSyncManager.sharedInstance.actions {
                            if action.arg1 == localID as String {
                                action.arg1 = recordFolder?.id
                            }
                            if action.arg2 == localID as String {
                                action.arg2 = recordFolder?.id
                            }
                        }
                    }
                    RecordingsManager.sharedInstance.syncItem(recordFolder!)
                    
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
                if completionHandler != nil {
                    completionHandler!(false, operation.responseString as AnyObject)
                }
        }
    }
    
    func deleteFolder(_ folderId:String, moveTo:String!, completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey, "id" : folderId] as NSMutableDictionary
        if moveTo != nil && moveTo != ""{
            parameters.setValue(moveTo, forKey: "move_to")
        }
        
        manager?.post("delete_folder", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }

                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                        APIClient.sharedInstance.updateFolders({ (success) -> Void in
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
                        })
                    }
                }
            }
            catch {
            if completionHandler != nil {
            completionHandler!(false, "Error parsing server result." as AnyObject)
            }
        }
            
            }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
                if completionHandler != nil {
                    completionHandler!(false, operation.responseString as AnyObject)
                }
        }
    }
    
    func reorderFolders(_ parameters:NSMutableDictionary, completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        parameters["api_key"] = AppPersistentData.sharedInstance.apiKey
        
        manager?.post("update_folders_order", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                        APIClient.sharedInstance.updateFolders({ (success) -> Void in
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
                        })
                    }
                }
                
            }
            catch {
            if completionHandler != nil {
            completionHandler!(false, "Error parsing server result." as AnyObject)
            }
        }
            
            }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
                if completionHandler != nil {
                    completionHandler!(false, operation.responseString as AnyObject)
                }
        }
    }
    
    
    func renameFolder(_ folderId:String, name:String, completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey, "id" : folderId, "name" : name]
        
        manager?.post("update_folder", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }

                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            
            }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
                if completionHandler != nil {
                    completionHandler!(false, operation.responseString as AnyObject)
                }
        }
    }

    func deleteRecording(_ recordItemId:String, removeForever:Bool, completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey, "ids" : recordItemId, "action" : removeForever ? "remove_forever" : ""]
        
        manager?.post("delete_files", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }
                            
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            
        }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
            if completionHandler != nil {
                completionHandler!(false, operation.responseString as AnyObject)
            }
        }
    }
    
    func moveRecording(_ recordItem:RecordItem, folderId:String, completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey, "id" : recordItem.id, "folder_id" : folderId]
        
        manager?.post("update_file", parameters: parameters, success:  { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }
                            
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            
        }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
            if completionHandler != nil {
                completionHandler!(false, operation.responseString as AnyObject)
            }
        }
    }
    
    func recoverRecording(_ recordItem:RecordItem, folderId:String, completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey, "id" : recordItem.id, "folder_id" : folderId]
        
        manager?.post("recover_file", parameters: parameters, success:  { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }
                            
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            
        }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
            if completionHandler != nil {
                completionHandler!(false, operation.responseString as AnyObject)
            }
        }
    }
    
    func updateRecordingInfo(_ recordItem:RecordItem ,parameters:NSMutableDictionary, completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        parameters.setObject(AppPersistentData.sharedInstance.apiKey, forKey: "api_key" as NSCopying)
        
        manager?.post("update_file", parameters: parameters, success:  { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }
                            
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            
        }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
            if completionHandler != nil {
                completionHandler!(false, operation.responseString as AnyObject)
            }
        }
    }

    func renameRecording(_ recordItem:RecordItem, name:String, completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey, "id" : recordItem.id, "name":name]

        manager?.post("update_file", parameters: parameters, success:  { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }
                            
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            
        }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
            if completionHandler != nil {
                completionHandler!(false, operation.responseString as AnyObject)
            }
        }
    }
    
    func uploadRecording(_ recordItem:RecordItem, completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        do {
            var jsonData = try JSONSerialization.data(withJSONObject: ["name":"audio_upload_test","notes":""], options: JSONSerialization.WritingOptions.prettyPrinted)
            var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey, "data": "{\"name\":\"\(recordItem.text)\",\"notes\":\"\(recordItem.notes)\"} "]
            
            
    //        if SwiftPreprocessor.sharedInstance().SWIFT_ISRECORDER{
    //            parameters["source"] = "app2"
    //        }

            var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
            path += recordItem.localFile
            
            if URL(fileURLWithPath:path).pathExtension == "caf" {
                var wavPath = path.replacingOccurrences(of: ".caf", with: ".wav", options: NSString.CompareOptions.literal, range: nil)
//                AudioConverter.exportAsset(asWaveFormat: path, destination:wavPath)
                path = wavPath
            }
            
            if !FileManager.default.fileExists(atPath: path ){
                completionHandler!(false, nil)
                return
            }
            
            manager?.post("create_file", parameters: parameters, constructingBodyWith: { (data) -> Void in
                do {
                 try data?.appendPart(withFileURL: NSURL(fileURLWithPath: path) as URL!, name: "file")
                }
                catch {
                    
                }

            },
            success: { (operation, data) -> Void in
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: (operation?.responseData)!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                    if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                        if completionHandler != nil {
                            if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                                if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                    AppPersistentData.sharedInstance.invalidAPIKey = true
                                }

                                completionHandler!(false, strError.localized as AnyObject)
                            }
                            else {
                                completionHandler!(false, nil)
                            }
                        }
                    }
                    else {
                        if let value:NSNumber = jsonDict.object(forKey: "id") as? NSNumber  {
                            recordItem.id = String(format:"%.0f", value.doubleValue)
                        }
                        
                        if completionHandler != nil {
                            completionHandler!( true, nil)
                        }
                    }
                }
                catch {
                    if completionHandler != nil {
                        completionHandler!(false, "Error parsing server result." as AnyObject)
                    }
                }
            }) { (operation, error) -> Void in
                if completionHandler != nil {
                    completionHandler!(false, operation?.responseString as AnyObject)
                }
            }
        }
        catch {
            if completionHandler != nil {
                completionHandler!(false, "Error parsing server result." as AnyObject)
            }
        }
    }
    
    func downloadFile(_ fileUrl:NSString, localPath:NSString, completionHandler:((Bool) -> Void)?)
    {
        if (AppPersistentData.sharedInstance.invalidAPIKey || fileUrl == ""){
            completionHandler!(false)
            return
        }

        var url = fileUrl as String
        url += "?api_key=" + AppPersistentData.sharedInstance.apiKey
        let request = URLRequest(url: URL(string: url as String)!)
        let operation = AFHTTPRequestOperation(request: request)
        
        operation?.outputStream = OutputStream(toFileAtPath: localPath as String, append: false)
        
        operation?.setCompletionBlockWithSuccess({ (op, data) -> Void in
            completionHandler!(true)
        }, failure: { (op, error) -> Void in
            completionHandler!(false)
        })
        
        operation?.start()
        
//        NSURL *url = [NSURL URLWithString:@"http://www.hulkshare.com/dl/qw30o7x373a8/stan_courtois_&_felly_vs_cutting_crew_-_die_in_your_arms_(x-centrik_mix)_%5B_www.themusix.net_%5D.mp3"];
//        NSURLRequest *request = [NSURLRequest requestWithURL:url];
//        
//        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//        
//        NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[url lastPathComponent]];
//        
//        [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fullPath append:NO]];
//        
//        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//        NSLog(@"bytesRead: %u, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", bytesRead, totalBytesRead, totalBytesExpectedToRead);
//        }];
//        
//        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
//        
//        NSError *error;
//        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
//        
//        if (error) {
//        NSLog(@"ERR: %@", [error description]);
//        } else {
//        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
//        long long fileSize = [fileSizeNumber longLongValue];
//        
//        [[_downloadFile titleLabel] setText:[NSString stringWithFormat:@"%lld", fileSize]];
//        }
//        
//        
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"ERR: %@", [error description]);
//        }];
//        
//        [operation start];
        
        
//        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey]
//        var op = manager.GET(fileUrl as String, parameters: nil, success: { (AFHTTPRequestOperation operation, AnyObject data) -> Void in
//            completionHandler!(true)
//            }) { (AFHTTPRequestOperation operation, NSError error) -> Void in
//                completionHandler!(false)
//        }
//        
//        op.outputStream = NSOutputStream(toFileAtPath: localPath as String, append: false)
//        op.outputStream.open()
    }
    
    func downloadAudioFile(_ recordItem:RecordItem, toFolder:String, completionHandler:((Bool) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false)
            return
        }

        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
        path = path + ("/" + toFolder + "/");
        if !FileManager.default.fileExists(atPath: path) {
            do {
             try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                
            }
        }
        path = path + recordItem.url.components(separatedBy: "/").last!
        
        var isWav = false
        var isMP3 = false
        if var wavRange = path.range(of: ".wav") {
            isWav = true
        }
        
        if var wavRange = path.range(of: ".mp3") {
            isMP3 = true
        }
        if !isWav && !isMP3 {
            path = path + ".wav"
        }
        
        // improve: remove local file if already exist and download it again (it may be a broken file)

        if !FileManager.default.fileExists(atPath: path) {
            APIClient.sharedInstance.downloadFile(recordItem.url as! NSString, localPath:path as NSString, completionHandler: { (success) -> Void in
                recordItem.fileDownloaded = success
                if success {
                    recordItem.localFile = "/" + toFolder + "/" + recordItem.url.components(separatedBy: "/").last!
                    var isWav = false
                    var isMP3 = false
                    if var wavRange = recordItem.localFile.range(of: ".wav") {
                        isWav = true
                    }
                    
                    if var wavRange = recordItem.localFile.range(of: ".mp3") {
                        isMP3 = true
                    }
                    if !isWav && !isMP3 {
                        recordItem.localFile = recordItem.localFile + ".wav"
                    }
                    NSLog(path)
                    self.getMetadataFiles(recordItem, completionHandler: { (success, files) -> Void in
                        if success && files != nil {
                            let allFiles = files as! Array<NSDictionary>
                            for file in allFiles{
                                let url = (file.object(forKey: "file") as? String)!
                                let name = (file.object(forKey: "name") as? String)!
                                var metaPath = AudioFileTagManager.sharedInstance.getMetadataFilePath(path)
                                if url.components(separatedBy: ".").last != "json" {
                                    var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
                                    path = path + ("/" + toFolder + "/")
                                    
                                    let end = "__" + name.components(separatedBy: "__").last!
                                    
                                    metaPath = metaPath.components(separatedBy: "_metadata").first!
                                    metaPath = metaPath + end
                                }
                                
                                APIClient.sharedInstance.downloadFile(url as NSString, localPath:metaPath as NSString, completionHandler: { (success) -> Void in
                                    if(success){
                                        AudioFileTagManager.sharedInstance.setupWithFile(path)
                                        recordItem.waveRenderVals = NSMutableArray(array: AudioFileTagManager.sharedInstance.waveRenderVals)
                                        AppPersistentData.sharedInstance.saveData()
                                    }
                                })
                            }
                        }
                    })
                    
                    if completionHandler != nil {
                        completionHandler!(true)
                    }
                }
            })
        }
        else {
            recordItem.fileDownloaded = true
            recordItem.localFile = "/" + toFolder + "/" + recordItem.url.components(separatedBy: "/").last!
            var isWav = false
            var isMP3 = false
            if var wavRange = recordItem.localFile.range(of: ".wav") {
                isWav = true
            }
            
            if var wavRange = recordItem.localFile.range(of: ".mp3") {
                isMP3 = true
            }
            if !isWav && !isMP3 {
                recordItem.localFile = recordItem.localFile + ".wav"
            }

            if completionHandler != nil {
                completionHandler!(true)
            }

        }
    }
    
    func mainSync(_ completionHandler:((Bool) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false)
            return
        }

        if mainSyncInProgress {
            if completionHandler != nil {
                completionHandler!(false)
            }
            return
        }
        if AppPersistentData.sharedInstance.apiKey == nil {
            mainSyncInProgress = false
            if completionHandler != nil {
                completionHandler!(false)
            }
            return
//            AppPersistentData.sharedInstance.apiKey = "557872b508520557872b50855c"
        }
        mainSyncInProgress = true
        mainSyncErrors = 0
        
        APIClient.sharedInstance.getSettings({ (success, data) -> Void in
            APIClient.sharedInstance.getMessages({ (success, data) -> Void in
                APIClient.sharedInstance.getLanguages { (success, data) -> Void in
                    APIClient.sharedInstance.getTranslations(TranslationManager.sharedInstance.currentLanguage, completionHandler:{ (success, data) -> Void in
                        APIClient.sharedInstance.getPhoneNumbers { (success, data) -> Void in
                            if !success {
                                self.mainSyncErrors += 1
                            }
                            APIClient.sharedInstance.getFolders({ (success, data) -> Void in
                                if !success {
                                    self.mainSyncErrors += 1
                                }
                                
                                self.getRecordings({ (success) -> Void in
                                    if completionHandler != nil {
                                        completionHandler!(true)
                                    }
                                    self.mainSyncInProgress = false
                                    //                    if self.mainSyncErrors > 0 {
                                    //                        AlertController.showAlert(self.currentViewController, title: "Warning".localized, message: "Errors occured during server sync process".localized, accept: "Ok".localized, reject: nil)
                                    //                    }
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
                                })
                            })
                        }
                    })
                }
            })
        })
    }
    
    
    func updateFolders(_ completionHandler:((Bool) -> Void)?) {
        APIClient.sharedInstance.getFolders { (success, data) -> Void in
            if !success {
                return
            }
            APIClient.sharedInstance.getRecordings({ (success) -> Void in
                if completionHandler != nil {
                    completionHandler!(true)
                }
            })
        }
    }

    func getRecordings(_ completionHandler:((Bool) -> Void)?) {
        if AppPersistentData.sharedInstance.apiKey == nil {
            if completionHandler != nil {
                completionHandler!(false)
                return
            }
        }
        var countToHandle = RecordingsManager.sharedInstance.recordFolders.count - 1

        for recordFolder in RecordingsManager.sharedInstance.recordFolders {
            if recordFolder.id == "-99"{
                continue
            }
            APIClient.sharedInstance.getRecordings(recordFolder.id, completionHandler:{ (success, data) -> Void in
                if !success {
                    self.mainSyncErrors += 1
                }
                countToHandle -= 1
                if countToHandle <= 0 {
                    RecordingsManager.sharedInstance.updateAllFilesFolder()
                    if completionHandler != nil {
                        completionHandler!(true)
                    }
                }
            })
        }
    }
    
    func updateSettings(_ playBeep:Bool, completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey, "play_beep" : playBeep ? "yes" : "no"]
        
        manager?.post("update_settings", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }
                            
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            
        }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
            if completionHandler != nil {
                if let resp = operation.responseString{
                    completionHandler!(false, resp as AnyObject)
                }else{
                    completionHandler!(false, "Something went horribly wrong" as AnyObject)
                }
            }
        }
    }
    
    func updateUser(_ free:Bool, completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey, "app" : free ? "free" : "pro"]
        
        manager?.post("update_user", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }
                            
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            
        }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
            if completionHandler != nil {
                completionHandler!(false, operation.responseString as AnyObject)
            }
        }
    }
    
    func getSettings(_ completionHandler:((Bool, AnyObject?) -> Void)?)
    {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey]

        manager?.post("get_settings", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                let jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }

                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if let settings:NSDictionary = jsonDict.object(forKey: "settings") as? NSDictionary {
                        
                        if var value:String = settings.object(forKey: "play_beep") as? String {
                            AppPersistentData.sharedInstance.playBeep = value == "no" ? false:true
                        }
                        if var value:String = settings.object(forKey: "files_permission") as? String {
                            AppPersistentData.sharedInstance.filePermission = value
                        }
                        if var value:Int = jsonDict.object(forKey: "credits") as? Int {
                            AppPersistentData.sharedInstance.credits = value
                        }
                        if var value:String = settings.object(forKey: "app") as? String {
                            AppPersistentData.sharedInstance.app = value
                        }
                        AppPersistentData.sharedInstance.saveData()
                    }
                    
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
                if completionHandler != nil {
                    completionHandler!(false, operation.responseString as AnyObject)
            }
        }
    }
    
    func buyCredits(_ credits:Int, receipt:String, completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey, "amount" : credits, "reciept" : receipt] as [String : Any]
        
        manager?.post("buy_credits", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }
                            
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            
        }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
            if completionHandler != nil {
                completionHandler!(false, operation.responseString as AnyObject)
            }
        }
    }
    
    func updateToken(_ token:String, completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey, "device_token" : token]
        
        manager?.post("update_device_token", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }
                            
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            
        }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
            if completionHandler != nil {
                completionHandler!(false, operation.responseString as AnyObject)
            }
        }
    }
    
    func notifyUser(_ token:String, completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey, "device" : token, "title" : "Title", "body" : "body"];
        
        manager?.post("notify_user", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }
                            
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            
        }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
            if completionHandler != nil {
                completionHandler!(false, operation.responseString as AnyObject)
            }
        }
    }
    
    func addMessage(_ token:String, completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey, "title" : "Title", "body" : "body"];
        
        manager?.post("add_msg", parameters: parameters, success:{ (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }
                            
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            
        }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
            if completionHandler != nil {
                completionHandler!(false, operation.responseString as AnyObject)
            }
        }
    }
    
    func getTranslations(_ language:String,completionHandler:((Bool, AnyObject?) -> Void)?)
    {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey, "language": language]
        
        manager?.post("get_translations", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }
                            
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            
        }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
            if completionHandler != nil {
                completionHandler!(false, operation.responseString as AnyObject)
            }
        }
    }
    
    func getLanguages(_ completionHandler:((Bool, AnyObject?) -> Void)?){
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey]
        
        manager?.post("get_languages", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            var error: NSError?
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }
                            
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if var calls:Array<NSDictionary> = jsonDict.object(forKey: "languages") as? Array<NSDictionary> {
                        TranslationManager.sharedInstance.languages = Array()
                        for call in calls {
                            var item:Language = Language()
                            
                            if var value:String = call.object(forKey: "name") as? String {
                                item.name = value
                            }
                            if var value:String = call.object(forKey: "code") as? String {
                                item.code = value
                            }
                            TranslationManager.sharedInstance.languages.append(item)
                        }
                        AppPersistentData.sharedInstance.saveData()
                    }
                    
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            
            }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
                if completionHandler != nil {
                    completionHandler!(false, operation.responseString as AnyObject)
            }
        }
    }
    
    func getMessages(_ completionHandler:((Bool, AnyObject?) -> Void)?)
    {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        var defaults = UserDefaults.standard
        var lastTime = defaults.object(forKey: "messageTime")
        if lastTime != nil{
            if ((lastTime as! NSNumber).intValue - (Date().timeIntervalSince1970 as NSNumber).intValue) < 24 * 60 * 60{
                completionHandler!( true, nil)
                return
            }
        }
        
        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey]
        
        manager?.post("get_msgs", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }
                            
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if var msgs:Array<NSDictionary> = jsonDict.object(forKey: "msgs") as? Array<NSDictionary> {
                        
                        defaults.set(NSNumber(value: NSDate().timeIntervalSince1970), forKey: "messageTime")

                        for msg in msgs {
                            var item:ServerMessage = ServerMessage()
                            
                            if var value:String = msg.object(forKey: "id") as? String {
                                item.id = value
                            }
                            if var value:String = msg.object(forKey: "title") as? String {
                                item.title = value
                            }
                            if var value:String = msg.object(forKey: "body") as? String {
                                item.body = value
                            }
                            if var value:String = msg.object(forKey: "time") as? String {
                                item.time = value
                            }
                            
                            var found = false
                            for msg in AppPersistentData.sharedInstance.serverMessages{
                                if msg.id == item.id{
                                    found = true
                                    break
                                }
                            }
                         
                            if !found{
                                item.read = false
                                if lastTime == nil{
                                    item.read = true
                                }
                                AppPersistentData.sharedInstance.serverMessages.append(item)
                            }
                            
                        }
                        AppPersistentData.sharedInstance.serverMessages.sort { $0.time < $1.time }
                        AppPersistentData.sharedInstance.saveData()
                    }
                    
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                
            }
            } as! (AFHTTPRequestOperation?, Any?) -> Void) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
                if completionHandler != nil {
                    completionHandler!(false, operation.responseString as AnyObject)
                }
        }
    }
    
    func uploadMetadataFile(_ recordItem:RecordItem, completionHandler:((Bool, AnyObject?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey,"name":(recordItem.text)+"_metadata", "parent_id":(recordItem.id)]
        
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
        path += recordItem.localFile
        path = AudioFileTagManager.sharedInstance.getMetadataFilePath(path)
        NSLog(path)
        if !FileManager.default.fileExists(atPath: path ){
            completionHandler!(false, nil)
            return
        }
        
        manager?.post("create_meta_file", parameters: parameters, constructingBodyWith: { (data) -> Void in
            do {
                try data?.appendPart(withFileURL: NSURL(fileURLWithPath: path) as URL!, name: "file")
            }
            catch {
                
            }
            },
            success: { (operation, data) -> Void in
                do {
                    var jsonDict = try JSONSerialization.jsonObject(with: (operation?.responseData)!, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                    if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                        if completionHandler != nil {
                            if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                                if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                    AppPersistentData.sharedInstance.invalidAPIKey = true
                                }
                                
                                completionHandler!(false, strError.localized as AnyObject)
                            }
                            else {
                                completionHandler!(false, nil)
                            }
                        }
                    }
                else {
                    var tagsCount = 0
                    if(AudioFileTagManager.sharedInstance.audioFileTags == nil){
                        if completionHandler != nil {
                            completionHandler!( true, nil)
                        }
                        return
                    }
                    for tag in AudioFileTagManager.sharedInstance.audioFileTags{
                        if (tag as! AudioTag).type == TagType.photo{
                            tagsCount += 1
                        }
                    }
                    if(tagsCount == 0){
                        if completionHandler != nil {
                            completionHandler!( true, nil)
                        }
                        return
                    }
                    var tagsCompleted = 0
                    for tag in AudioFileTagManager.sharedInstance.audioFileTags{
                        if (tag as! AudioTag).type == TagType.photo{
                            var imgPath = AudioFileTagManager.sharedInstance.getPhotoFilePath(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as! String + recordItem.localFile, time: (tag as! AudioTag).timeStamp)
                            
                            var imgParameters = ["api_key": AppPersistentData.sharedInstance.apiKey,"name":imgPath.components(separatedBy:"/").last, "parent_id":(recordItem.id)]
                            self.manager?.post("create_meta_file", parameters: imgParameters, constructingBodyWith: { (data) -> Void in
                                do {
                                    try data?.appendPart(withFileURL: NSURL(fileURLWithPath: imgPath) as URL!, name: "file")
                                }
                                catch {
                                    
                                }
                                },
                                success: { (operation, data) -> Void in
                                    tagsCompleted = tagsCompleted + 1;
                                    if(tagsCompleted == tagsCount){
                                        if completionHandler != nil {
                                            completionHandler!( true, nil)
                                        }
                                    }
                                }) { (operation, error) -> Void in
                                    tagsCompleted = tagsCompleted + 1;
                                    if(tagsCompleted == tagsCount){
                                        if completionHandler != nil {
                                            completionHandler!( true, nil)
                                        }
                                    }
                                }

                        }
                    }
                }
                    
                }catch {
                        if completionHandler != nil {
                            completionHandler!(false, "Error parsing server result." as AnyObject)
                        }
                    }
            }) { (operation, error) -> Void in
                if completionHandler != nil {
                    completionHandler!(false, operation?.responseString as AnyObject)
                }
        }
    }
    
    func getMetadataFiles(_ recordItem:RecordItem, completionHandler:((Bool, AnyObject?) -> Void)?)
    {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        var parameters = ["api_key": AppPersistentData.sharedInstance.apiKey, "parent_id":(recordItem.id)]
        
        manager?.post("get_meta_files", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response:Any!) -> Void in
            do {
                var jsonDict = try JSONSerialization.jsonObject(with: operation.responseData, options:JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
                if (jsonDict.count == 0 || (jsonDict.count > 0 && jsonDict.object(forKey: "status") != nil && !(jsonDict.object(forKey: "status")! as AnyObject).isEqual("ok"))) {
                    if completionHandler != nil {
                        if let strError:String = jsonDict.object(forKey: "msg") as? String  {
                            if jsonDict.object(forKey: "msg") as? String == "Invalid API Key" {
                                AppPersistentData.sharedInstance.invalidAPIKey = true
                            }
                            
                            completionHandler!(false, strError.localized as AnyObject)
                        }
                        else {
                            completionHandler!(false, nil)
                        }
                    }
                }
                else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }
            catch {
                if completionHandler != nil {
                    completionHandler!(false, "Error parsing server result." as AnyObject)
                }
            }
            
        }) { (operation:AFHTTPRequestOperation!, error:Error!) -> Void in
            if completionHandler != nil {
                completionHandler!(false, operation.responseString as AnyObject)
            }
        }
    }
}
