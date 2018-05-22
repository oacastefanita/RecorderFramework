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
    
    func test1ProfileUpdate() {
        let params = NSMutableDictionary()
        params["data[play_beep]"] = "1"
        params["data[f_name]"] = "Unit test first name"
        params["data[l_name]"] = "Unit test Last name"
        params["data[is_public]"] = "1"
        params["data[time_zone]"] = "60"
        params["data[email]"] = "fakeEmail"
        
        let promise = expectation(description: "Profile not updated")
        APIClient.sharedInstance.updateProfile(params: params as! [String : Any], completionHandler: { (success, data) -> Void in
            if success{
                RecorderFrameworkManager.sharedInstance.getProfile({ (success, data) -> Void in
                    if success {
                        XCTFail("Error: \(data)")
                    }else {
                        promise.fulfill()
                    }
                })
            }else{
                XCTFail("Error: \(data)")
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    
    
    func test5AddMessage() {
        let promise = expectation(description: "Add Message")
        RecorderFrameworkManager.sharedInstance.addMessage("Taskdaskljd as3290ru48f3u4estTOken",title:"",message:"UnitTestBody",completionHandler:{(success, data) -> Void in
            if success{
            }else{
                XCTFail("Error: \(data)")
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
}
