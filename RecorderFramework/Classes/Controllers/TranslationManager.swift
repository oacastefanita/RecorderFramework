//
//  TranslationManager.swift
//  Recorder
//
//  Created by Adelina on 7/8/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation

class TranslationManager : NSObject  {
    public static let sharedInstance = TranslationManager()
    
    var languages:Array<Language>
    var translations:NSDictionary
    var currentLanguage:String!
    
    override init() {
        self.translations = NSDictionary()
        self.languages = Array()
        
        super.init()
        
        loadData()
    }
    
    func saveData() {
        let defaults = UserDefaults.standard
        
        defaults.set(translations, forKey: "translations");
        
        if(currentLanguage != nil){
            defaults.setValue(currentLanguage, forKey: "currentLanguage");
        }

        defaults.synchronize()
    }
    
    func loadData() {
        let defaults = UserDefaults.standard
        
        if let value:NSDictionary = defaults.value(forKey: "translations") as? NSDictionary {
            translations = value
        }
        
        if let value:String = defaults.value(forKey: "currentLanguage") as? String {
            currentLanguage = value
        } else {
            currentLanguage = "en_US"
        }

    }

}
