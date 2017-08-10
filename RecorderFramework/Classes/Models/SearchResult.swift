//
//  SearchResult.swift
//  Recorder
//
//  Created by Adelina on 7/17/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import Foundation

public class SearchResult: NSObject{
    public var text: String! = ""
    public var recordItem: RecordItem!
    public var recordFolder: RecordFolder!
    public var isText: Bool = false
}
