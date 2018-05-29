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

class FileTestsUnsucessfull: XCTestCase {
    var fileId = ""
    var folderId: String!
    var folderName = "UnitTestFolder"
    
    override func setUp() {
        super.setUp()
        if let id = UserDefaults.standard.value(forKey: "testFileId") as? String {
            self.fileId = id
        }
        if let id = UserDefaults.standard.value(forKey: "testFolderId") as? String {
            self.folderId = id
        }
    }
    
    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.set(self.fileId, forKey: "testFileId")
        UserDefaults.standard.set(self.folderId, forKey: "testFolderId")
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
    
    func test2UpdateWrongEmail() {
        if let recordItem = RecordingsManager.sharedInstance.getRecordingById(self.fileId){
            recordItem.remindDays = "UnitTestDaysUpdate"
            recordItem.remindDate = "UnitTestDateUpdate"
            recordItem.notes = "UnitTestNoteUpdate"
            recordItem.email = "BAD EMAIL"
            recordItem.phoneNumber = "+40772727272"
            recordItem.lastName = "UnitTestLastNameUpdate"
            recordItem.firstName = "UnitTestFirstNameUpdate"
            recordItem.text = "UnitTestTextUpdate"
            
            let dict = RecorderFrameworkManager.sharedInstance.createDictFromRecordItem(recordItem)
            let promise = expectation(description: "Update file fail")
            APIClient.sharedInstance.updateRecordingInfo(recordItem, parameters:dict as! [String : Any], completionHandler: { (success, data) -> Void in
                if success {
                    XCTFail("Error: Email is invalid, server should not accept it")
                }
                else {
                    promise.fulfill()
                }
            })
            
            waitForExpectations(timeout: 30, handler: nil)
        }else{
            XCTFail("Error: file update failed")
        }
        
    }
    
    func test3UpdateWrongRemindDays() {
        if let recordItem = RecordingsManager.sharedInstance.getRecordingById(self.fileId){
            recordItem.remindDays = "asdasfgdsf"
            recordItem.remindDate = "UnitTestDateUpdate"
            recordItem.notes = "UnitTestNoteUpdate"
            recordItem.email = "email@example.com"
            recordItem.phoneNumber = "+40772727272"
            recordItem.lastName = "UnitTestLastNameUpdate"
            recordItem.firstName = "UnitTestFirstNameUpdate"
            recordItem.text = "UnitTestTextUpdate"
            
            let dict = RecorderFrameworkManager.sharedInstance.createDictFromRecordItem(recordItem)
            let promise = expectation(description: "Update file fail")
            APIClient.sharedInstance.updateRecordingInfo(recordItem, parameters:dict as! [String : Any], completionHandler: { (success, data) -> Void in
                if success {
                    XCTFail("Error: remindDays is invalid, server should not accept it")
                }
                else {
                    promise.fulfill()
                }
            })
            
            waitForExpectations(timeout: 30, handler: nil)
        }else{
            XCTFail("Error: file update failed")
        }
        
    }
    
    func test4UpdateWrongRemindDate() {
        if let recordItem = RecordingsManager.sharedInstance.getRecordingById(self.fileId){
            recordItem.remindDays = "5"
            recordItem.remindDate = "asdasfa"
            recordItem.notes = "UnitTestNoteUpdate"
            recordItem.email = "email@example.com"
            recordItem.phoneNumber = "+40772727272"
            recordItem.lastName = "UnitTestLastNameUpdate"
            recordItem.firstName = "UnitTestFirstNameUpdate"
            recordItem.text = "UnitTestTextUpdate"
            
            let dict = RecorderFrameworkManager.sharedInstance.createDictFromRecordItem(recordItem)
            let promise = expectation(description: "Update file fail")
            APIClient.sharedInstance.updateRecordingInfo(recordItem, parameters:dict as! [String : Any], completionHandler: { (success, data) -> Void in
                if success {
                    XCTFail("Error: remindDate is invalid, server should not accept it")
                }
                else {
                    promise.fulfill()
                }
            })
            
            waitForExpectations(timeout: 30, handler: nil)
        }else{
            XCTFail("Error: file update failed")
        }
        
    }
    
