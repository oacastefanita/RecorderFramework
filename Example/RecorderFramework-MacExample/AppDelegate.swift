//
//  AppDelegate.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 09/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        RecorderFrameworkManager.sharedInstance.containerName = "group.com.codebluestudio.Recorder"
        NSApp.registerForRemoteNotifications(matching: .alert)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var newToken: String = ""
        for i in 0..<deviceToken.count {
            newToken += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        RecorderFrameworkManager.sharedInstance.pushToken = newToken
    }
    
    func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
        
    }

}

