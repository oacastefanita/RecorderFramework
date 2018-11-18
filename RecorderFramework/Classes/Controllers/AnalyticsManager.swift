//
//  AnalyticsManager.swift
//  Pods
//
//  Created by Stefanita Oaca on 14/11/2018.
//

import Foundation

#if os(iOS) || os(macOS) || os(tvOS)
import Mixpanel
#endif

public class AnalyticsManager : NSObject {
    public static let sharedInstance = AnalyticsManager()
    
    override public init() {
        super.init()
        
#if os(iOS) || os(macOS) || os(tvOS)
        Mixpanel.sharedInstance(withToken: "bd4a2b9b1f2ccc5215cc3a0aabfa9c0e")
#endif
    }
    
    func track(_ event: String!, properties: [AnyHashable: Any]? = nil) {
#if os(iOS) || os(macOS) || os(tvOS)
        Mixpanel.sharedInstance()?.track(event, properties:properties)
#endif
    }
}