    func test5StarWrongId() {
        let promise = expectation(description: "Star file fail")
        RecorderFrameworkManager.sharedInstance.star(true, entityId: "", isFile: true, completionHandler: { (success, data) -> Void in
            if success {
                XCTFail("Error: Id is invalid, server should not accept it")
            }
            else {
                promise.fulfill()
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test6Clone() {
        let promise = expectation(description: "Clone file fail")
        RecorderFrameworkManager.sharedInstance.cloneFile(entityId: "", completionHandler: { (success, data) -> Void in
            if success {
                XCTFail("Error: Id is invalid, server should not accept it")
            }
            else {
                promise.fulfill()
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test7MoveWrongFolder() {
        let promise = expectation(description: "Move file fail")
        let recordItem = RecordItem()
        recordItem.id = self.fileId
        APIClient.sharedInstance.moveRecording(recordItem, folderId:"asdjasid asiod", completionHandler: { (success, data) -> Void in
            if success {
                XCTFail("Error: Id is invalid, server should not accept it")
            }
            else {
                promise.fulfill()
            }
        })
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func test8MoveWrongId() {
        let promise = expectation(description: "Move file fail")
        RecorderFrameworkManager.sharedInstance.createFolder(folderName, localID: "", completionHandler: { (success, data) -> Void in
            if success {
                if let folderId = data as? NSNumber{
                    self.folderId = "\(folderId)"
                    let recordItem = RecordItem()
                    recordItem.id = "asdasdas"
                    APIClient.sharedInstance.moveRecording(recordItem, folderId:self.folderId, completionHandler: { (success, data) -> Void in
                        if success {
                            XCTFail("Error: Id is invalid, server should not accept it")
                        }
                        else {
                            promise.fulfill()
                        }
                    })
                }else{
                    XCTFail("Error: \(data)")
                }
            } else {
                XCTFail("Error: \(data)")
            }
        })
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func test9GetMetadata() {
        let promise = expectation(description: "Get metadata files fail")
        let recordItem = RecordItem()
        recordItem.id = "12349789764589745"
        APIClient.sharedInstance.getMetadataFiles(recordItem, completionHandler: { (success, data) -> Void in
            if(success){
                XCTFail("Error: Id is invalid, server should not accept it")
            } else{
                promise.fulfill()
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test10DeleteFail() {
        let promise = expectation(description: "Delete file fail")
        APIClient.sharedInstance.deleteRecording("", removeForever: true, completionHandler: { (success, data) -> Void in
            if(success){
                XCTFail("Error: Id is invalid, server should not accept it")
            } else{
                promise.fulfill()
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test11Delete() {
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
    
    func test12Recover(){
        let promise = expectation(description: "Recover file fail")
        let recordItem = RecordItem()
        recordItem.id = "12349789764589745"
        APIClient.sharedInstance.recoverRecording(recordItem, folderId:"\(folderId)", completionHandler: { (success, data) -> Void in
            if success {
                promise.fulfill()
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test13Recover(){
        let promise = expectation(description: "Recover file fail")
        let recordItem = RecordItem()
        recordItem.id = self.fileId
        APIClient.sharedInstance.recoverRecording(recordItem, folderId:"112346798451", completionHandler: { (success, data) -> Void in
            if success {
                promise.fulfill()
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test14DeleteFolderFail(){
        let promise = expectation(description: "Delete folder fail")
        
        APIClient.sharedInstance.deleteFolder("", moveTo:"", completionHandler: { (success, data) -> Void in
            if success {
                XCTFail("Error: Id is invalid, server should not accept it")
            }
            else {
                promise.fulfill()
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test15DeleteFolder(){
        let promise = expectation(description: "Delete folder")
        
        APIClient.sharedInstance.deleteFolder(self.folderId, moveTo:"", completionHandler: { (success, data) -> Void in
            if success {
                promise.fulfill()
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
}
