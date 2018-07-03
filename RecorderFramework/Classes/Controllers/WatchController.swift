//
//  WatchController.swift
//  Pods
//
//  Created by Stefanita Oaca on 15/09/2017.
//
//

#if os(watchOS) || os(iOS)
import WatchConnectivity
import CoreData
import RecorderFramework

class WatchKitController: NSObject, WCSessionDelegate{
    
    /// Singleton
    static let sharedInstance = WatchKitController()
    
    /// Current watchkit session
    var session : WCSession?
    
    /// Context to be sent, every new context sent replaces the old one
    var context = [String:Any]()
    
    override init() {
        super.init()
        self.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?)
    {
        
    }
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]){
        if let user = applicationContext["user"] {
            RecorderFrameworkManager.sharedInstance.setUser(RecorderFrameworkManager.sharedInstance.createUserFromDict(user as! NSDictionary))
        }
        if let key = applicationContext["api_key"] {
            RecorderFrameworkManager.sharedInstance.setApiKey(key as! String)
        }
        if let phone = applicationContext["phone"] {
            RecorderFrameworkManager.sharedInstance.setDefaultPhone(phone as! String)
        }
        if let folders = applicationContext["folders"]{
            var foldersArray = Array<RecordFolder>()
            for folder in (folders as! Array<NSDictionary>){
                foldersArray.append(RecorderFrameworkManager.sharedInstance.createRecordFolderFromDict(folder))
            }
            RecorderFrameworkManager.sharedInstance.setFolders(foldersArray)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationContextUpdated), object: nil)
        RecorderFrameworkManager.sharedInstance.saveData()
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif

    /// Activate the watch session
    func activate(){
        if WCSession.isSupported() {    //  it is supported
            session = WCSession.default
            session!.delegate = self
            session!.activate()
            print("watch activating WCSession")
        } else {
            
            print("watch does not support WCSession")
        }
        if session != nil{
            if(!session!.isReachable){
                print("not reachable")
                return
            }else{
                print("watch is reachable")
                
            }
        }
    }
    
    /// Check if the session is active
    ///
    /// - Returns: true if current session is active
    func sessionActive() -> Bool{
        if !WCSession.isSupported(){
            return false
        }
        if session == nil{
            return false
        }
        
        return true
    }

    /// Add all folders to the context and send the new context
    func sendFolders(){
        if !sessionActive(){
            return
        }
        var array = Array<NSDictionary>()
        for folder  in RecordingsManager.sharedInstance.recordFolders{
            array.append(RecorderFactory.createDictFromRecordFolder(folder))
        }
        
        context["folders"] = array
        do {
            try session?.updateApplicationContext(
                context
            )
        } catch let error as NSError {
            NSLog("Updating the context failed: " + error.localizedDescription)
        }
    }
    
    func sendApiKey(){
        if !sessionActive(){
            return
        }
        
        context["api_key"] = AppPersistentData.sharedInstance.apiKey
        do {
            try session?.updateApplicationContext(
                context
            )
        } catch let error as NSError {
            NSLog("Updating the context failed: " + error.localizedDescription)
        }
    }
    
    /// Add user to the context and send the new context
    func sendUser(){
        if !sessionActive(){
            return
        }
        context["user"] = RecorderFactory.createDictFromUser(AppPersistentData.sharedInstance.user)
        do {
            try session?.updateApplicationContext(
                context
            )
        } catch let error as NSError {
            NSLog("Updating the context failed: " + error.localizedDescription)
        }
    }
    
    /// Add default phone to the context and send the new context
    func sendPhone(){
        if !sessionActive(){
            return
        }
        for phoneNumber in AppPersistentData.sharedInstance.phoneNumbers{
            if phoneNumber.isDefault{
                context["phone"] = phoneNumber.phoneNumber
                break
            }
        }
        do {
            try session?.updateApplicationContext(
                context
            )
        } catch let error as NSError {
            NSLog("Updating the context failed: " + error.localizedDescription)
        }
    }
}
#endif
