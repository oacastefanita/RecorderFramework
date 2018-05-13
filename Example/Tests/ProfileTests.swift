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
        
        let promise = expectation(description: "Profile updated")
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
}
