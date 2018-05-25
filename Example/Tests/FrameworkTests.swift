//
//  FrameworkTests.swift
//  RecorderFramework_Tests
//
//  Created by Stefanita Oaca on 25/05/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import RecorderFramework

class FrameworkTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test1CreateRecordItem() {
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

        let recordItemDict = RecorderFactory.createDictFromRecordItem(recordItem)
        let newRecordItem = RecorderFactory.createRecordItemFromDict(recordItemDict)
        XCTAssert(recordItem.remindDays == newRecordItem.remindDays)
//        XCTAssert(recordItem.remindDate == newRecordItem.remindDate)
        XCTAssert(recordItem.notes == newRecordItem.notes)
        XCTAssert(recordItem.email == newRecordItem.email)
        XCTAssert(recordItem.phoneNumber == newRecordItem.phoneNumber)
        XCTAssert(recordItem.lastName == newRecordItem.lastName)
        XCTAssert(recordItem.firstName == newRecordItem.firstName)
        XCTAssert(recordItem.text == newRecordItem.text)
        XCTAssert(recordItem.id == newRecordItem.id)
    }
    
    func test2CreateRecordFolder() {
        let recordFolder = RecordFolder()
        recordFolder.title = ""
        recordFolder.id = ""
        recordFolder.created = ""
        recordFolder.folderOrder = 13
        recordFolder.password = ""
        
        let recordFolderDict = RecorderFactory.createDictFromRecordFolder(recordFolder)
        let newRecordFolder = RecorderFactory.createRecordFolderFromDict(recordFolderDict)
        
        XCTAssert(recordFolder.title == recordFolder.title)
        XCTAssert(recordFolder.id == recordFolder.id)
        XCTAssert(recordFolder.created == recordFolder.created)
        XCTAssert(recordFolder.folderOrder == recordFolder.folderOrder)
        XCTAssert(recordFolder.password == recordFolder.password)
    }
}
