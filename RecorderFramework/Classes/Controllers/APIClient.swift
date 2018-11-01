//
//  APIClient.swift
//  PPC
//
//  Created by Grif on 24/04/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

public let defaultToken = "55942ee3894f51000530894"
public let API_BASE_URL = "https://app2.virtualbrix.net/rapi/"

// all server paths
public enum ServerPaths : String {
    case registerPhone = "register_phone"
    case verifyPhone = "verify_phone"
    case getFiles = "get_files"
    case getPhones = "get_phones"
    case getFolders = "get_folders"
    case deleteFolder = "delete_folder"
    case createFolder = "create_folder"
    case updateOrder = "update_order"
    case updateFolder = "update_folder"
    case deleteFiles = "delete_files"
    case recoverFile = "recover_file"
    case updateFile = "update_file"
    case updateStar = "update_star"
    case cloneFile = "clone_file"
    case createFile = "create_file"
    case updateSettings = "update_settings"
    case updateUser = "update_user"
    case getSettings = "get_settings"
    case buyCredits = "buy_credits"
    case updateDeviceToken = "update_device_token"
    case notifyUser = "notify_user"
    case getTranslations = "get_translations"
    case getLanguages = "get_languages"
    case getMessages = "get_msgs"
    case uploadMetaFile = "upload_meta_file"
    case deleteMetaFiles = "delete_meta_files"
    case getMetaFiles = "get_meta_files"
    case getProfile = "get_profile"
    case updateProfile = "update_profile"
    case updateProfileImg = "upload/update_profile_img"
    case verifyFolderPass = "verify_folder_pass"
}

import Foundation

public class APIClient : NSObject {
    
    var mainSyncInProgress:Bool = false
    var mainSyncErrors:Int = 0
    
    @objc public  static let sharedInstance = APIClient()
    
    var api = Api(baseURL: API_BASE_URL)
    
    override init() {
        super.init()
        
        //completion handler log initialization
        api.completionHandlerLog = { (req, resp) in
            print(req)
            print(resp)
        }
    }
    
    //MARK: Register
    func validatePhone(_ number:String) -> Bool{
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = number.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        if  !(number == filtered && number.first == "+"){
            return false
        }else{
            return true
        }
    }
    
