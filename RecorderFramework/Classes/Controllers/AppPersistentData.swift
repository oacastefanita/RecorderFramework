//
//  AppPersistenceData.swift
//  Recorder
//
//  Created by Grif on 08/05/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation


class AppPersistentData : NSObject {
    @objc static let sharedInstance = AppPersistentData()
    
    @objc var phone:String!
    @objc var apiKey:String!
    @objc var verificationCode:String! //for testing
    @objc var notificationToken:String!
    @objc var invalidAPIKey = false
    
    // settings
    @objc var user:User! = User()
    @objc var passOn = false
    @objc var filePermission:String!
    public var credits:Int!
    @objc var app:String!
    
    @objc var phoneNumbers:Array<PhoneNumber>
    @objc var serverMessages:Array<ServerMessage>
    
    @objc var justReseted = false
    @objc var free = false
    
    // settings
    @objc var receivedNotification = false
    @objc var messageID:String!
    
    override init() {
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
    
    @objc func saveData() {
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
        
        if user != nil{
            defaults.setValue(NSKeyedArchiver.archivedData(withRootObject: user),  forKey: "user")
        }
        
        defaults.set(passOn , forKey: "passwordpref");
        
        defaults.synchronize()
    }
    
    func loadData() {
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
        checkDefaultFolders()
        
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
    }
    
    func checkDefaultFolders(){
        if RecordingsManager.sharedInstance.recordFolders.count == 0 {
            let folder = RecordFolder()
            folder.title = "New Call Recordings".localized
            folder.id = "0"
            RecordingsManager.sharedInstance.recordFolders.append(folder)
            
            let allFilesfolder = RecordFolder()
            allFilesfolder.title = "All Files".localized
            allFilesfolder.id = "-99"
            RecordingsManager.sharedInstance.recordFolders.append(allFilesfolder)
        }
    }
    
    func registered() -> Bool {
        return !(AppPersistentData.sharedInstance.phone == nil || AppPersistentData.sharedInstance.phone.isEmpty)
    }
    
    func verified() -> Bool {
        return !(AppPersistentData.sharedInstance.apiKey == nil || AppPersistentData.sharedInstance.apiKey.isEmpty)
    }
}

