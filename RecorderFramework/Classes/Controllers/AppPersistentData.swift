//
//  AppPersistenceData.swift
//  Recorder
//
//  Created by Grif on 08/05/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation


public class AppPersistentData : NSObject {
    
    public static let sharedInstance = AppPersistentData()
    
    public var phone:String!
    public var apiKey:String!
    public var verificationCode:String! //for testing
    public var notificationToken:String!
    public var invalidAPIKey = false
    
    // settings
    public var user:User! = User()
    public var passOn = false
    public var filePermission:String!
    public var credits:Int!
    public var app:String!
    
    public var phoneNumbers:Array<PhoneNumber>
    public var serverMessages:Array<ServerMessage>
    
    public var justReseted = false
    public var free = false
    
    // settings
    public var receivedNotification = false
    public var messageID:String!
    
    override public init() {
        phoneNumbers = Array<PhoneNumber>()
        serverMessages = Array<ServerMessage>()
        super.init()
        
        //manual storage
        let manualOn = UserDefaults.standard.object(forKey: "localStorageManualOn") as? String
        if manualOn == nil{
            UserDefaults.standard.set("false", forKey: "localStorageManualOn")
            UserDefaults.standard.synchronize()
        }
        
        //days storage
        let numberOfDaysOn = UserDefaults.standard.object(forKey: "localStorageDaysOn") as? String
        if numberOfDaysOn == nil{
            UserDefaults.standard.set("true", forKey: "localStorageDaysOn")
            UserDefaults.standard.synchronize()
        }
        
        let numberOfDays = UserDefaults.standard.integer(forKey: "localStorageDays")
        if numberOfDays == 0{
            UserDefaults.standard.set(5, forKey: "localStorageDays")
            UserDefaults.standard.synchronize()
        }
        
        //max storage size
        let numberOfMBOn = UserDefaults.standard.object(forKey: "localStorageMaxSizeOn") as? String
        if numberOfMBOn == nil{
            UserDefaults.standard.set("true", forKey: "localStorageMaxSizeOn")
            UserDefaults.standard.synchronize()
        }
        
        let numberOfMB = UserDefaults.standard.integer(forKey: "localStorageMaxSize")
        if numberOfMB == 0{
            UserDefaults.standard.set(10, forKey: "localStorageMaxSize")
            UserDefaults.standard.synchronize()
        }
    }

    public func saveData() {
        let defaults = UserDefaults.standard
        
        if(phone != nil){
            defaults.setValue(phone.aesEncrypt(), forKey: "phone");
        }
        if(apiKey != nil){
            defaults.setValue(apiKey.aesEncrypt(), forKey: "api_key");
        }
        
        defaults.setValue(invalidAPIKey, forKey: "invalid_api_key");
        
        if(notificationToken != nil){
            defaults.setValue(notificationToken.aesEncrypt(), forKey: "notificationToken");
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: RecordingsManager.sharedInstance.recordFolders)
        defaults.set(data, forKey: "recordFolders")
        
        let languagesData = NSKeyedArchiver.archivedData(withRootObject: TranslationManager.sharedInstance.languages)
        defaults.set(languagesData, forKey: "languages")
        
        let translationsData = NSKeyedArchiver.archivedData(withRootObject: TranslationManager.sharedInstance.translations)
        defaults.set(translationsData, forKey: "translations")
        
        let numbersData = NSKeyedArchiver.archivedData(withRootObject: phoneNumbers)
        defaults.set(numbersData, forKey: "phoneNumbers")
        
        let serverMessagesData = NSKeyedArchiver.archivedData(withRootObject: serverMessages)
        defaults.set(serverMessagesData, forKey: "serverMessages")
        
        defaults.setValue(NSKeyedArchiver.archivedData(withRootObject: user),  forKey: "user");
        defaults.set(passOn , forKey: "passwordpref");
        
        defaults.synchronize()
    }
    
    public func loadData() {
        let defaults = UserDefaults.standard
        
        if let value:String = defaults.value(forKey: "phone") as? String {
            phone = value.aesDecrypt()
        }
        
        if let value:String = defaults.value(forKey: "api_key") as? String {
            apiKey = value.aesDecrypt()
        }
        
        invalidAPIKey = defaults.bool(forKey: "invalid_api_key")
        
        if let value:String = defaults.value(forKey: "notificationToken") as? String {
            notificationToken = value.aesDecrypt()
        }
        
        if let data = defaults.object(forKey: "recordFolders") as? Data {
            RecordingsManager.sharedInstance.recordFolders = NSKeyedUnarchiver.unarchiveObject(with: data) as! Array<RecordFolder>
        }
        
        if let data = defaults.object(forKey: "translations") as? Data {
            TranslationManager.sharedInstance.translations = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
        }
        
        if let data = defaults.object(forKey: "languages") as? Data {
            TranslationManager.sharedInstance.languages = NSKeyedUnarchiver.unarchiveObject(with: data) as! Array<Language>
        }
        
        if let data = defaults.object(forKey: "phoneNumbers") as? Data {
            phoneNumbers = NSKeyedUnarchiver.unarchiveObject(with: data) as! Array<PhoneNumber>
        }
        
        if let data = defaults.object(forKey: "serverMessages") as? Data {
            serverMessages = NSKeyedUnarchiver.unarchiveObject(with: data) as! Array<ServerMessage>
        }
        
        if let data = defaults.value(forKey: "user") as? Data {
            user = NSKeyedUnarchiver.unarchiveObject(with: data) as! User
        }
        
        passOn = defaults.bool(forKey: "passwordpref")
        
        free = false
        #if CRFREE
            free = true
        #endif
    }
    
    public func registered() -> Bool {
        return !(AppPersistentData.sharedInstance.phone == nil || AppPersistentData.sharedInstance.phone.isEmpty)
    }
    
    public func verified() -> Bool {
        return !(AppPersistentData.sharedInstance.apiKey == nil || AppPersistentData.sharedInstance.apiKey.isEmpty)
    }
}
