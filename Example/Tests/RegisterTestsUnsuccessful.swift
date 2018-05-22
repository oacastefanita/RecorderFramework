//
//  RegisterTestsUnsuccessful.swift
//  RecorderFramework_Tests
//
//  Created by Stefanita Oaca on 14/05/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import RecorderFramework

class RegisterTestsUnsuccessful: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test1RegisterWrongNumber() {
        let promise = expectation(description: "Register wrong phone")
        
        RecorderFrameworkManager.sharedInstance.register("1234567890", completionHandler: { (success, data) -> Void in
            if success {
                XCTFail("Error: phone numbers is invalid, server should not accept it")
            }
            else {
                if( (data as! String) == "Please enter valid Phone Number , alongwith country code"){
                    promise.fulfill()
                }
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test1RegisterWrongCode() {
        let promise = expectation(description: "Register wrong phone")
        
        RecorderFrameworkManager.sharedInstance.register("+40727272727", completionHandler: { (success, data) -> Void in
            if success {
                RecorderFrameworkManager.sharedInstance.sendVerificationCode("1234", completionHandler: { (success, data) -> Void in
                    if success {
                        XCTFail("Error: Code is invalid, server should not accept it")
                    }
                    else {
                        if( (data as! String) == "Invalid Code"){
                            promise.fulfill()
                        }
                    }
                })
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
}
