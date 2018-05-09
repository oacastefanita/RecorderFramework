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
    
    func testContainerName() {
        // This is an example of a functional test case.
        let obj = RecorderFrameworkManager.sharedInstance.containerName
        XCTAssertEqual(obj, "group.com.codebluestudio.Recorder")
    }
    
    func testGetFolders(){
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
    
    func testCreateFolder(){
        let promise = expectation(description: "Folder created")
        
        RecorderFrameworkManager.sharedInstance.createFolder(folderName, localID: "", completionHandler: { (success, data) -> Void in
            if success {
                promise.fulfill()
            }
            else {
                XCTFail("Error: \(data)")
            }
        })
        waitForExpectations(timeout: 20, handler: nil)
    }
}
