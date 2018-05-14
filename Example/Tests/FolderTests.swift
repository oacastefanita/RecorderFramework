import UIKit
import XCTest
import RecorderFramework

class FolderTests: XCTestCase {
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
    
    func test1ContainerName() {
        // This is an example of a functional test case.
        let obj = RecorderFrameworkManager.sharedInstance.containerName
        XCTAssertEqual(obj, "group.com.codebluestudio.Recorder")
    }
    
    func test2GetFolders(){
        let promise = expectation(description: "Folder created")
        RecorderFrameworkManager.sharedInstance.getFolders({ (success, data) -> Void in
            if success{
                promise.fulfill()
            }else{
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    func test3CreateFolder(){
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
    
    func test4AddPassToFolder(){
        let promise = expectation(description: "Added password")
        let newPass = "PassTest"
        APIClient.sharedInstance.addPasswordToFolder(self.folderId, pass:newPass, completionHandler: { (success, data) -> Void in
            if success {
                APIClient.sharedInstance.verifyFolderPass(newPass,folderId: self.folderId, completionHandler: { (success, data) -> Void in
                    if success {
                        promise.fulfill()
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
    
    func test5RenameFolder(){
        let promise = expectation(description: "Rename folder")
        let newName = folderName + "renamed"
        APIClient.sharedInstance.renameFolder(self.folderId, name:newName, completionHandler: { (success, data) -> Void in
        if success {
            RecorderFrameworkManager.sharedInstance.getFolders({ (success, data) -> Void in
                if success{
                    var found = false
                    for folder in data as! [RecordFolder]{
                        if folder.id == self.folderId!{
                            if folder.title == newName{
                                promise.fulfill()
                                found = true
                                break
                            }
                        }
                    }
                    if found == false{
                        XCTFail("Error: \(data)")
                    }
                }else{
                    XCTFail("Error: \(data)")
                }
            })
        }else {
            XCTFail("Error: \(data)")
        }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test6DeleteFolder(){
        let promise = expectation(description: "Folder Deleted")
        
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
