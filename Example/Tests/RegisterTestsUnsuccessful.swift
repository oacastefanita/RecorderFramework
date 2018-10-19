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
    
    func test01RegisterWrongNumber() {
        let promise = expectation(description: "Register phone fail")
        //wrong phone
        RecorderFrameworkManager.sharedInstance.register("1234567890", completionHandler: { (success, data) -> Void in
            if success {
                XCTFail("Error: Phone number is invalid, server should not accept it")
            }
            else {
                if( (data as! String) == "Please enter valid Phone Number , alongwith country code"){
                    promise.fulfill()
                }
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test02RegisterWrongCode() {
        let promise = expectation(description: "Register send code fail")
        
        RecorderFrameworkManager.sharedInstance.register("+40727272727", completionHandler: { (success, data) -> Void in
            if success {
               //wrong registration code
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
    
    func test03RegisterWrongToken() {
        let promise = expectation(description: "Register phone fail")
        //empty token
        APIClient.sharedInstance.register("1234567890", token:"", completionHandler: { (success, data) -> Void in
            if success {
                XCTFail("Error: Phone number is invalid, server should not accept it")
            }
            else {
                if( (data as! String) == "invalid token"){
                    promise.fulfill()
                }
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test04RegisterWrongPhone(){
        let promise = expectation(description: "Send code fail")
        RecorderFrameworkManager.sharedInstance.register("+40727272727", completionHandler: { (success, data) -> Void in
            if success {
               var code = data as! String
                var appCode = "rec"
                if RecorderFrameworkManager.sharedInstance.isRecorder{
                    appCode = "rem"
                }
                
                let deviceToken =  AppPersistentData.sharedInstance.notificationToken == nil ? "Simulator" : AppPersistentData.sharedInstance.notificationToken!
                //wrong phone
                var parameters = ["phone": "987654321","mcc":"300" ,"code": code, "token": "55942ee3894f51000530894", "app": appCode, "device_token":deviceToken] as [String : Any]
                
                #if os(iOS)
                var mcc = "300"
                parameters["mcc"] = mcc
                parameters["device_type"] = "ios"
                #elseif os(OSX)
                parameters["device_type"] = "mac"
                parameters["device_id"] = RecorderFrameworkManager.sharedInstance.macSN
                #endif
                parameters["time_zone"] = TimeZone.current.secondsFromGMT() / 60
                
                APIClient.sharedInstance.sendVerificationCode(parameters:parameters, completionHandler: { (success, data) -> Void in
                    if success {
                        XCTFail("Error: Code is invalid, server should not accept it")
                    } else {
                        promise.fulfill()
                    }
                })
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test05RegisterEmptyPhone(){
        let promise = expectation(description: "Send code fail")
        RecorderFrameworkManager.sharedInstance.register("+40727272727", completionHandler: { (success, data) -> Void in
            if success {
                var code = data as! String
                var appCode = "rec"
                if RecorderFrameworkManager.sharedInstance.isRecorder{
                    appCode = "rem"
                }
                
                let deviceToken =  AppPersistentData.sharedInstance.notificationToken == nil ? "Simulator" : AppPersistentData.sharedInstance.notificationToken!
                //empty phone
                var parameters = ["phone": "","mcc":"300" ,"code": code, "token": "55942ee3894f51000530894", "app": appCode, "device_token":deviceToken] as [String : Any]
                
                #if os(iOS)
                var mcc = "300"
                parameters["mcc"] = mcc
                parameters["device_type"] = "ios"
                #elseif os(OSX)
                parameters["device_type"] = "mac"
                parameters["device_id"] = RecorderFrameworkManager.sharedInstance.macSN
                #endif
                parameters["time_zone"] = TimeZone.current.secondsFromGMT() / 60
                
                APIClient.sharedInstance.sendVerificationCode(parameters:parameters, completionHandler: { (success, data) -> Void in
                    if success {
                        XCTFail("Error: Code is invalid, server should not accept it")
                    } else {
                        promise.fulfill()
                    }
                })
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test06RegisterEmptyToken(){
        let promise = expectation(description: "Send code fail")
        RecorderFrameworkManager.sharedInstance.register("+40727272727", completionHandler: { (success, data) -> Void in
            if success {
                var code = data as! String
                var appCode = "rec"
                if RecorderFrameworkManager.sharedInstance.isRecorder{
                    appCode = "rem"
                }
                
                let deviceToken =  AppPersistentData.sharedInstance.notificationToken == nil ? "Simulator" : AppPersistentData.sharedInstance.notificationToken!
                //empty token
                var parameters = ["phone": AppPersistentData.sharedInstance.phone!,"mcc":"300" ,"code": code, "token": "", "app": appCode, "device_token":deviceToken] as [String : Any]
                
                #if os(iOS)
                var mcc = "300"
                parameters["mcc"] = mcc
                parameters["device_type"] = "ios"
                #elseif os(OSX)
                parameters["device_type"] = "mac"
                parameters["device_id"] = RecorderFrameworkManager.sharedInstance.macSN
                #endif
                parameters["time_zone"] = TimeZone.current.secondsFromGMT() / 60
                
                APIClient.sharedInstance.sendVerificationCode(parameters:parameters, completionHandler: { (success, data) -> Void in
                    if success {
                        XCTFail("Error: Code is invalid, server should not accept it")
                    } else {
                        promise.fulfill()
                    }
                })
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test07RegisterWrongToken(){
        let promise = expectation(description: "Send code fail")
        RecorderFrameworkManager.sharedInstance.register("+40727272727", completionHandler: { (success, data) -> Void in
            if success {
                var code = data as! String
                var appCode = "rec"
                if RecorderFrameworkManager.sharedInstance.isRecorder{
                    appCode = "rem"
                }
                
                let deviceToken =  AppPersistentData.sharedInstance.notificationToken == nil ? "Simulator" : AppPersistentData.sharedInstance.notificationToken!
                //wrong token
                var parameters = ["phone": AppPersistentData.sharedInstance.phone!,"mcc":"300" ,"code": code, "token": "559 asd42ee3894f5100 as0530894", "app": appCode, "device_token":deviceToken] as [String : Any]
                
                #if os(iOS)
                var mcc = "300"
                parameters["mcc"] = mcc
                parameters["device_type"] = "ios"
                #elseif os(OSX)
                parameters["device_type"] = "mac"
                parameters["device_id"] = RecorderFrameworkManager.sharedInstance.macSN
                #endif
                parameters["time_zone"] = TimeZone.current.secondsFromGMT() / 60
                
                APIClient.sharedInstance.sendVerificationCode(parameters:parameters, completionHandler: { (success, data) -> Void in
                    if success {
                        XCTFail("Error: Code is invalid, server should not accept it")
                    } else {
                        promise.fulfill()
                    }
                })
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test08RegisterWrongApp(){
        let promise = expectation(description: "Send code fail")
        RecorderFrameworkManager.sharedInstance.register("+40727272727", completionHandler: { (success, data) -> Void in
            if success {
                var code = data as! String
                //wrong app code
                var appCode = "wtf"
                let deviceToken =  AppPersistentData.sharedInstance.notificationToken == nil ? "Simulator" : AppPersistentData.sharedInstance.notificationToken!
                var parameters = ["phone": AppPersistentData.sharedInstance.phone!,"mcc":"300" ,"code": code, "token": "55942ee3894f51000530894", "app": appCode, "device_token":deviceToken] as [String : Any]
                
                #if os(iOS)
                var mcc = "300"
                parameters["mcc"] = mcc
                parameters["device_type"] = "ios"
                #elseif os(OSX)
                parameters["device_type"] = "mac"
                parameters["device_id"] = RecorderFrameworkManager.sharedInstance.macSN
                #endif
                parameters["time_zone"] = TimeZone.current.secondsFromGMT() / 60
                
                APIClient.sharedInstance.sendVerificationCode(parameters:parameters, completionHandler: { (success, data) -> Void in
                    if success {
                        XCTFail("Error: Code is invalid, server should not accept it")
                    } else {
                        promise.fulfill()
                    }
                })
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test09RegisterEmptyApp(){
        let promise = expectation(description: "Send code fail")
        RecorderFrameworkManager.sharedInstance.register("+40727272727", completionHandler: { (success, data) -> Void in
            if success {
                var code = data as! String
                // empty app
                var appCode = ""
                let deviceToken =  AppPersistentData.sharedInstance.notificationToken == nil ? "Simulator" : AppPersistentData.sharedInstance.notificationToken!
                var parameters = ["phone": AppPersistentData.sharedInstance.phone!,"mcc":"300" ,"code": code, "token": "55942ee3894f51000530894", "app": appCode, "device_token":deviceToken] as [String : Any]
                
                #if os(iOS)
                var mcc = "300"
                parameters["mcc"] = mcc
                parameters["device_type"] = "ios"
                #elseif os(OSX)
                parameters["device_type"] = "mac"
                parameters["device_id"] = RecorderFrameworkManager.sharedInstance.macSN
                #endif
                parameters["time_zone"] = TimeZone.current.secondsFromGMT() / 60
                
                APIClient.sharedInstance.sendVerificationCode(parameters:parameters, completionHandler: { (success, data) -> Void in
                    if success {
                        XCTFail("Error: Code is invalid, server should not accept it")
                    } else {
                        promise.fulfill()
                    }
                })
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test10RegisterEmptyDeviceToken(){
        let promise = expectation(description: "Send code fail")
        RecorderFrameworkManager.sharedInstance.register("+40727272727", completionHandler: { (success, data) -> Void in
            if success {
                var code = data as! String
                var appCode = "rec"
                if RecorderFrameworkManager.sharedInstance.isRecorder{
                    appCode = "rem"
                }
                
                var parameters = ["phone": AppPersistentData.sharedInstance.phone!,"mcc":"300" ,"code": code, "token": "55942ee3894f51000530894", "app": appCode, "device_token":""] as [String : Any]
                
                #if os(iOS)
                var mcc = "300"
                parameters["mcc"] = mcc
                parameters["device_type"] = "ios"
                #elseif os(OSX)
                parameters["device_type"] = "mac"
                parameters["device_id"] = RecorderFrameworkManager.sharedInstance.macSN
                #endif
                parameters["time_zone"] = TimeZone.current.secondsFromGMT() / 60
                
                APIClient.sharedInstance.sendVerificationCode(parameters:parameters, completionHandler: { (success, data) -> Void in
                    if success {
                        XCTFail("Error: Code is invalid, server should not accept it")
                    } else {
                        promise.fulfill()
                    }
                })
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test11RegisterEmptyDeviceType(){
        let promise = expectation(description: "Send code fail")
        RecorderFrameworkManager.sharedInstance.register("+40727272727", completionHandler: { (success, data) -> Void in
            if success {
                var code = data as! String
                var appCode = "rec"
                if RecorderFrameworkManager.sharedInstance.isRecorder{
                    appCode = "rem"
                }
                
                let deviceToken =  AppPersistentData.sharedInstance.notificationToken == nil ? "Simulator" : AppPersistentData.sharedInstance.notificationToken!
                var parameters = ["phone": AppPersistentData.sharedInstance.phone!,"mcc":"300" ,"code": code, "token": "55942ee3894f51000530894", "app": appCode, "device_token":deviceToken] as [String : Any]
                
                var mcc = "300"
                parameters["mcc"] = mcc
                parameters["device_type"] = ""//empty

                parameters["time_zone"] = TimeZone.current.secondsFromGMT() / 60
                
                APIClient.sharedInstance.sendVerificationCode(parameters:parameters, completionHandler: { (success, data) -> Void in
                    if success {
                        XCTFail("Error: Code is invalid, server should not accept it")
                    } else {
                        promise.fulfill()
                    }
                })
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test12RegisterWrongDeviceType(){
        let promise = expectation(description: "Send code fail")
        RecorderFrameworkManager.sharedInstance.register("+40727272727", completionHandler: { (success, data) -> Void in
            if success {
                var code = data as! String
                var appCode = "rec"
                if RecorderFrameworkManager.sharedInstance.isRecorder{
                    appCode = "rem"
                }
                
                let deviceToken =  AppPersistentData.sharedInstance.notificationToken == nil ? "Simulator" : AppPersistentData.sharedInstance.notificationToken!
                var parameters = ["phone": AppPersistentData.sharedInstance.phone!,"mcc":"300" ,"code": code, "token": "55942ee3894f51000530894", "app": appCode, "device_token":deviceToken] as [String : Any]
                var mcc = "300"
                parameters["mcc"] = mcc
                parameters["device_type"] = "asdada"//wrong

                parameters["time_zone"] = TimeZone.current.secondsFromGMT() / 60
                
                APIClient.sharedInstance.sendVerificationCode(parameters:parameters, completionHandler: { (success, data) -> Void in
                    if success {
                        XCTFail("Error: Code is invalid, server should not accept it")
                    } else {
                        promise.fulfill()
                    }
                })
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test13RegisterEmptyDeviceIdMac(){
        let promise = expectation(description: "Send code fail")
        RecorderFrameworkManager.sharedInstance.register("+40727272727", completionHandler: { (success, data) -> Void in
            if success {
                var code = data as! String
                var appCode = "rec"
                if RecorderFrameworkManager.sharedInstance.isRecorder{
                    appCode = "rem"
                }
                
                let deviceToken =  AppPersistentData.sharedInstance.notificationToken == nil ? "Simulator" : AppPersistentData.sharedInstance.notificationToken!
                var parameters = ["phone": AppPersistentData.sharedInstance.phone!,"mcc":"300" ,"code": code, "token": "55942ee3894f51000530894", "app": appCode, "device_token":deviceToken] as [String : Any]

                parameters["device_type"] = "mac"
                parameters["device_id"] = ""//empty

                parameters["time_zone"] = TimeZone.current.secondsFromGMT() / 60
                
                APIClient.sharedInstance.sendVerificationCode(parameters:parameters, completionHandler: { (success, data) -> Void in
                    if success {
                        XCTFail("Error: Code is invalid, server should not accept it")
                    } else {
                        promise.fulfill()
                    }
                })
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test14RegisterWrongTimeZone(){
        let promise = expectation(description: "Send code fail")
        RecorderFrameworkManager.sharedInstance.register("+40727272727", completionHandler: { (success, data) -> Void in
            if success {
                var code = data as! String
                var appCode = "rec"
                if RecorderFrameworkManager.sharedInstance.isRecorder{
                    appCode = "rem"
                }
                
                let deviceToken =  AppPersistentData.sharedInstance.notificationToken == nil ? "Simulator" : AppPersistentData.sharedInstance.notificationToken!
                var parameters = ["phone": AppPersistentData.sharedInstance.phone!,"mcc":"300" ,"code": code, "token": "55942ee3894f51000530894", "app": appCode, "device_token":deviceToken] as [String : Any]
                
                #if os(iOS)
                var mcc = "300"
                parameters["mcc"] = mcc
                parameters["device_type"] = "ios"
                #elseif os(OSX)
                parameters["device_type"] = "mac"
                parameters["device_id"] = RecorderFrameworkManager.sharedInstance.macSN
                #endif
                parameters["time_zone"] = "asdasd"//wrong
                
                APIClient.sharedInstance.sendVerificationCode(parameters:parameters, completionHandler: { (success, data) -> Void in
                    if success {
                        XCTFail("Error: Code is invalid, server should not accept it")
                    } else {
                        promise.fulfill()
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
