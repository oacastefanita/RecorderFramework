//
//  ActionsSyncManager.swift
//  Recorder
//
//  Created by Grif on 30/04/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

//All public action types
@objc public enum ActionType : Int {
    case deleteRecording
    case renameRecording
    case moveRecording
    case recoverRecording
    case createFolder
    case renameFolder
    case deleteFolder
    case reorderFolders
    case uploadRecording
    case updateFileInfo
    case buyCredits
    case custom
    case addPasswordToFolder
    case updateUserProfile
    case uploadMetadata
    case starItem
}

public class Action : NSObject, NSCoding {
    
    @objc public var id:String
    @objc public var type:ActionType = ActionType.moveRecording
    @objc public var arg1:String!
    @objc public var arg2:String!
    @objc public var arg3:NSMutableDictionary!
    
    var timeStamp:TimeInterval!
    
    override public init() {
        id = UUID().uuidString
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        id = UUID().uuidString
        
        if let value = aDecoder.decodeObject(forKey: "id") as? String {
            self.id = value
        }
        if let value = aDecoder.decodeObject(forKey: "type") as? String {
            let intVal:Int = Int(value)!
            self.type = ActionType(rawValue:intVal)!
        }
        if let value = aDecoder.decodeObject(forKey: "arg1") as? String {
            self.arg1 = value
        }
        if let value = aDecoder.decodeObject(forKey: "arg2") as? String {
            self.arg2 = value
        }
        if let value = aDecoder.decodeObject(forKey: "arg3") as? Data {
            self.arg3 = NSKeyedUnarchiver.unarchiveObject(with: value) as? NSMutableDictionary
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(NSString(format: "%d", self.type.rawValue) as String, forKey: "type")
        if let value = arg1 {
            aCoder.encode(value, forKey: "arg1")
        }
        if let value = arg2 {
            aCoder.encode(value, forKey: "arg2")
        }
        if let value = arg3 {
            let data =  NSKeyedArchiver.archivedData(withRootObject: value)
            aCoder.encode(data, forKey: "arg3")
        }
        
    }
    
}

protocol CustomActionDelegate {
    func handle(action:Action, completionHandler:((Bool, AnyObject?) -> Void)?)
}

//Actions manager is used to cache all user actions for an item in case of no internet connection and start sending them to the server when the internet connection is restored
@objc class ActionsSyncManager : NSObject {
    @objc public static let sharedInstance = ActionsSyncManager()
    
    @objc public var actions = [Action]()// curent list of actions
    @objc public var syncInProgress = false
    @objc public var actionsFailed:Int = 0//number of actions that have failed
    
    var delegate:CustomActionDelegate!
    
