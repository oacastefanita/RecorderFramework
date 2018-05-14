//
//  RegisterTests.swift
//  RecorderFramework_Tests
//
//  Created by Stefanita Oaca on 14/05/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import RecorderFramework

class RegisterTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test1Register() {
        let promise = expectation(description: "Register flow")
        
        RecorderFrameworkManager.sharedInstance.register("+40727272727", completionHandler: { (success, data) -> Void in
            if success {
                RecorderFrameworkManager.sharedInstance.sendVerificationCode(data as! String, completionHandler: { (success, data) -> Void in
                    if success {
                        if ((data as! [String:Any])["phone"] as! String) == "+40727272727"{
                            promise.fulfill()
                        }else{
                            XCTFail("Error: \(data)")
                        }
                    }
                    else {
                        XCTFail("Error: \(data)")
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
