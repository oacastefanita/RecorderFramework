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
        params["data[email]"] = "fakeEmail"
        
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
        params["data[f_name]"] = ""
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
        params["data[l_name]"] = ""
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
    
    func test4AddEmptyTitleMessage() {
        let promise = expectation(description: "Add message fail")
        RecorderFrameworkManager.sharedInstance.addMessage("NewTokenForUnitTest",title:"",message:"UnitTestBody",completionHandler:{(success, data) -> Void in
            if success {
                XCTFail("Error: Title is invalid, server should not accept it")
            }else {
                promise.fulfill()
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test5AddEmptyBodyMessage() {
        let promise = expectation(description: "Add message fail")
        RecorderFrameworkManager.sharedInstance.addMessage("NewTokenForUnitTest",title:"UnitTestTitle",message:"",completionHandler:{(success, data) -> Void in
            if success {
                XCTFail("Error: Body is invalid, server should not accept it")
            }else {
                promise.fulfill()
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test6AddEmptyTokenMessage() {
        let promise = expectation(description: "Add message fail")
        RecorderFrameworkManager.sharedInstance.addMessage("",title:"UnitTestTitle",message:"UnitTestMessage",completionHandler:{(success, data) -> Void in
            if success {
                XCTFail("Error: Token is invalid, server should not accept it")
            }else {
                promise.fulfill()
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test7UpdateToken() {
        let promise = expectation(description: "Update token fail")
        RecorderFrameworkManager.sharedInstance.updateToken("",completionHandler:{(success, data) -> Void in
            if success{
                XCTFail("Error: Token is invalid, server should not accept it")
            }else{
                promise.fulfill()
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test8GetTranslations(){
        let promise = expectation(description: "Get translation fail")
        RecorderFrameworkManager.sharedInstance.getTranslations("", completionHandler:{(success, data) -> Void in
            if success{
                XCTFail("Error: Id is invalid, server should not accept it")
            }else{
                promise.fulfill()
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
}
