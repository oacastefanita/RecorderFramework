//
//  AnaliticsManager.h
//  googleadwords
//
//  Created by Adelina on 2/16/15.
//  Copyright (c) 2015 Code Blue Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum AnaliticsEventTypes
{
    kAnaliticsEventTypePasswordShown= 0,//
    kAnaliticsEventTypeFoldersShown,//
    kAnaliticsEventTypeRecordingsShown,//
    kAnaliticsEventTypeSettingsShown,//
    kAnaliticsEventTypeRecordItemSelected,//
    kAnaliticsEventTypeInfoShown,//
    kAnaliticsEventTypeShareShown,//
    kAnaliticsEventTypeExportFailed,//
    kAnaliticsEventTypeExportSuccedded,//
    kAnaliticsEventTypeBluetoothFailed,//
    kAnaliticsEventTypeBluetoothSuccedded,//
    kAnaliticsEventTypeWifiFailed,//
    kAnaliticsEventTypeWifiSuccedded,//
    kAnaliticsEventTypeNumberRegistered,//
    kAnaliticsEventTypeAccountVerified,//
    kAnaliticsEventTypeFolderCreated,//
    kAnaliticsEventTypeFolderRenamed,//
    kAnaliticsEventTypeFolderDeleted,//
    kAnaliticsEventTypeFolderReorder,//
    kAnaliticsEventTypeRecordItemMoved,//
    kAnaliticsEventTypeRecordItemRenamed,//
    kAnaliticsEventTypeRecordItemDeleted,//
} AnaliticsEventTypes;

@interface AnaliticsManager : NSObject

+ (instancetype)sharedInstance;
- (void) addEvent:(AnaliticsEventTypes)eventType;

@end