    public func register(_ number:String, token:String = defaultToken,completionHandler:((Bool, Any?) -> Void)?)
    {
        if !validatePhone(number){
            if completionHandler != nil {
                completionHandler!(false, "invalid phone number")
            }
        }
        
        api.doRequest(ServerPaths.registerPhone.rawValue, method: .post, parameters: APIRequestParametersController.createRegisterParameters(phone: number, token:token)) { (success, data) in
            if success {
                if let value = data!["phone"] as? String {
                    AppPersistentData.sharedInstance.phone = value
                }
                if let value = data!["api_key"] as? String {
                    AppPersistentData.sharedInstance.apiKey = value
                }
                if let value = data!["code"] as? String {
                    AppPersistentData.sharedInstance.verificationCode = value
                }
                AppPersistentData.sharedInstance.saveData()
                
                if completionHandler != nil {
                    completionHandler!(true, AppPersistentData.sharedInstance.verificationCode)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func sendVerificationCode(_ code:String, completionHandler:((Bool, Any?) -> Void)?) {
        api.doRequest(ServerPaths.verifyPhone.rawValue, method: .post, parameters: APIRequestParametersController.createSendVerificationCodeParameters(code: code)) { (success, data) in
            if success {
                if let value:String = data!["api_key"] as? String  {
                    AppPersistentData.sharedInstance.apiKey = value
                    AppPersistentData.sharedInstance.invalidAPIKey = false
                    AppPersistentData.sharedInstance.saveData()
                    #if os(iOS)
                    WatchKitController.sharedInstance.sendApiKey()
                    #endif
                    if completionHandler != nil {
                        completionHandler!( true, data)
                    }
                }else {
                    if completionHandler != nil {
                        if let strError:String = data!["msg"] as? String  {
                            completionHandler!(false, strError.localized as AnyObject)
                        }else {
                            completionHandler!(false, nil)
                        }
                    }
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    // for unit tests
    public func sendVerificationCode(parameters: [String: Any] ,completionHandler:((Bool, Any?) -> Void)?) {
        api.doRequest(ServerPaths.verifyPhone.rawValue, method: .post, parameters: parameters) { (success, data) in
            if success{
                if let value:String = data!["api_key"] as? String  {
                    AppPersistentData.sharedInstance.apiKey = value
                    AppPersistentData.sharedInstance.invalidAPIKey = false
                    AppPersistentData.sharedInstance.saveData()
                    
                    if completionHandler != nil {
                        completionHandler!( true, data)
                    }
                }else {
                    if completionHandler != nil {
                        if let strError:String = data!["msg"] as? String  {
                            completionHandler!(false, strError.localized as AnyObject)
                        }else {
                            completionHandler!(false, nil)
                        }
                    }
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func getRecordings(_ folderId:String!, lastFileId: String! = nil, less: Bool = false, pass:String! = nil, q:String! = nil, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        let parameters = APIRequestParametersController.createGetRecordingsParameters(folderId: folderId, lastFileId: lastFileId, less: less, pass:pass, q:q)
        api.doRequest(ServerPaths.getFiles.rawValue, method: .post, parameters: parameters) { (success, data) in
            if success {
                if let calls:Array<NSDictionary> = data!["files"] as? Array<NSDictionary> {
                    var allIds:Array<String> = Array<String>()
                    var recordFolder = RecordingsManager.sharedInstance.recordFolders[0]
                    for recFolder in RecordingsManager.sharedInstance.recordFolders {
                        if recFolder.id == folderId {
                            recordFolder = recFolder
                            break
                        }
                    }
                    for item in recordFolder.recordedItems {
                        let action:Action! = item.recordingNextAction(nil)
                        if action != nil {
                            allIds.append(item.id)
                        }
                    }
                    
                    for call in calls {
                        let item = RecorderFactory.createRecordItemFromDict(call)
                        if folderId == "trash"{
                            item.fromTrash = true
                        }
                        allIds.append(item.id)
                        
                        _ = RecordingsManager.sharedInstance.syncRecordingItem(item, folder:recordFolder)
                        
                        var on = UserDefaults.standard.object(forKey: "3GSync") as? Bool
                        if(on == nil){
                            on = true
                        }
                    }
                    
                    RecordingsManager.sharedInstance.updateAllFilesFolder()
                    AppPersistentData.sharedInstance.saveData()
                }
                
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func searchRecordings(_ q:String, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        api.doRequest(ServerPaths.getFiles.rawValue, method: .post, parameters: APIRequestParametersController.createSearchRecordingsParameters(q:q)) { (success, data) in
            if success {
                if let calls:Array<NSDictionary> = data!["files"] as? Array<NSDictionary> {

                    var items = [RecordItem]()
                    for call in calls {
                        let item = RecorderFactory.createRecordItemFromDict(call)
                        items.append(item)
                    }
                    if completionHandler != nil {
                        completionHandler!( true, items)
                    }
                    return
                }
                
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    //for unit tests
    public func getRecordings(parameters: [String:Any], completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        api.doRequest(ServerPaths.getFiles.rawValue, method: .post, parameters: parameters) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }
            else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func getPhoneNumbers(_ completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key")
            return
        }
        
        var defaultPhone = " "
        for phoneNumber in AppPersistentData.sharedInstance.phoneNumbers{
            if phoneNumber.isDefault{
                defaultPhone = phoneNumber.phoneNumber
                break
            }
        }
        AppPersistentData.sharedInstance.phoneNumbers.removeAll(keepingCapacity: false)
        
        api.doRequest(ServerPaths.getPhones.rawValue, method: .post, parameters: APIRequestParametersController.createDefaultParameters()) { (success, data) in
            if success {
                if let numbers:Array<NSDictionary> = data!["root"] as? Array<NSDictionary> {
                    
                    for number in numbers {
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
                    #if os(iOS)
                    WatchKitController.sharedInstance.sendPhone()
                    #endif
                }
                var downloadsCompleted = 0
                for phoneNumber in  AppPersistentData.sharedInstance.phoneNumbers {
                    let fileManager = FileManager.default
                    var path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)!.path
                    path = path.appendingFormat("/" + "flags" + "/");
                    do {
                        if !FileManager.default.fileExists(atPath: path) {
                            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                        }
                    }catch {
                        
                    }
                    path = path.appendingFormat(phoneNumber.flag.components(separatedBy: "/").last!)
                    if !FileManager.default.fileExists(atPath: path) {
                        APIClient.sharedInstance.downloadFile(phoneNumber.flag!, localPath:path, completionHandler: { (success) -> Void in
                            downloadsCompleted += 1
                            if(downloadsCompleted == AppPersistentData.sharedInstance.phoneNumbers.count){
                                if completionHandler != nil {
                                    completionHandler!( true, nil)
                                }
                            }
                        })
                    }else{
                        downloadsCompleted += 1
                        if(downloadsCompleted == AppPersistentData.sharedInstance.phoneNumbers.count){
                            if completionHandler != nil {
                                completionHandler!( true, nil)
                            }
                        }
                    }
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func getFolders(_ completionHandler:((Bool, Any?) -> Void)?) {
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
        
        api.doRequest(ServerPaths.getFolders.rawValue, method: .post, parameters: APIRequestParametersController.createDefaultParameters()) { (success, data) in
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
            if !foundTrash {
                let defaultFolder = RecordFolder()
                defaultFolder.id = "trash"
                defaultFolder.title = "Trash".localized
                RecordingsManager.sharedInstance.recordFolders.insert(defaultFolder, at: 2)
            }
            
            if success {
                if let folders:Array<NSDictionary> = data!["folders"] as? Array<NSDictionary> {
                    var ids:Array<String> = Array<String>()
                    ids.append("0")
                    ids.append("-99")
                    ids.append("trash")
                    for folder in folders {
                        let recordFolder = RecorderFactory.createRecordFolderFromDict(folder)
                        ids.append(recordFolder.id)
                        
                        _ = RecordingsManager.sharedInstance.syncItem(recordFolder)
                    }
                    RecordingsManager.sharedInstance.keepOnlyItemsWithIds(ids);
                    RecordingsManager.sharedInstance.updateTrashFolder()
                    RecordingsManager.sharedInstance.sortByFolderOrder()
                }
                #if os(iOS)
                WatchKitController.sharedInstance.sendFolders()
                #endif
                if completionHandler != nil {
                    completionHandler!( true, RecordingsManager.sharedInstance.recordFolders)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func createFolder(_ name:String, localID:String , pass:String! = nil, completionHandler:((Bool, Any?) -> Void)?)
    {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.createFolder.rawValue, method: .post, parameters: APIRequestParametersController.createCreateFolderParameters(name:name, localID:localID, pass:pass)) { (success, data) in
            if success {
                var recordFolder = RecordingsManager.sharedInstance.getFolderWithId(localID as String)
                if recordFolder == nil {
                    recordFolder = RecordFolder()
                }
                
                if let value:String = data!["name"] as? String {
                    recordFolder?.title = value
                }else {
                    recordFolder?.title = name as String
                }
                if let value:NSNumber = data!["id"] as? NSNumber {
                    recordFolder?.id = value.stringValue
                    for action in ActionsSyncManager.sharedInstance.actions {
                        if action.arg1 != nil && action.arg1 == localID as String {
                            action.arg1 = recordFolder?.id
                        }
                        
                        if action.arg2 != nil && action.arg2 == localID as String {
                            action.arg2 = recordFolder?.id
                        }
                    }
                }
                _ = RecordingsManager.sharedInstance.syncItem(recordFolder!)
                
                if let value:NSNumber = data!["id"] as? NSNumber {
                    if completionHandler != nil {
                        completionHandler!( true, value)
                    }
                }else{
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    public func deleteFolder(_ folderId:String, moveTo:String!, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        api.doRequest(ServerPaths.deleteFolder.rawValue, method: .post, parameters: APIRequestParametersController.createDeleteFoldersParameters(folderId:folderId, moveTo:moveTo)) { (success, data) in
            if success {
                if completionHandler != nil {
                    //{"status":"ok","msg":"Deleted Successfully"}
                    completionHandler!( true, nil)
                    APIClient.sharedInstance.updateFolders({ (success) -> Void in
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
                    })
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func reorderFolders(_ parameters:[String:Any], completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        api.doRequest(ServerPaths.updateOrder.rawValue, method: .post, parameters: APIRequestParametersController.createDefaultParameters()) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                    self.updateFolders({ (success) -> Void in
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
                    })
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    public func renameFolder(_ folderId:String, name:String, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.updateFolder.rawValue, method: .post, parameters: APIRequestParametersController.createRenameFolderParameters(folderId:folderId, name:name)) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    public func addPasswordToFolder(_ folderId:String, pass:String, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.updateFolder.rawValue, method: .post, parameters: APIRequestParametersController.createAddPassToFolderParameters(folderId: folderId, pass: pass)) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    public func deleteRecording(_ recordItemId:String, removeForever:Bool, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        /*
         if  action=remove_forever then file will be removed permanently
         comma separated ids limit is 30
         */
        api.doRequest(ServerPaths.deleteFiles.rawValue, method: .post, parameters: APIRequestParametersController.createDeleteRecordingParameters(recordItemId: recordItemId, removeForever: removeForever)) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
                RecordingsManager.sharedInstance.deleteRecordingItem(recordItemId)
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    public func moveRecording(_ recordItem:RecordItem, folderId:String, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.updateFile.rawValue, method: .post, parameters: APIRequestParametersController.createMoveRecordingParameters(recordItem:recordItem, folderId:folderId)) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    public func recoverRecording(_ recordItem:RecordItem, folderId:String, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        api.doRequest(ServerPaths.recoverFile.rawValue, method: .post, parameters: APIRequestParametersController.createRecoverRecordingParameters(recordItem: recordItem, folderId: folderId)) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    public func updateRecordingInfo(_ recordItem:RecordItem ,parameters:[String:Any], completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        api.doRequest(ServerPaths.updateFile.rawValue, method: .post, parameters: APIRequestParametersController.createDefaultParameters()) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    
    func star(_ star:Bool, entityId:String, isFile:Bool, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.updateStar.rawValue, method: .post, parameters: APIRequestParametersController.createStarItemParameters(star: star, entityId: entityId, isFile: isFile)) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    // for unit tests
    public func star(_ parameters:[String:Any], completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        api.doRequest(ServerPaths.updateStar.rawValue, method: .post, parameters: parameters) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func cloneFile(entityId:String, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.cloneFile.rawValue, method: .post, parameters: APIRequestParametersController.createCloneFileParameters(entityId: entityId)) { (success, data) in
            if success {
                if let id = data!["id"]{
                    if completionHandler != nil {
                        completionHandler!( true, "\(id)")
                    }
                }else {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func renameRecording(_ recordItem:RecordItem, name:String, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        api.doRequest(ServerPaths.updateFile.rawValue, method: .post, parameters: APIRequestParametersController.createRenameRecordingParameters(recordItem: recordItem, name: name)) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    public func uploadRecording(_ recordItem:RecordItem!, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        if recordItem.localFile == nil{
            return
        }
        
        let fileManager = FileManager.default
        var path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)!.path
        path += recordItem.localFile
        
        if URL(fileURLWithPath:path).pathExtension == "caf" {
            let wavPath = path.replacingOccurrences(of: ".caf", with: ".wav", options: NSString.CompareOptions.literal, range: nil)
            //                AudioConverter.exportAsset(asWaveFormat: path, destination:wavPath)
            path = wavPath
        }
        
        if !FileManager.default.fileExists(atPath: path ){
            completionHandler!(false, nil)
            return
        }
        
        api.upload(API_BASE_URL + ServerPaths.createFile.rawValue, imagesFiles: [path], fieldNames: ["file"], parameters:APIRequestParametersController.createUploadRecordingParameters(recordItem: recordItem)) { (success, retData) in
            if success {
                if let data = retData as? [String:Any] {
                    //{"status":"ok","msg":”File Uploaded Successfully",”id”:”1”}
                    if let value:NSNumber = data["id"] as? NSNumber  {
                        recordItem.id = String(format:"%.0f", value.doubleValue)
                    }
                    
                    if completionHandler != nil {
                        completionHandler!( true, recordItem.id)
                    }
                }
            }else {
                if completionHandler != nil {
                    if retData is String {
                        completionHandler!(success, retData)
                    }else {
                        completionHandler!(success, "Error occured while uploading file.")
                    }
                }
            }
        }
    }
    
    func downloadFile(_ fileUrl:String, localPath:String, completionHandler:((Bool) -> Void)?)
    {
        if (AppPersistentData.sharedInstance.invalidAPIKey || fileUrl == ""){
            completionHandler!(false)
            return
        }
        
        var url = fileUrl as String
        url += "?api_key=" + AppPersistentData.sharedInstance.apiKey!
        
        api.downloadFile(url, atPath: localPath) { (success, data) in
            if completionHandler != nil {
                completionHandler!(success)
            }
        }
    }
    
    public func downloadAudioFile(_ recordItem:RecordItem, toFolder:String, completionHandler:((Bool) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false)
            return
        }
        
        let fileManager = FileManager.default
        var path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)!.path
        path = path + ("/" + toFolder + "/");
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }catch {
                
            }
        }
        path = path + recordItem.url.components(separatedBy: "/").last!
        
        var isWav = false
        var isMP3 = false
        if path.range(of: ".wav") != nil {
            isWav = true
        }
        
        if path.range(of: ".mp3") != nil {
            isMP3 = true
        }
        if !isWav && !isMP3 {
            path = path + ".wav"
        }
        
        // improve: remove local file if already exist and download it again (it may be a broken file)
        
        if !FileManager.default.fileExists(atPath: path) {
            APIClient.sharedInstance.downloadFile(recordItem.url!, localPath:path, completionHandler: { (success) -> Void in
                recordItem.fileDownloaded = success
                if success {
                    recordItem.localFile = "/" + toFolder + "/" + recordItem.url.components(separatedBy: "/").last!
                    var isWav = false
                    var isMP3 = false
                    if recordItem.localFile.range(of: ".wav") != nil {
                        isWav = true
                    }
                    
                    if recordItem.localFile.range(of: ".mp3") != nil {
                        isMP3 = true
                    }
                    if !isWav && !isMP3 {
                        recordItem.localFile = recordItem.localFile + ".wav"
                    }
                    var fileSize = UInt64(0)
                    do {
                        let attr = try FileManager.default.attributesOfItem(atPath: path)
                        fileSize = attr[FileAttributeKey.size] as! UInt64
                    }catch {
                        print("Error: \(error)")
                    }
                    recordItem.fileSize = "\(fileSize/1000)"
                    self.getMetadataForRecordItem(recordItem,path:path, masterCompletionHandler: nil)
                    completionHandler!(true)
                }else{
                    completionHandler!(false)
                }
            })
        }
        else {
            recordItem.fileDownloaded = true
            recordItem.localFile = "/" + toFolder + "/" + recordItem.url.components(separatedBy: "/").last!
            var isWav = false
            var isMP3 = false
            if recordItem.localFile.range(of: ".wav") != nil {
                isWav = true
            }
            
            if recordItem.localFile.range(of: ".mp3") != nil {
                isMP3 = true
            }
            if !isWav && !isMP3 {
                recordItem.localFile = recordItem.localFile + ".wav"
            }
            var fileSize = UInt64(0)
            do {
                let attr = try FileManager.default.attributesOfItem(atPath: path)
                fileSize = attr[FileAttributeKey.size] as! UInt64
            }catch {
                print("Error: \(error)")
            }
            recordItem.fileSize = "\(fileSize/1000)"
            self.getMetadataForRecordItem(recordItem,path:path, masterCompletionHandler: nil)
            completionHandler!(true)
        }
    }
    
    func getMetadataForRecordItem(_ recordItem: RecordItem, path: String, masterCompletionHandler:((Bool) -> Void)?){
        NSLog(path)
        self.getMetadataFiles(recordItem, completionHandler: { (success, files) -> Void in
            if success && files != nil {
                let allFiles = files as! Array<NSDictionary>
                for file in allFiles{
                    let url = (file.object(forKey: "file") as? String)!
                    let name = (file.object(forKey: "name") as? String)!
                    var metaPath = AudioFileTagManager.sharedInstance.getMetadataFilePath(path)
                    if url.components(separatedBy: ".").last != "json" {
                        metaPath = RecorderFrameworkManager.sharedInstance.getPath() + recordItem.localFile.components(separatedBy: ".").first! + "/" + ((file.object(forKey: "id") as? String)!) + "." + url.components(separatedBy: ".").last!
                    }else{
                        recordItem.metaFileId = (file.object(forKey: "id") as? String)!
                    }
                    
                    APIClient.sharedInstance.downloadFile(url, localPath:metaPath, completionHandler: { (success) -> Void in
                        if(success){
                            recordItem.setupWithFile(path)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
                            AppPersistentData.sharedInstance.saveData()
                        }
                    })
                    if masterCompletionHandler != nil{
                        masterCompletionHandler!(true)
                    }
                }
            }else {
                if masterCompletionHandler != nil{
                    masterCompletionHandler!(false)
                }
            }
        })
    }
    
    public func defaultFolderSync(_ completionHandler:((Bool) -> Void)?) {
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
        }
        var lastRecording:RecordItem!
        if let folder = RecordingsManager.sharedInstance.recordFolders.first{
            if let rec = folder.recordedItems.first{
                lastRecording = rec
            }
        }
        if lastRecording != nil {
            APIClient.sharedInstance.getRecordings("0", lastFileId: lastRecording.id, completionHandler:{ (success, data) -> Void in
                RecordingsManager.sharedInstance.updateAllFilesFolder()
                if completionHandler != nil {
                    completionHandler!(success)
                }
            })
        }else{
            
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
            //            AppPersistentData.sharedInstance.apiKey = "562a60677fd88562a60677fdc4"
        }
        mainSyncInProgress = true
        mainSyncErrors = 0
        
        APIClient.sharedInstance.getSettings({ (success, data) -> Void in
            APIClient.sharedInstance.getMessages({ (success, data) -> Void in
                APIClient.sharedInstance.getLanguages { (success, data) -> Void in
                    APIClient.sharedInstance.getTranslations(TranslationManager.sharedInstance.currentLanguage, completionHandler:{ (success, data) -> Void in
                        APIClient.sharedInstance.getProfile({ (success, data) -> Void in
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
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
                                    })
                                })
                            }
                        })
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
    
    func updateSettings(_ playBeep:Bool, filesPersmission:Bool = true,completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.updateSettings.rawValue, method: .post, parameters: APIRequestParametersController.createUpdateSettingsParameters(playBeep: playBeep, filesPersmission: filesPersmission)) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func updateUser(_ free:Bool, timezone:String! = nil, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.updateUser.rawValue, method: .post, parameters: APIRequestParametersController.createUpdateUserParameters(free:free, timezone:timezone)) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func getSettings(_ completionHandler:((Bool, Any?) -> Void)?)
    {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.getSettings.rawValue, method: .post, parameters: APIRequestParametersController.createDefaultParameters()) { (success, data) in
            if success {
                if let settings:NSDictionary = data!["settings"] as? NSDictionary {
                    if let value:String = settings.object(forKey: "play_beep") as? String {
                        AppPersistentData.sharedInstance.user.playBeep = value == "no" ? false:true
                    }
                    if let value:String = settings.object(forKey: "files_permission") as? String {
                        AppPersistentData.sharedInstance.filePermission = value
                    }
                    if let value:Int = data!["credits"] as? Int {
                        AppPersistentData.sharedInstance.credits = value
                    }
                    if let value:String = data!["app"] as? String {
                        AppPersistentData.sharedInstance.app = value
                    }
                    AppPersistentData.sharedInstance.user.timeZone = "\(TimeZone.current.secondsFromGMT() / 60)"
                    AppPersistentData.sharedInstance.saveData()
                }
                
                if completionHandler != nil {
                    completionHandler!( true, data!["settings"])
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func buyCredits(_ credits:Int, receipt:String, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.buyCredits.rawValue, method: .post, parameters: APIRequestParametersController.createBuyCreditsParameters(credits: credits, receipt: receipt)) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    //for unit tests
    public func buyCredits(_ parameters:[String: Any], completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }

        api.doRequest(ServerPaths.buyCredits.rawValue, method: .post, parameters: parameters) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func updateToken(_ token:String, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.updateDeviceToken.rawValue, method: .post, parameters: APIRequestParametersController.createUpdateTokenParameters(token: token)) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    //for unit tests
    public func updateToken(_ parameters:[String:Any], completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.updateDeviceToken.rawValue, method: .post, parameters: parameters) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func notifyUser(_ token:String, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.notifyUser.rawValue, method: .post, parameters: APIRequestParametersController.createNotifyUserParameters(token:token)) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func getTranslations(_ language:String,completionHandler:((Bool, Any?) -> Void)?)
    {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.getTranslations.rawValue, method: .post, parameters: APIRequestParametersController.createGetTranslationsParameters(language: language)) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, data)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func getLanguages(_ completionHandler:((Bool, Any?) -> Void)?){
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.getLanguages.rawValue, method: .post, parameters: APIRequestParametersController.createDefaultParameters()) { (success, data) in
            if success {
                if let calls:Array<NSDictionary> = data!["languages"] as? Array<NSDictionary> {
                    TranslationManager.sharedInstance.languages = Array()
                    for call in calls {
                        let item:Language = Language()
                        
                        if let value:String = call.object(forKey: "name") as? String {
                            item.name = value
                        }
                        if let value:String = call.object(forKey: "code") as? String {
                            item.code = value
                        }
                        TranslationManager.sharedInstance.languages.append(item)
                    }
                    AppPersistentData.sharedInstance.saveData()
                }
                
                if completionHandler != nil {
                    completionHandler!( true, TranslationManager.sharedInstance.languages)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    @objc func getMessages(_ completionHandler:((Bool, Any?) -> Void)?)
    {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        let defaults = UserDefaults.standard
        let lastTime = defaults.object(forKey: "messageTime")

        api.doRequest(ServerPaths.getMessages.rawValue, method: .post, parameters: APIRequestParametersController.createDefaultParameters()) { (success, data) in
            if success {
                if let msgs:Array<NSDictionary> = data!["msgs"] as? Array<NSDictionary> {
                    defaults.set(NSNumber(value: NSDate().timeIntervalSince1970), forKey: "messageTime")
                    
                    for msg in msgs {
                        let item:ServerMessage = ServerMessage()
                        
                        if let value:String = msg.object(forKey: "id") as? String {
                            item.id = value
                        }
                        if let value:String = msg.object(forKey: "title") as? String {
                            item.title = value
                        }
                        if let value:String = msg.object(forKey: "body") as? String {
                            item.body = value
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
                    completionHandler!( true, AppPersistentData.sharedInstance.serverMessages)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func uploadMetadataImageFile(_ imagePath:String, fileId: String, oldId:String! = nil, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        if !FileManager.default.fileExists(atPath: imagePath ){
            completionHandler!(false, nil)
            return
        }
        
        api.upload(API_BASE_URL + ServerPaths.uploadMetaFile.rawValue, imagesFiles: [imagePath], fieldNames: ["file"], parameters:APIRequestParametersController.createUploadImageMetadataFileParameters(imagePath: imagePath, fileId: fileId, oldId: oldId)) { (success, retData) in
            if success {
                if let data = retData as? [String:Any] {
                    if completionHandler != nil {
                        completionHandler!( true, data["id"])
                    }
                }
            }else {
                if completionHandler != nil {
                    if retData is String {
                        completionHandler!(success, retData)
                    }else {
                        completionHandler!(success, "Error occured while uploading file.")
                    }
                }
            }
        }
    }
    
    func uploadMetadataFile(_ recordItem:RecordItem, oldId:String! = nil, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        
        let fileManager = FileManager.default
        var path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)!.path
        path += recordItem.localFile
        path = AudioFileTagManager.sharedInstance.getMetadataFilePath(path)
        NSLog(path)
        if !FileManager.default.fileExists(atPath: path ){
            completionHandler!(false, nil)
            return
        }       
        
        api.upload(API_BASE_URL + ServerPaths.uploadMetaFile.rawValue, imagesFiles: [path], fieldNames: ["file"], parameters:APIRequestParametersController.createUploadMetadataFileParameters(recordItem: recordItem, oldId: oldId)) { (success, retData) in
            if success {
                if let data = retData as? [String:Any] {
                    if completionHandler != nil {
                        if path.contains("json"){
                            recordItem.metaFileId = "\(data["id"]!)"
                        }
                        completionHandler!( true, nil)
                    }
                }
            }else {
                if completionHandler != nil {
                    if retData is String {
                        completionHandler!(success, retData)
                    }else {
                        completionHandler!(success, "Error occured while uploading file.")
                    }
                }
            }
        }
    }
    
    func deleteMetadataFile(_ fileId:String, parentId: String! = nil,completionHandler:((Bool, Any?) -> Void)?)
    {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.deleteMetaFiles.rawValue, method: .post, parameters: APIRequestParametersController.createDeleteMetadataFileParameters(fileId: fileId, parentId: parentId)) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }

    public func getMetadataFiles(_ recordItem:RecordItem, completionHandler:((Bool, Any?) -> Void)?)
    {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.getMetaFiles.rawValue, method: .post, parameters: APIRequestParametersController.createGetMetadataFilesParameters(recordItem: recordItem)) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, data?["meta_files"])
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
        
    }
    
    //MARK: profile
    func getProfile(_ completionHandler:((Bool, Any?) -> Void)?)
    {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        api.doRequest(ServerPaths.getProfile.rawValue, method: .post, parameters: APIRequestParametersController.createDefaultParameters()) { (success, data) in
            if success {
                if let profile:NSDictionary = data!["profile"] as? NSDictionary {
                    AppPersistentData.sharedInstance.user = RecorderFactory.createUserFromDict(profile)
                    AppPersistentData.sharedInstance.user.timeZone = "\(TimeZone.current.secondsFromGMT() / 60)"
                    AppPersistentData.sharedInstance.saveData()
                    
                    #if os(iOS)
                    WatchKitController.sharedInstance.sendUser()
                    #endif
                }
                
                if let url:String = data!["share_url"] as? String {
                    AppPersistentData.sharedInstance.shareUrl = url
                }
                if let url:String = data!["rate_url"] as? String {
                    AppPersistentData.sharedInstance.rateUrl = url
                }
                if completionHandler != nil {
                    completionHandler!( true, data)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    //for unit tests
    public func updateProfile(params:[String:Any], completionHandler:((Bool, Any?) -> Void)?)
    {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        var parameters = params
        parameters["api_key"] = AppPersistentData.sharedInstance.apiKey!
        
        api.doRequest(ServerPaths.updateProfile.rawValue, method: .post, parameters: parameters) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
    
    func uploadProfilePicture(path:String, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        if !FileManager.default.fileExists(atPath: path ){
            completionHandler!(false, nil)
            return
        }

        var url = API_BASE_URL.replacingOccurrences(of: "rapi/", with: ServerPaths.updateProfileImg.rawValue)
        api.upload(url, imagesFiles: [path], fieldNames: ["file"], parameters:APIRequestParametersController.createDefaultParameters(), mimeType: "image/jpeg") { (success, retData) in
            if success {
                if let data = retData as? [String:Any] {
                    if completionHandler != nil {
                        completionHandler!( true, nil)
                    }
                }
                
            }else {
                if completionHandler != nil {
                    if retData is String {
                        completionHandler!(success, retData)
                    }else {
                        completionHandler!(success, "Error occured while uploading file.")
                    }
                }
            }
        }
    }
    
    public func verifyFolderPass(_ pass:String, folderId:String, completionHandler:((Bool, Any?) -> Void)?) {
        if AppPersistentData.sharedInstance.invalidAPIKey {
            completionHandler!(false, "Invalid API Key" as AnyObject)
            return
        }
        
        api.doRequest(ServerPaths.verifyFolderPass.rawValue, method: .post, parameters: APIRequestParametersController.createVerifyFolderPassParameters(pass: pass, folderId: folderId)) { (success, data) in
            if success {
                if completionHandler != nil {
                    completionHandler!( true, nil)
                }
            }else {
                if completionHandler != nil {
                    completionHandler!(success, data!["error"] as? String)
                }
            }
        }
    }
}

