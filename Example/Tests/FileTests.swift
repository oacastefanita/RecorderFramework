//
//  FileTests.swift
//  RecorderFramework_Tests
//
//  Created by Stefanita Oaca on 14/05/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import RecorderFramework

class FileTests: XCTestCase {
    var fileId = ""
    
    override func setUp() {
        super.setUp()
        if let id = UserDefaults.standard.value(forKey: "testFileId") as? String {
            self.fileId = id
        }
    }
    
    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.set(self.fileId, forKey: "testFileId")
        UserDefaults.standard.synchronize()
    }
    
    func test1Create() {
        let recordItem = RecordItem()
        recordItem.remindDays = "UnitTestDays"
        recordItem.remindDate = "UnitTestDate"
        recordItem.notes = "UnitTestNote"
        recordItem.email = "Unit@Test.com"
        recordItem.phoneNumber = "+40727272727"
        recordItem.lastName = "UnitTestLastName"
        recordItem.firstName = "UnitTestFirstName"
        recordItem.text = "UnitTestText"
        recordItem.id = UUID().uuidString
        self.fileId = recordItem.id
        
        let oldPath = Bundle.main.url(forResource: "Test", withExtension: "wav")
        let fileManager = FileManager.default
        let sharedContainer = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)
        
        var newPath = "/" + (RecordingsManager.sharedInstance.recordFolders.first?.title)! + "/" + recordItem.id
        if !FileManager.default.fileExists(atPath: (sharedContainer?.path)! + newPath) {
            do {
                try FileManager.default.createDirectory(atPath: (sharedContainer?.path)! + newPath, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }
        newPath = newPath + "/" + recordItem.id + ".wav"
        
        do {
            try fileManager.moveItem(atPath: (oldPath?.path)!, toPath: (sharedContainer?.path)! + newPath)
            recordItem.localFile = newPath
        }
        catch let error as NSError {
            XCTFail("Error: \(error.localizedDescription)")
        }
        
        let promise = expectation(description: "Upload file")
        APIClient.sharedInstance.uploadRecording(recordItem, completionHandler: { (success, data) -> Void in
            if(success){
                recordItem.id = data as! String
                self.fileId = recordItem.id
                _ = RecorderFrameworkManager.sharedInstance.syncRecordingItem(recordItem, folder:RecordingsManager.sharedInstance.recordFolders[0])
                
                promise.fulfill()
            } else{
                XCTFail("Error: \(data)")
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test2Update() {
        if let recordItem = RecordingsManager.sharedInstance.getRecordingById(self.fileId){
            recordItem.remindDays = "UnitTestDaysUpdate"
            recordItem.remindDate = "UnitTestDateUpdate"
            recordItem.notes = "UnitTestNoteUpdate"
            recordItem.email = "UnitUpdatet@Test.com"
            recordItem.phoneNumber = "+40772727272"
            recordItem.lastName = "UnitTestLastNameUpdate"
            recordItem.firstName = "UnitTestFirstNameUpdate"
            recordItem.text = "UnitTestTextUpdate"
            
            let dict = RecorderFrameworkManager.sharedInstance.createDictFromRecordItem(recordItem)
            let promise = expectation(description: "Update file")
            APIClient.sharedInstance.updateRecordingInfo(recordItem, parameters:dict as! [String : Any], completionHandler: { (success, data) -> Void in
                if(success){
                    RecorderFrameworkManager.sharedInstance.defaultFolderSync { (success) -> Void in
                        if success {
                            if let newRec = RecordingsManager.sharedInstance.getRecordingById(self.fileId){
                                if newRec.remindDays == "UnitTestDaysUpdate" && newRec.remindDate == "UnitTestDateUpdate" && newRec.notes == "UnitTestNoteUpdate" && newRec.email == "UnitUpdatet@Test.com" && newRec.phoneNumber == "+40772727272" && newRec.lastName == "UnitTestLastNameUpdate" && newRec.firstName == "UnitTestFirstNameUpdate" && newRec.text == "UnitTestTextUpdate"{
                                    promise.fulfill()
                                }else{
                                    XCTFail("Error: incorrect data")
                                }
                            }else{
                                XCTFail("Error: no recording")
                            }
                        }else{
                            XCTFail("Error: \(data)")
                        }
                    }
                } else{
                    XCTFail("Error: \(data)")
                }
            })
            
            waitForExpectations(timeout: 30, handler: nil)
        }else{
            XCTFail("Error: file update failed")
        }
        
    }
    
    func test3Star() {
        let promise = expectation(description: "Star file")
        RecorderFrameworkManager.sharedInstance.star(true, entityId: self.fileId, isFile: true, completionHandler: { (success, data) -> Void in
            if(success){
                promise.fulfill()
            } else{
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test4Clone() {
        let promise = expectation(description: "Clone file")
        RecorderFrameworkManager.sharedInstance.cloneFile(entityId: self.fileId, completionHandler: { (success, data) -> Void in
            if(success){
                promise.fulfill()
            } else{
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test5Delete() {
        let promise = expectation(description: "Delete file")
        APIClient.sharedInstance.deleteRecording(self.fileId, removeForever: true, completionHandler: { (success, data) -> Void in
            if(success){
                promise.fulfill()
            } else{
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
}
