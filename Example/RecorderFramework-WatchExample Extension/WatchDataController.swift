//
//  WatchDataController.swift
//  RecorderFramework-WatchExample Extension
//
//  Created by Stefanita Oaca on 31/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import WatchConnectivity
import RecorderFramework
import CoreData

@available(iOS 9.0, *)
//var alertDelegate:HomeIC? = nil

public class WatchData: NSObject,WCSessionDelegate {
    var session = WCSession.default
    
    public static let sharedInstance = WatchData()
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?){
     
    }

    @available(watchOS 2.0, *)
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]){
        if let user = applicationContext["user"] {
            RecorderFrameworkManager.sharedInstance.setUser(RecorderFrameworkManager.sharedInstance.createUserFromDict(user as! NSDictionary))
        }
        if let key = applicationContext["api_key"] {
            RecorderFrameworkManager.sharedInstance.setApiKey(key as! String)
        }
        if let folders = applicationContext["folders"]{
            var foldersArray = Array<RecordFolder>()
            for folder in (folders as! Array<NSDictionary>){
                foldersArray.append(RecorderFrameworkManager.sharedInstance.createRecordFolderFromDict(folder))
            }
            RecorderFrameworkManager.sharedInstance.setFolders(foldersArray)
        }
        RecorderFrameworkManager.sharedInstance.saveData()
    }

    @available(watchOS 2.0, *)
    public func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?){
        
    }

    @available(watchOS 2.0, *)
    public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]){
        
    }

    @available(watchOS 2.0, *)
    public func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?){
        
    }

    @available(watchOS 2.0, *)
    public func session(_ session: WCSession, didReceive file: WCSessionFile){
        
    }
    
    public func activate(){
        if WCSession.isSupported() {    //  it is supported
            session = WCSession.default
            session.delegate = self
            session.activate()
            print("watch activating WCSession")
        } else {
            
            print("watch does not support WCSession")
        }
        
        if(!session.isReachable){
            print("not reachable")
            return
        }else{
            print("watch is reachable")
            
        }
    }
}
