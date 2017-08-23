
//
//  ActionsSyncManager.swift
//  Recorder
//
//  Created by Grif on 30/04/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation

public enum ActionType : Int {
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
}

public class Action : NSObject, NSCoding {
    
    public var id:String
    public var type:ActionType = ActionType.moveRecording
    public var arg1:String!
    public var arg2:String!
    public var arg3:NSMutableDictionary!
    
    public var timeStamp:TimeInterval!
    
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

public protocol CustomActionDelegate {
    func handle(action:Action, completionHandler:((Bool, AnyObject?) -> Void)?)
}


public class ActionsSyncManager : NSObject {
    public static let sharedInstance = ActionsSyncManager()

    public var actions = [Action]()
    public var syncInProgress = false
    public var actionsFailed:Int = 0
    public var currentController:UIViewController!
    
    var delegate:CustomActionDelegate!
    
    override public init() {
        super.init()
        AFNetworkReachabilityManager.shared().startMonitoring()
        
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status) -> Void in
            if status == AFNetworkReachabilityStatus.reachableViaWiFi || status == AFNetworkReachabilityStatus.reachableViaWWAN {
                self.startProcessingActions()
            }
        }
    }
    
    // MARK: credits
    public func buyCredits(_ credits:Int, reciept:String!) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.buyCredits
        action.arg1 = "\(credits)"
        action.arg2 = reciept
        actions.append(action)
        
        self.saveActions()
        self.startProcessingActions()
    }
    
    // MARK: folder actions
    public func createFolder(_ recordFolder:RecordFolder) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.createFolder
        action.arg1 = recordFolder.id
        actions.append(action)
        
        self.saveActions()
        self.startProcessingActions()
        
        AnaliticsManager.sharedInstance().addEvent(kAnaliticsEventTypeFolderCreated);
    }
    
    public func deleteFolder(_ recordFolder:RecordFolder, moveToFolder:String!) {
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
        actions.append(action)
        self.saveActions()
        self.startProcessingActions()
        
        AnaliticsManager.sharedInstance().addEvent(kAnaliticsEventTypeFolderDeleted);
    }
    
    public func renameFolder(_ recordFolder:RecordFolder) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.renameFolder
        action.arg1 = recordFolder.id
        action.arg2 = recordFolder.title
        actions.append(action)
        
        self.saveActions()
        self.startProcessingActions()
        
        AnaliticsManager.sharedInstance().addEvent(kAnaliticsEventTypeFolderRenamed);
    }


    // MARK: recordings actions
    public func deleteRecording(_ recordItem:RecordItem, forever:Bool) {
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
        
        actions.append(action)
        
        self.saveActions()
        self.startProcessingActions()
        
        AnaliticsManager.sharedInstance().addEvent(kAnaliticsEventTypeRecordItemDeleted);
    }
    
    public func deleteRecordings(_ recordItemIds:String, forever:Bool) {
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
        
        actions.append(action)
        
        self.saveActions()
        self.startProcessingActions()
        
        AnaliticsManager.sharedInstance().addEvent(kAnaliticsEventTypeRecordItemDeleted);
    }

    public func moveRecording(_ recordItem:RecordItem, folderId:String) {
        
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
        actions.append(action)
        
        self.saveActions()
        
        AnaliticsManager.sharedInstance().addEvent(kAnaliticsEventTypeRecordItemMoved);
    }
    
    public func recoverRecording(_ recordItem:RecordItem, folderId:String) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.recoverRecording
        action.arg1 = recordItem.id
        action.arg2 = folderId
        actions.append(action)
        
        self.saveActions()
        
        AnaliticsManager.sharedInstance().addEvent(kAnaliticsEventTypeRecordItemMoved);
    }
    
    public func renameRecording(_ recordItem:RecordItem) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.renameRecording
        action.arg1 = recordItem.id
        action.arg2 = recordItem.text
        actions.append(action)
        
        self.saveActions()
        self.startProcessingActions()
        
        AnaliticsManager.sharedInstance().addEvent(kAnaliticsEventTypeRecordItemRenamed);
    }
    
    public func uploadRecording(_ recordItem:RecordItem) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.uploadRecording
        action.arg1 = recordItem.id
        action.arg2 = recordItem.text
        actions.append(action)
        
        self.saveActions()
        self.startProcessingActions()
    }
    
    public func updateRecordingInfo(_ recordItem:RecordItem, fileInfo:NSMutableDictionary) {
        let action = Action()
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.updateFileInfo
        action.arg1 = recordItem.id
        action.arg3 = fileInfo;
        actions.append(action)
        
        self.saveActions()
        self.startProcessingActions()
        AnaliticsManager.sharedInstance().addEvent(kAnaliticsEventTypeFolderReorder);
    }

    
    public func reorderFolders(_ parameters:NSMutableDictionary) {
        let action = Action()
        action.arg1 = "-1"
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.reorderFolders
        action.arg3 = parameters
        actions.append(action)
        self.saveActions()
        self.startProcessingActions()
    }
    
    public func customAction(arg1:String, arg2:String, arg3:NSMutableDictionary) {
        let action = Action()
        action.arg1 = arg1
        action.arg2 = arg2
        action.arg3 = arg3
        action.timeStamp = Date().timeIntervalSince1970
        action.type = ActionType.custom
        actions.append(action)
        self.saveActions()
        self.startProcessingActions()
    }
    
    // MARK: processing
    
    public func startProcessingActions() {
        if AppPersistentData.sharedInstance.apiKey == nil {
            return
        }
//        var on = NSUserDefaults.standardUserDefaults().objectForKey("3GSync") as? Bool
//        if(on == nil){
//            on = false
//        }
//        if AFNetworkReachabilityManager.sharedManager().reachableViaWiFi || on! {
            if syncInProgress {
                return
            }
            actionsFailed = 0
            if self.actions.count > 0 {
                syncInProgress = true
                self.processActions(self.actions)
            }
//        }
    }
    
    public func processActions( _ workingActions:[Action] ) {
        if workingActions.count == 0 {
            syncInProgress = false
            self.saveActions()
//            if actionsFailed > 0 {
//                var message = (NSString(format: "%d action failed at last sync session", actionsFailed) as String).localized
//                if actionsFailed > 1 {
//                    message = (NSString(format: "%d actions failed at last sync session", actionsFailed) as String).localized
//                }
//                AlertController.showAlert(self.currentController, title: "Actions failed".localized, message: message, accept: "OK".localized, reject: nil)
//            }
            APIClient.sharedInstance.mainSync({ (success) -> Void in
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
            })
            return
        }
        
        let action = workingActions.first
        var newActions = workingActions
        newActions.remove(at: 0)
        
        switch(action!.type) {
        case ActionType.deleteRecording:

//            let recordItem = RecordingsManager.sharedInstance.getRecordingById(action!.arg1)
//            if recordItem != nil {
                APIClient.sharedInstance.deleteRecording(action!.arg1, removeForever:action!.arg2 == "true", completionHandler: { (success, data) -> Void in
                    if !success {
                        self.actionsFailed += 1
                    }
                    else {
                        self.removeAction(action!.id)
                        self.saveActions()
                    }
                    self.processActions(newActions)
                
                })
//            }
//            else {
//                self.removeAction(action!.id)
//                processActions(newActions)
//            }

            break
        case ActionType.moveRecording:
            
            let recordItem = RecordingsManager.sharedInstance.getRecordingById(action!.arg1)
            if recordItem != nil {
                APIClient.sharedInstance.moveRecording(recordItem!, folderId:action!.arg2, completionHandler: { (success, data) -> Void in
                    if !success {
                        self.actionsFailed += 1
                    }
                    else {
                        self.removeAction(action!.id)
                        self.saveActions()
                    }
                    self.processActions(newActions)
                })
            }
            else {
                self.removeAction(action!.id)
                processActions(newActions)
            }
            
            break
        case ActionType.recoverRecording:
            
            let recordItem = RecordingsManager.sharedInstance.getRecordingById(action!.arg1)
            if recordItem != nil {
                APIClient.sharedInstance.recoverRecording(recordItem!, folderId:action!.arg2, completionHandler: { (success, data) -> Void in
                    if !success {
                        self.actionsFailed += 1
                    }
                    else {
                        self.removeAction(action!.id)
                        self.saveActions()
                    }
                    self.processActions(newActions)
                })
            }
            else {
                self.removeAction(action!.id)
                processActions(newActions)
            }
            
            break
        case ActionType.renameRecording:
            
            let recordItem = RecordingsManager.sharedInstance.getRecordingById(action!.arg1)
            if recordItem != nil {
                APIClient.sharedInstance.renameRecording(recordItem!, name:action!.arg2, completionHandler: { (success, data) -> Void in
                    if !success {
                        self.actionsFailed += 1
                    }
                    else {
                        self.removeAction(action!.id)
                        self.saveActions()
                    }
                    self.processActions(newActions)
                })
            }
            else {
                self.removeAction(action!.id)
                processActions(newActions)
            }
            
            break
        case ActionType.uploadRecording:
            
            var on = UserDefaults.standard.object(forKey: "3GSync") as? Bool
            if(on == nil){
                on = true
            }
            if AFNetworkReachabilityManager.shared().isReachableViaWiFi || on! {
                let recordItem = RecordingsManager.sharedInstance.getRecordingById(action!.arg1)
                if recordItem != nil {
                    APIClient.sharedInstance.uploadRecording(recordItem!, completionHandler: { (success, data) -> Void in
                        if(success){
                            APIClient.sharedInstance.uploadMetadataFile(recordItem!, completionHandler: { (success, data) -> Void in
                                if !success {
                                    self.actionsFailed += 1
                                }
                                else {
                                    self.removeAction(action!.id)
                                    self.saveActions()
                                }
                                self.processActions(newActions)
                            })
                        } else{
                            self.actionsFailed += 1
                            self.processActions(newActions)
                        }
                    })
                }
                else {
                    self.removeAction(action!.id)
                    processActions(newActions)
                }
            }else {
                processActions(newActions)
            }
            
            break
        case ActionType.createFolder:
            let recordFolder = RecordingsManager.sharedInstance.getFolderByLinkedAction(action!.id)
            if recordFolder != nil {
                APIClient.sharedInstance.createFolder(recordFolder!.title! as NSString, localID:recordFolder!.id! as NSString, completionHandler: { (success, data) -> Void in
                    if success {
//                        var index = 0
//                        for recItem in RecordingsManager.sharedInstance.recordFolders {
//                            if recItem.linkedActionId != nil && recItem.linkedActionId == recordFolder.linkedActionId {
//                                RecordingsManager.sharedInstance.recordFolders.removeAtIndex(index)
//                                AppPersistentData.sharedInstance.saveData()
//                                break
//                            }
//                            index++
//                        }
                        self.removeAction(action!.id)
                        self.saveActions()
                    }
                    else {
                        self.actionsFailed += 1
                    }
                    self.processActions(newActions)
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
                })
            }
            else {
                self.removeAction(action!.id)
                processActions(newActions)
            }
            break
        case ActionType.renameFolder:
            let recordFolder = RecordingsManager.sharedInstance.getFolderByLinkedAction(action!.id)
            if recordFolder != nil {
                APIClient.sharedInstance.renameFolder((recordFolder?.id)!, name:action!.arg2, completionHandler: { (success, data) -> Void in
                    if success {
                        self.removeAction(action!.id)
                        self.saveActions()
                    }
                    else {
                        self.actionsFailed += 1
                    }
                    self.processActions(newActions)
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationRecordingsUpdated), object: nil)
                })
            }
            else {
                self.removeAction(action!.id)
                processActions(newActions)
            }
            break
        case ActionType.deleteFolder:
            APIClient.sharedInstance.deleteFolder(action!.arg1, moveTo:action!.arg2, completionHandler: { (success, data) -> Void in
                if success {
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
        case ActionType.reorderFolders:
            APIClient.sharedInstance.reorderFolders(action!.arg3, completionHandler: { (success, data) -> Void in
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
                APIClient.sharedInstance.updateRecordingInfo(recordItem!, parameters: action!.arg3, completionHandler: { (success, data) -> Void in
                    if !success {
                        self.actionsFailed += 1
                    }
                    else {
                        self.removeAction(action!.id)
                        self.saveActions()
                    }
                    self.processActions(newActions)
                })
            }
            else {
                self.removeAction(action!.id)
                processActions(newActions)
            }
            break
            
        case ActionType.buyCredits:
            APIClient.sharedInstance.buyCredits((action!.arg1 as NSString).integerValue, receipt:action!.arg2, completionHandler: { (success, data) -> Void in
                if success {
                    self.removeAction(action!.id)
                    self.saveActions()
                }
                else {
                    self.actionsFailed += 1
                }
                self.processActions(newActions)
                
            })
            break
        case ActionType.custom:
            if delegate != nil {
                delegate.handle(action: action!, completionHandler: { (success, data) -> Void in
                    if success {
                        self.removeAction(action!.id)
                        self.saveActions()
                    }
                    else {
                        self.actionsFailed += 1
                    }
                    self.processActions(newActions)
                })
            }
            break
        }
    }
    
    public func removeAction(_ id:String) {
        var index = 0
        for action in actions {
            if action.id == id {
                actions.remove(at: index)
                return
            }
            index += 1
        }
    }
    
    
    public func saveActions() {
        let data = NSKeyedArchiver.archivedData(withRootObject: actions)
        UserDefaults.standard.set(data, forKey: "actions")
    }
    
    public func loadActions() {
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: "actions") as? Data {
            actions = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Action]
        }
    }
    
    // MARK: helpers
    
    public func getActionById(_ actionID:String) -> Action! {
        for action in actions {
            if action.id == actionID {
                return action
            }
        }
        return nil
    }
}
