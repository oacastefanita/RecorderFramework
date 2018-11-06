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

class ProfileTestsUnsucessfull: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test1ProfileUpdateWrongEmailFormat() {
        let params = NSMutableDictionary()
        params["data[play_beep]"] = "1"
        params["data[f_name]"] = "Unit test first name"
        params["data[l_name]"] = "Unit test Last name"
        params["data[is_public]"] = "1"
        params["data[time_zone]"] = "60"
        params["data[email]"] = "fakeEmail"//wrong
        
        let promise = expectation(description: "Profile update fail")
        APIClient.sharedInstance.updateProfile(params: params as! [String : Any], completionHandler: { (success, data) -> Void in
            if success {
                 XCTFail("Error: Email is invalid, server should not accept it")
            }else {
                promise.fulfill()
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test2ProfileUpdateEmptyFirstName() {
        let params = NSMutableDictionary()
        params["data[play_beep]"] = "1"
        params["data[f_name]"] = ""//empty
        params["data[l_name]"] = "Unit test Last name"
        params["data[is_public]"] = "1"
        params["data[time_zone]"] = "60"
        params["data[email]"] = "unitTest@email.com"
        
        let promise = expectation(description: "Profile update fail")
        APIClient.sharedInstance.updateProfile(params: params as! [String : Any], completionHandler: { (success, data) -> Void in
            if success {
                XCTFail("Error: First name is invalid, server should not accept it")
            }else {
                promise.fulfill()
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test3ProfileUpdateEmptyLastName() {
        let params = NSMutableDictionary()
        params["data[play_beep]"] = "1"
        params["data[f_name]"] = "Unit test First name"
        params["data[l_name]"] = ""//empty
        params["data[is_public]"] = "1"
        params["data[time_zone]"] = "60"
        params["data[email]"] = "unitTest@email.com"
        
        let promise = expectation(description: "Profile not updated")
        APIClient.sharedInstance.updateProfile(params: params as! [String : Any], completionHandler: { (success, data) -> Void in
            if success {
                XCTFail("Error: Last name is invalid, server should not accept it")
            }else {
                promise.fulfill()
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test4UpdateEmptyToken() {
        let promise = expectation(description: "Update token fail")
        //empty token
        RecorderFrameworkManager.sharedInstance.updateToken("",completionHandler:{(success, data) -> Void in
            if success{
                XCTFail("Error: Token is invalid, server should not accept it")
            }else{
                promise.fulfill()
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test5GetTranslationsEmptyLanguage(){
        let promise = expectation(description: "Get translation fail")
        //empty language
        RecorderFrameworkManager.sharedInstance.getTranslations("", completionHandler:{(success, data) -> Void in
            if success{
                XCTFail("Error: Id is invalid, server should not accept it")
            }else{
                promise.fulfill()
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test6BuyCreditsWrongReceipt(){
        let promise = expectation(description: "Buy credits fail")
        //empty receipt
        var parameters:[String:Any] = ["app":"rec", "reciept" : ""] as [String : Any]
        parameters[ServerReuqestKeys.apiKey.rawValue] = AppPersistentData.sharedInstance.apiKey!
        APIClient.sharedInstance.buyCredits(parameters, completionHandler:{(success, data) -> Void in
            if success{
                XCTFail("Error: Receipt is invalid, server should not accept it")
            }else{
                promise.fulfill()
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test7UpdateTokenEmptyType() {
        let promise = expectation(description: "Update token fail")
        let parameters:[String:Any] = [ServerReuqestKeys.apiKey.rawValue: AppPersistentData.sharedInstance.apiKey!, "device_token" : "23432432sdfsdf4dsfsdfdsfsd ", "device_type" : ""]//empty device_type
        APIClient.sharedInstance.updateToken(parameters,completionHandler:{(success, data) -> Void in
            if success{
                XCTFail("Error: Token is invalid, server should not accept it")
            }else{
                promise.fulfill()
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
}
