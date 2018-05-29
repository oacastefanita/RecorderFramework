import UIKit
import XCTest
import RecorderFramework

class FolderTestsUnsucessfull: XCTestCase {
    var folderName = "UnitTestFolder"
    var folderId: String!
    
    var recordingName = "UnitTestFile"
    var recordingId: String!
    
    
    override func setUp() {
        super.setUp()
        if let id = UserDefaults.standard.value(forKey: "testFolderId") as? String {
            self.folderId = id
        }
        if let id = UserDefaults.standard.value(forKey: "testRecordingId") as? String {
            self.recordingId = id
        }
    }
    
    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.set(self.folderId, forKey: "testFolderId")
        UserDefaults.standard.set(self.recordingId, forKey: "testRecordingId")
        UserDefaults.standard.synchronize()
    }
    
    func test1CreateFolderEmptyTitle(){
        let promise = expectation(description: "Folder create fail")
        RecorderFrameworkManager.sharedInstance.createFolder("", localID: "", completionHandler: { (success, data) -> Void in
            if success {
                XCTFail("Error: Name is invalid, server should not accept it")
            }
            else {
                promise.fulfill()
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test2CreateFolder(){
        let promise = expectation(description: "Folder created")
        RecorderFrameworkManager.sharedInstance.createFolder(folderName, localID: "", completionHandler: { (success, data) -> Void in
            if success {
                if let folderId = data as? NSNumber{
                    RecorderFrameworkManager.sharedInstance.getFolders({ (success, data) -> Void in
                        if success{
                            var found = false
                            for folder in data as! [RecordFolder]{
                                if folder.id == "\(folderId)" && folder.title == self.folderName{
                                    self.folderId = folder.id
                                    promise.fulfill()
                                    found = true
                                    break
                                }
                            }
                            if found == false{
                                XCTFail("Error: \(data)")
                            }
                        }else{
                            XCTFail("Error: \(data)")
                        }
                    })
                }else{
                    XCTFail("Error: \(data)")
                }
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
//    func test3AddPassWithoutFolderId(){
//        let promise = expectation(description: "Add Pass fail")
//        let newPass = "UnitTestPass"
//        APIClient.sharedInstance.addPasswordToFolder("", pass:newPass, completionHandler: { (success, data) -> Void in
//            if success {
//                XCTFail("Error: Id is invalid, server should not accept it")
//            }
//            else {
//                promise.fulfill()
//            }
//        })
//        waitForExpectations(timeout: 30, handler: nil)
//    }
    
//    func test4AddEmptyPassToFolder(){
//        let promise = expectation(description: "Add Pass failed")
//        let newPass = ""
//        APIClient.sharedInstance.addPasswordToFolder(self.folderId, pass:newPass, completionHandler: { (success, data) -> Void in
//            if success {
//                XCTFail("Error: Pass is invalid, server should not accept it")
//            }
//            else {
//                promise.fulfill()
//            }
//        })
//        waitForExpectations(timeout: 30, handler: nil)
//    }
    
    func test5RenameFolderEmpty(){
        let promise = expectation(description: "Rename folder fail")
        APIClient.sharedInstance.renameFolder(self.folderId, name:"", completionHandler: { (success, data) -> Void in
            if success {
                XCTFail("Error: Name is invalid, server should not accept it")
            }
            else {
                promise.fulfill()
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test6RenameFolderNoId(){
        let promise = expectation(description: "Rename folder fail")
        APIClient.sharedInstance.renameFolder("", name:"UnitTestRename", completionHandler: { (success, data) -> Void in
            if success {
                XCTFail("Error: Id is invalid, server should not accept it")
            }
            else {
                promise.fulfill()
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test7DeleteFolderNoId(){
        let promise = expectation(description: "Folder delete fail")
        
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
    
    func test8DeleteFolderNoId(){
        let promise = expectation(description: "Folder delete fail")
        
        APIClient.sharedInstance.deleteFolder(self.folderId, moveTo:"65468752785", completionHandler: { (success, data) -> Void in
            if success {
                XCTFail("Error: Id is invalid, server should not accept it")
            }
            else {
                promise.fulfill()
            }
        })
        
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test9DeleteFolder(){
        let promise = expectation(description: "Folder Delete")
        
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
