//
//  FileTests.swift
//  RecorderFramework_Tests
//
//  Created by Stefanita Oaca on 14/05/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

//NOTE: test all file, do not run separate tests

import UIKit
import XCTest
import RecorderFramework

class FileTestsUnsucessfull: XCTestCase {
    var fileId = "" //newly created file id
    var folderId: String! // newly created folder id
    var folderName = "UnitTestFolder" // name of the new folder
    
    override func setUp() {
        super.setUp()
        //get file id
        if let id = UserDefaults.standard.value(forKey: "testFileId") as? String {
            self.fileId = id
        }
        // get folder it
        if let id = UserDefaults.standard.value(forKey: "testFolderId") as? String {
            self.folderId = id
        }
    }
    
    override func tearDown() {
        super.tearDown()
        //save file id and folder id
        UserDefaults.standard.set(self.fileId, forKey: "testFileId")
        UserDefaults.standard.set(self.folderId, forKey: "testFolderId")
        UserDefaults.standard.synchronize()
    }
    
    func test01Create() {
        //create record item to use in future tests
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
    
    func test02UpdateWrongEmail() {
        if let recordItem = RecordingsManager.sharedInstance.getRecordingById(self.fileId){
            recordItem.remindDays = "UnitTestDaysUpdate"
            recordItem.remindDate = "UnitTestDateUpdate"
            recordItem.notes = "UnitTestNoteUpdate"
            recordItem.email = "BAD EMAIL"//Bad email address
            recordItem.phoneNumber = "+40772727272"
            recordItem.lastName = "UnitTestLastNameUpdate"
            recordItem.firstName = "UnitTestFirstNameUpdate"
            recordItem.text = "UnitTestTextUpdate"
            
            var dict = RecorderFrameworkManager.sharedInstance.createDictFromRecordItem(recordItem)
            dict[ServerReuqestKeys.apiKey.rawValue] = AppPersistentData.sharedInstance.apiKey!
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
    
    func test03UpdateWrongRemindDays() {
        if let recordItem = RecordingsManager.sharedInstance.getRecordingById(self.fileId){
            recordItem.remindDays = "asdasfgdsf"//wrong remind date
            recordItem.remindDate = "UnitTestDateUpdate"
            recordItem.notes = "UnitTestNoteUpdate"
            recordItem.email = "email@example.com"
            recordItem.phoneNumber = "+40772727272"
            recordItem.lastName = "UnitTestLastNameUpdate"
            recordItem.firstName = "UnitTestFirstNameUpdate"
            recordItem.text = "UnitTestTextUpdate"
            
            var dict = RecorderFrameworkManager.sharedInstance.createDictFromRecordItem(recordItem)
            dict[ServerReuqestKeys.apiKey.rawValue] = AppPersistentData.sharedInstance.apiKey!
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
    
    func test04UpdateWrongRemindDate() {
        if let recordItem = RecordingsManager.sharedInstance.getRecordingById(self.fileId){
            recordItem.remindDays = "5"
            recordItem.remindDate = "asdasfa"//wrong remind date
            recordItem.notes = "UnitTestNoteUpdate"
            recordItem.email = "email@example.com"
            recordItem.phoneNumber = "+40772727272"
            recordItem.lastName = "UnitTestLastNameUpdate"
            recordItem.firstName = "UnitTestFirstNameUpdate"
            recordItem.text = "UnitTestTextUpdate"
            
            var dict = RecorderFrameworkManager.sharedInstance.createDictFromRecordItem(recordItem)
            dict[ServerReuqestKeys.apiKey.rawValue] = AppPersistentData.sharedInstance.apiKey!
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
    
    func test05StarWrongId() {
        let promise = expectation(description: "Star file fail")
        //no entity id
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
    
    
    func test07CloneWrongEntityId() {
        let promise = expectation(description: "Clone file fail")
        //no entity id
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
    
    func test08MoveWrongFolderId() {
        let promise = expectation(description: "Move file fail")
        let recordItem = RecordItem()
        recordItem.id = self.fileId
        //wrong folder id
        APIClient.sharedInstance.moveRecording(recordItem, folderId:"23423423423", completionHandler: { (success, data) -> Void in
            if success {
                XCTFail("Error: Id is invalid, server should not accept it")
            }
            else {
                promise.fulfill()
            }
        })
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func test09MoveWrongFileId() {
        let promise = expectation(description: "Move file fail")
        //create folder to move file to
        RecorderFrameworkManager.sharedInstance.createFolder(folderName, localID: "", completionHandler: { (success, data) -> Void in
            if success {
                if let folderId = data as? NSNumber{
                    self.folderId = "\(folderId)"
                    let recordItem = RecordItem()
                    recordItem.id = "4232423423as"//wrong file id
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
    
    func test10GetMetadataWrongFileId() {
        let promise = expectation(description: "Get metadata files fail")
        let recordItem = RecordItem()
        recordItem.id = "12349789764589745"//wrong id
        APIClient.sharedInstance.getMetadataFiles(recordItem, completionHandler: { (success, data) -> Void in
            if(success){
                XCTFail("Error: Id is invalid, server should not accept it")
            } else{
                promise.fulfill()
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test11DeleteWrongFileId() {
        let promise = expectation(description: "Delete file fail")
        //no id provided
        APIClient.sharedInstance.deleteRecording("", removeForever: true, completionHandler: { (success, data) -> Void in
            if(success){
                XCTFail("Error: Id is invalid, server should not accept it")
            } else{
                promise.fulfill()
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test12Delete() {
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
    
    func test13RecoverWrongFileId(){
        let promise = expectation(description: "Recover file fail")
        let recordItem = RecordItem()
        recordItem.id = "12349789764589745"//wrong file id
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
    
    func test14RecoverWrongFolderId(){
        let promise = expectation(description: "Recover file fail")
        let recordItem = RecordItem()
        recordItem.id = self.fileId
        //wrong folder id
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
    
    func test15DeleteFolderWrongFolderId(){
        let promise = expectation(description: "Delete folder fail")
        //empty folder id
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
    
    func test16DeleteFolder(){
        let promise = expectation(description: "Delete folder")
        //delete folder
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
    
    func test17GetRecordingsWrongSource(){
        let promise = expectation(description: "Get recordings fail")
        
        var parameters:[String : Any] = ["reminder":"true"]
        parameters[ServerReuqestKeys.apiKey.rawValue] = AppPersistentData.sharedInstance.apiKey!
        if folderId != nil {
            parameters.updateValue(folderId, forKey: "folder_id")
        }
        parameters["source"] = "9887"//wrong source
        APIClient.sharedInstance.getRecordings(parameters:parameters, completionHandler: { (success, data) -> Void in
            if success {
                XCTFail("Error: \(data)")
            }
            else {
                promise.fulfill()
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test18GetRecordingsWrongId(){
        let promise = expectation(description: "Get recordings fail")
        
        var parameters:[String : Any] = ["reminder":"true"]
        if folderId != nil {
            parameters.updateValue(folderId!, forKey: "folder_id")
        }
        parameters[ServerReuqestKeys.apiKey.rawValue] = AppPersistentData.sharedInstance.apiKey!
        parameters["source"] = "all"
        parameters["id"] = "987465132"//wrong id
        parameters["op"] = "less"
        
        APIClient.sharedInstance.getRecordings(parameters:parameters, completionHandler: { (success, data) -> Void in
            if success {
                XCTFail("Error: \(data)")
            }
            else {
                promise.fulfill()
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
}
