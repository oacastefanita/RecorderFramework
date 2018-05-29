//
//  ProfileTests.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 13/05/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import RecorderFramework

class ProfileTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test1ProfileUpdate() {
        let params = NSMutableDictionary()
        params["data[play_beep]"] = "1"
        params["data[f_name]"] = "Unit test first name"
        params["data[l_name]"] = "Unit test Last name"
        params["data[is_public]"] = "1"
        params["data[time_zone]"] = "60"
        params["data[email]"] = "unit@test.com"
        
        let promise = expectation(description: "Update profile")
        APIClient.sharedInstance.updateProfile(params: params as! [String : Any], completionHandler: { (success, data) -> Void in
            if success{
                RecorderFrameworkManager.sharedInstance.getProfile({ (success, data) -> Void in
                    if success {
                        var error = false
                        if let profile = (data as! [String : Any])["profile"] as? [String : Any]{
                            error = "\(profile["email"])" == "unit@test.com" && "\(profile["time_zone"])" == "60" && "\(profile["is_public"])" == "1" && "\(profile["l_name"])" == "Unit test Last name" && "\(profile["f_name"])" == "Unit test first name" && "\(profile["play_beep"])" == "1"
                        }else{
                            XCTFail("Error: \(data)")
                        }
                        if error{
                            XCTFail("Error: \(data)")
                        }else{
                            promise.fulfill()
                        }
                    }else {
                        XCTFail("Error: \(data)")
                    }
                })
            }else{
                XCTFail("Error: \(data)")
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test2GetLanguages() {
        let promise = expectation(description: "Get languages and translations")
        RecorderFrameworkManager.sharedInstance.getLanguages({(success, data) -> Void in
            if success{
                if let array = data as? Array<Language>{
                    let expectedTranslations = array.count
                    var successfulTranslations = 0
                    for language in array{
                        RecorderFrameworkManager.sharedInstance.getTranslations(language.code, completionHandler:{(success, data) -> Void in
                            if success{
                                successfulTranslations = successfulTranslations + 1
                                if successfulTranslations == expectedTranslations{
                                    promise.fulfill()
                                }
                            }else{
                                XCTFail("Error: \(data)")
                            }
                        })
                    }
                }
            }else{
                XCTFail("Error: \(data)")
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test3GetPhoneNumbers() {
        let promise = expectation(description: "Get profile numbers")
        RecorderFrameworkManager.sharedInstance.getPhoneNumbers({(success, data) -> Void in
            if success{
                promise.fulfill()
            }else{
                XCTFail("Error: \(data)")
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test4Settings() {
        let promise = expectation(description: "Update settings")
        RecorderFrameworkManager.sharedInstance.updateSettings(true, completionHandler: { (success, data) -> Void in
            if success {
                RecorderFrameworkManager.sharedInstance.getSettings({ (success, data) -> Void in
                    if success {
                        if let dict = data as? NSDictionary{
                            if let value:String = dict.object(forKey: "play_beep") as? String {
                                if value != "no"{
                                    promise.fulfill()
                                }
                            }
                        }
                    }
                    else {
                        XCTFail("Error: \(data)")
                    }
                })
            }
            else {
                
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test5UpdateToken() {
        let promise = expectation(description: "Update token")
        RecorderFrameworkManager.sharedInstance.updateToken("NewTokenForUnitTest",completionHandler:{(success, data) -> Void in
            if success{
                promise.fulfill()
            }else{
                XCTFail("Error: \(data)")
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
}