    override init() {
        super.init()
        #if os(iOS)
        AFNetworkReachabilityManager.shared().startMonitoring()
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status) -> Void in
            if status == AFNetworkReachabilityStatus.reachableViaWiFi || status == AFNetworkReachabilityStatus.reachableViaWWAN {
                self.startProcessingActions()
            }
        }
        #endif
    }
    
    func addAction(_ action: Action){
        actions.append(action)
        self.saveActions()
        self.startProcessingActions()
    }
    
    // MARK: credits
    func buyCredits(_ credits:Int, reciept:String!) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.buyCredits
        action.arg1 = "\(credits)"
        action.arg2 = reciept
        addAction(action)
    }
    
    func buyCredits(_ credits:Int, reciept:String!, completionHandler:((Bool, Any?) -> Void)?) {
        APIClient.sharedInstance.buyCredits(credits, receipt:reciept, completionHandler: { (success, data) -> Void in
            completionHandler?(success,data)
        })
    }
    
    // MARK: folder actions
    func createFolder(_ recordFolder:RecordFolder) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.createFolder
        action.arg1 = recordFolder.id
        action.arg2 = "\(recordFolder.color.rawValue)"
        addAction(action)
    }
    
    func deleteFolder(_ recordFolder:RecordFolder, moveToFolder:String!) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.deleteFolder
        action.arg1 = recordFolder.id
        action.arg2 = moveToFolder
        for var i in (0..<actions.count){
            if actions[i].arg1 == action.arg1 && action.type.rawValue > 2 && action.type.rawValue <= ActionType.reorderFolders.rawValue {
                actions.remove(at: i)
                i -= 1
            }
        }
        addAction(action)
    }
    
    func renameFolder(_ recordFolder:RecordFolder) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.renameFolder
        action.arg1 = recordFolder.id
        action.arg2 = recordFolder.title
        action.arg3 = ["color":"\(recordFolder.color.rawValue)"]
        addAction(action)
    }
    
    func addPasswordToFolder(_ recordFolder:RecordFolder) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.addPasswordToFolder
        action.arg1 = recordFolder.id
        action.arg2 = recordFolder.password
        action.arg3 = ["hint":recordFolder.passwordHint]
        addAction(action)
    }
    
    
    // MARK: recordings actions
    func deleteRecording(_ recordItem:RecordItem, forever:Bool) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.deleteRecording
        action.arg1 = recordItem.id
        action.arg2 = forever ? "true" : "false"
        for var i in (0..<actions.count){
            if actions[i].arg1 == action.arg1 && action.type.rawValue <= 2 {
                actions.remove(at: i)
                i -= 1
            }
        }
        addAction(action)
    }
    
    func deleteRecordings(_ recordItemIds:String, forever:Bool) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.deleteRecording
        action.arg1 = recordItemIds
        action.arg2 = forever ? "true" : "false"
        for var i in (0..<actions.count){
            if actions[i].arg1 == action.arg1 && action.type.rawValue <= 2 {
                actions.remove(at: i)
                i -= 1
            }
        }
        addAction(action)
    }
    
    func moveRecording(_ recordItem:RecordItem, folderId:String) {
        
        var okToAdd = false
        for iterateFolder in RecordingsManager.sharedInstance.recordFolders {
            if iterateFolder.id == "-99" {
                continue
            }
            for iterateRec in iterateFolder.recordedItems {
                if iterateRec.id == recordItem.id {
                    if iterateFolder.id != folderId {
                        okToAdd = true
                        break
                    }
                }
            }
            if okToAdd {
                break
            }
        }
        if !okToAdd {
            return
        }
        
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.moveRecording
        action.arg1 = recordItem.id
        action.arg2 = folderId
        addAction(action)
    }
    
    func recoverRecording(_ recordItem:RecordItem, folderId:String) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.recoverRecording
        action.arg1 = recordItem.id
        action.arg2 = folderId
        addAction(action)
    }
    
    func renameRecording(_ recordItem:RecordItem) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.renameRecording
        action.arg1 = recordItem.id
        action.arg2 = recordItem.text
        addAction(action)
    }
    
    @objc func uploadRecording(_ recordItem:RecordItem) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.uploadRecording
        action.arg1 = recordItem.id
        action.arg2 = recordItem.text
        addAction(action)
    }
    
    func updateRecordingInfo(_ recordItem:RecordItem, fileInfo:NSMutableDictionary) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.updateFileInfo
        action.arg1 = recordItem.id
        action.arg3 = fileInfo;
        addAction(action)
    }
    
    func updateRecordingMetadata(_ recordItem:RecordItem) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.uploadMetadata
        action.arg1 = recordItem.id
        addAction(action)
    }
    
    func updateUserProfile(userInfo:NSMutableDictionary) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.updateUserProfile
        action.arg3 = userInfo
        addAction(action)
    }
    
    func reorderFolders(_ parameters:NSMutableDictionary) {
        let action = Action()
        action.arg1 = "-1"
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.reorderFolders
        action.arg3 = parameters
        addAction(action)
    }
    
    func customAction(arg1:String?, arg2:String?, arg3:NSMutableDictionary?) {
        let action = Action()
        action.arg1 = arg1
        action.arg2 = arg2
        action.arg3 = arg3
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.custom
        addAction(action)
    }
    
    // MARK: folder actions
    func starItem(_ star:Bool, entityId:String, isFile:Bool) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.starItem
        action.arg1 = star ? "1" : "0"
        action.arg2 = isFile ? "1" : "0"
        action.arg3 = ["id":entityId]
        addAction(action)
    }
    
    // MARK: processing
    
    func startProcessingActions() {
        if AppPersistentData.sharedInstance.apiKey == nil {
            return
        }
        if syncInProgress {
            return
        }
        actionsFailed = 0
        if self.actions.count > 0 {
            syncInProgress = true
            self.processActions(self.actions)
        }
    }
    
    func moveToNextActionFrom(_ action:Action?, success:Bool, newActions:[Action]){
        
        //disabled retry mechanism as it doesn't have a fallback solution
//        if !success {
//            self.actionsFailed += 1
//        }
//        else {
            self.removeAction(action!.id)
            self.saveActions()
//        }
        self.processActions(newActions)
    }
    
    func actionNotFound(_ action: Action?, newActions:[Action]){
        self.removeAction(action!.id)
        processActions(newActions)
    }
    
    func processActions( _ workingActions:[Action] ) {
        if workingActions.count == 0 {
            syncInProgress = false
            self.saveActions()
            APIClient.sharedInstance.mainSync({ (success, data) -> Void in
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
            })
            return
        }
        
        let action = workingActions.first
        var newActions = workingActions
        newActions.remove(at: 0)
        
        switch(action!.type) {
        case ActionType.deleteRecording:
            APIClient.sharedInstance.deleteRecording(action!.arg1, removeForever:action!.arg2 == "true", completionHandler: { (success, data) -> Void in
                self.moveToNextActionFrom(action, success: success, newActions: newActions)
            })
            
            break
        case ActionType.moveRecording:
            let recordItem = RecordingsManager.sharedInstance.getRecordingById(action!.arg1)
            if recordItem != nil {
                APIClient.sharedInstance.moveRecording(recordItem!, folderId:action!.arg2, completionHandler: { (success, data) -> Void in
                    self.moveToNextActionFrom(action, success: success, newActions: newActions)
                })
            }
            else {
                actionNotFound(action, newActions: newActions)
            }
            
            break
        case ActionType.recoverRecording:
            let recordItem = RecordingsManager.sharedInstance.getRecordingById(action!.arg1)
            if recordItem != nil {
                APIClient.sharedInstance.recoverRecording(recordItem!, folderId:action!.arg2, completionHandler: { (success, data) -> Void in
                    self.moveToNextActionFrom(action, success: success, newActions: newActions)
                })
            }
            else {
                actionNotFound(action, newActions: newActions)
            }
            
            break
        case ActionType.renameRecording:
            let recordItem = RecordingsManager.sharedInstance.getRecordingById(action!.arg1)
            if recordItem != nil {
                APIClient.sharedInstance.renameRecording(recordItem!, name:action!.arg2, completionHandler: { (success, data) -> Void in
                    self.moveToNextActionFrom(action, success: success, newActions: newActions)
                })
            }
            else {
                actionNotFound(action, newActions: newActions)
            }
            
            break
        case ActionType.uploadRecording:
            var on = UserDefaults.standard.object(forKey: "3GSync") as? Bool
            if(on == nil){
                on = true
            }
            #if os(iOS)
            if !(AFNetworkReachabilityManager.shared().isReachableViaWiFi || on!) {
                processActions(newActions)
                break
            }
            #endif
            
            let recordItem = RecordingsManager.sharedInstance.getRecordingById(action!.arg1)
            if recordItem != nil {
                APIClient.sharedInstance.uploadRecording(recordItem!, completionHandler: { (success, data) -> Void in
                    if(success){
                        APIClient.sharedInstance.uploadMetadataFile(recordItem!, completionHandler: { (success, data) -> Void in
                            self.moveToNextActionFrom(action, success: success, newActions: newActions)
                        })
                    } else{
                        self.actionsFailed += 1
                        self.processActions(newActions)
                    }
                })
            }
            else {
                actionNotFound(action, newActions: newActions)
            }
            break
            
        case ActionType.uploadMetadata:
            var on = UserDefaults.standard.object(forKey: "3GSync") as? Bool
            if(on == nil){
                on = true
            }
            #if os(iOS)
                if !(AFNetworkReachabilityManager.shared().isReachableViaWiFi || on!) {
                    processActions(newActions)
                    break
                }
            #endif
            let recordItem = RecordingsManager.sharedInstance.getRecordingById(action!.arg1)
            if recordItem != nil {
                APIClient.sharedInstance.uploadMetadataFile(recordItem!, completionHandler: { (success, data) -> Void in
                    self.moveToNextActionFrom(action, success: success, newActions: newActions)
                })
            }
            else {
                actionNotFound(action, newActions: newActions)            }
            break
        case ActionType.createFolder:
            let recordFolder = RecordingsManager.sharedInstance.getFolderByLinkedAction(action!.id)
            if recordFolder != nil {
                APIClient.sharedInstance.createFolder(recordFolder!.title!, localID:recordFolder!.id!, color: action!.arg2, completionHandler: { (success, data) -> Void in
                    self.moveToNextActionFrom(action, success: success, newActions: newActions)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
                })
            }
            else {
                actionNotFound(action, newActions: newActions)
            }
            break
        case ActionType.renameFolder:
            let recordFolder = RecordingsManager.sharedInstance.getFolderByLinkedAction(action!.id)
            if recordFolder != nil {
                APIClient.sharedInstance.renameFolder((recordFolder?.id)!, name:action!.arg2, color: action!.arg3["color"] as! String, completionHandler: { (success, data) -> Void in
                    self.moveToNextActionFrom(action, success: success, newActions: newActions)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
                })
            }
            else {
                actionNotFound(action, newActions: newActions)
            }
            break
        case ActionType.addPasswordToFolder:
            let recordFolder = RecordingsManager.sharedInstance.getFolderByLinkedAction(action!.id)
            if recordFolder != nil {
                var hint = ""
                if let dict = action?.arg3, let passHint = dict["hint"] as? String {
                    hint = passHint
                }
                APIClient.sharedInstance.addPasswordToFolder((recordFolder?.id)!, pass:action!.arg2, hint: hint, completionHandler: { (success, data) -> Void in
                    self.moveToNextActionFrom(action, success: success, newActions: newActions)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
                })
            }
            else {
                actionNotFound(action, newActions: newActions)
            }
            break
        case ActionType.deleteFolder:
            APIClient.sharedInstance.deleteFolder(action!.arg1, moveTo:action!.arg2, completionHandler: { (success, data) -> Void in
                self.moveToNextActionFrom(action, success: success, newActions: newActions)
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
            })
            break
        case ActionType.reorderFolders:
            APIClient.sharedInstance.reorderFolders(action!.arg3 as! [String : Any], completionHandler: { (success, data) -> Void in
                if success || data as! String == "Nothing to Update" {
                    self.removeAction(action!.id)
                    self.saveActions()
                }
                else {
                    self.actionsFailed += 1
                }
                self.processActions(newActions)
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
            })
            break
        case ActionType.updateFileInfo:
            let recordItem = RecordingsManager.sharedInstance.getRecordingById(action!.arg1)
            if recordItem != nil {
                APIClient.sharedInstance.updateRecordingInfo(recordItem!, parameters: action!.arg3 as! [String : Any], completionHandler: { (success, data) -> Void in
                    self.moveToNextActionFrom(action, success: success, newActions: newActions)
                })
            }
            else {
                actionNotFound(action, newActions: newActions)
            }
            break
            
        case ActionType.buyCredits:
            APIClient.sharedInstance.buyCredits((action!.arg1 as NSString).integerValue, receipt:action!.arg2, completionHandler: { (success, data) -> Void in
                self.moveToNextActionFrom(action, success: success, newActions: newActions)
                self.processActions(newActions)
                
            })
            break
        case ActionType.custom:
            if delegate != nil {
                delegate.handle(action: action!, completionHandler: { (success, data) -> Void in
                    self.moveToNextActionFrom(action, success: success, newActions: newActions)
                })
            }
            break
        case ActionType.updateUserProfile:
            APIClient.sharedInstance.updateProfile(params: action!.arg3 as! [String : Any], completionHandler: { (success, data) -> Void in
                self.moveToNextActionFrom(action, success: success, newActions: newActions)
            })
            break
        case ActionType.starItem:
            APIClient.sharedInstance.star(action!.arg1 == "1", entityId: action!.arg3!["id"] as! String, isFile: action!.arg2 == "1", completionHandler: { (success, data) -> Void in
                self.moveToNextActionFrom(action, success: success, newActions: newActions)
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
            })
            break
        }
    }
    
    //MARK: actions manipulation
    func saveActions() {
        let data = NSKeyedArchiver.archivedData(withRootObject: actions)
        UserDefaults.standard.set(data, forKey: "actions")
    }
    
    func loadActions() {
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: "actions") as? Data {
            actions = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Action]
        }
    }
    
    func removeAction(_ id:String) {
        var index = 0
        for action in actions {
            if action.id == id {
                actions.remove(at: index)
                return
            }
            index += 1
        }
    }
    
    func getActionById(_ actionID:String) -> Action! {
        for action in actions {
            if action.id == actionID {
                return action
            }
        }
        return nil
    }
}

