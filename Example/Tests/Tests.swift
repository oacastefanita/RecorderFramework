import UIKit
import XCTest
import RecorderFramework

class Tests: XCTestCase {
    var folderName = "UnitTestFolder"
    var folderId: String!
    
    var recordingName = "UnitTestFile"
    var recordingId: String!
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
                                if folder.id == "\(folderId)"{
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
        let newPass = "Pass Test"
        APIClient.sharedInstance.addPasswordToFolder(self.folderId, pass:newPass, completionHandler: { (success, data) -> Void in
            if success {
                RecorderFrameworkManager.sharedInstance.getFolders({ (success, data) -> Void in
                    if success{
                        var found = false
                        for folder in data as! [RecordFolder]{
                            if folder.id == "\(self.folderId)"{
                                if folder.password == newPass{
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
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    func test5DeleteFolder(){
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
