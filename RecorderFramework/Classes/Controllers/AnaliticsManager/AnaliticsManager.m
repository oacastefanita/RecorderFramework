//
//  AnaliticsManager.m
//  googleadwords
//
//  Created by Adelina on 2/16/15.
//  Copyright (c) 2015 Code Blue Studio. All rights reserved.
//

#import "AnaliticsManager.h"
#if TARGET_OS_IPHONE
//#import "Flurry.h"
//#import "GAI.h"
//#import "GAIDictionaryBuilder.h"
//#import "GAIEcommerceProduct.h"
//#import "GAIEcommerceProductAction.h"
//#import "GAIEcommercePromotion.h"
//#import "GAIFields.h"
//#import "GAILogger.h"
//#import "GAITrackedViewController.h"
//#import "GAITracker.h"
//#import "TAGContainer.h"
//#import "TAGContainerOpener.h"
//#import "TAGManager.h"
//#import "TAGDataLayer.h"
#else
#import <Google Analytics SDK for OSX/AnalyticsHelper.h>
#endif

@interface AnaliticsManager()
#if TARGET_OS_IPHONE
//<TAGContainerOpenerNotifier>
#endif
{
    
}

#if TARGET_OS_IPHONE
//@property (nonatomic, strong) TAGManager *tagManager;
//@property (nonatomic, strong) TAGContainer *container;
#else
@property (nonatomic, strong) AnalyticsHelper* analyticsHelper;
#endif

@end

@implementation AnaliticsManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t p = 0;
    __strong static AnaliticsManager *_sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[AnaliticsManager alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if(self)
    {
#if TARGET_OS_IPHONE
        //[self initFlurry];
        [self initGoogleTagManager];
#endif
        [self initGoogleAnalytics];
    }
    
    return self;
}

#pragma mark - initialization methods
#if TARGET_OS_IPHONE
- (void)initFlurry
{
//    [Flurry startSession:@"K8696PD5SK9FMFV9HQ7X"];
//    [Flurry setEventLoggingEnabled:YES];
//    [Flurry setLogLevel:FlurryLogLevelNone];
}

- (void)initGoogleAnalytics
{
//    [GAI sharedInstance].trackUncaughtExceptions = NO;
//    [GAI sharedInstance].dispatchInterval = 20;
//    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
//    [[GAI sharedInstance] trackerWithTrackingId:@"UA-64486422-1"];//please insert track id because none was provided, i am trying to make this line very long so that you notice it
}

- (void)initGoogleTagManager
{
//    self.tagManager = [TAGManager instance];
//    [self.tagManager.logger setLogLevel:kTAGLoggerLogLevelDebug];
//    [TAGContainerOpener openContainerWithId:@"GTM-5BMCCZ"
//                                 tagManager:self.tagManager
//                                   openType:kTAGOpenTypePreferFresh
//                                    timeout:nil
//                                   notifier:self];
}
#else
- (void)initGoogleAnalytics
{
//    self.analyticsHelper = [[AnalyticsHelper alloc] init];
//    self.analyticsHelper.domainName = @"dexteroi.com";
//    self.analyticsHelper.analyticsAccountCode = @"UA-59731338-1";
}
#endif

#pragma mark - add event methods
- (void) addEvent:(AnaliticsEventTypes)eventType
{
#if TARGET_OS_IPHONE
//    [self addFlurryEvent:eventType];
//    [self addGoogleTagEvent:eventType];
#endif
//    [self addGoogleAnalyticsEvent:eventType];
    
}
#if TARGET_OS_IPHONE
- (void)addFlurryEvent:(AnaliticsEventTypes)eventType
{
    //[Flurry logEvent:[self stringForEventType:eventType] withParameters:nil];
}

- (void)addGoogleAnalyticsEvent:(AnaliticsEventTypes)eventType
{
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[self categoryForEventType:eventType]
//                                                          action:[self actionForEventType:eventType]
//                                                           label:[self stringForEventType:eventType]
//                                                           value:nil] build]];
}

- (void)addGoogleTagEvent:(AnaliticsEventTypes)eventType
{
//    TAGDataLayer *dataLayer = [TAGManager instance].dataLayer;
//    [dataLayer push:@{@"Event": [self stringForEventType:eventType]}];
}
#else
- (void)addGoogleAnalyticsEvent:(AnaliticsEventTypes)eventType
{
    [self.analyticsHelper fireEvent:[self categoryForEventType:eventType]
                             action:[self actionForEventType:eventType]
                         eventLabel:[self stringForEventType:eventType]
                         eventValue:@1];
}
#endif

#pragma mark - decode event type methods
- (NSString*)actionForEventType:(AnaliticsEventTypes)eventType
{
    NSString* returnString = @"";
    
    switch (eventType)
    {
        case kAnaliticsEventTypePasswordShown:
            returnString = @"Shown";
            break;
        case kAnaliticsEventTypeFoldersShown:
            returnString = @"Shown";
            break;

        case kAnaliticsEventTypeRecordingsShown:
            returnString = @"Shown";
            break;

        case kAnaliticsEventTypeSettingsShown:
            returnString = @"Shown";
            break;

        case kAnaliticsEventTypeRecordItemSelected:
            returnString = @"Shown";
            break;

        case kAnaliticsEventTypeInfoShown:
            returnString = @"Shown";
            break;

        case kAnaliticsEventTypeShareShown:
            returnString = @"Shown";
            break;

        case kAnaliticsEventTypeFolderCreated:
            returnString = @"Tap";
            break;

        case kAnaliticsEventTypeFolderRenamed:
            returnString = @"Tap";
            break;

        case kAnaliticsEventTypeFolderDeleted:
            returnString = @"Tap";
            break;
            
        case kAnaliticsEventTypeFolderReorder:
            returnString = @"Tap";
            break;

        case kAnaliticsEventTypeRecordItemMoved:
            returnString = @"Tap";
            break;

        case kAnaliticsEventTypeRecordItemRenamed:
            returnString = @"Tap";
            break;

        case kAnaliticsEventTypeRecordItemDeleted:
            returnString = @"Tap";
            break;

        default:
            break;
    }
    
    return returnString;
}


- (NSString*)categoryForEventType:(AnaliticsEventTypes)eventType
{
    NSString* returnString = @"";
    
    switch (eventType)
    {
        case kAnaliticsEventTypePasswordShown:
            returnString = @"ScreenPresentation";
            break;
        case kAnaliticsEventTypeFoldersShown:
            returnString = @"ScreenPresentation";
            break;
            
        case kAnaliticsEventTypeRecordingsShown:
            returnString = @"ScreenPresentation";
            break;
            
        case kAnaliticsEventTypeSettingsShown:
            returnString = @"ScreenPresentation";
            break;
            
        case kAnaliticsEventTypeRecordItemSelected:
            returnString = @"ScreenPresentation";
            break;
            
        case kAnaliticsEventTypeInfoShown:
            returnString = @"ScreenPresentation";
            break;
            
        case kAnaliticsEventTypeShareShown:
            returnString = @"ScreenPresentation";
            break;
            
        case kAnaliticsEventTypeFolderCreated:
            returnString = @"UserAction";
            break;
            
        case kAnaliticsEventTypeFolderRenamed:
            returnString = @"UserAction";
            break;
            
        case kAnaliticsEventTypeFolderDeleted:
            returnString = @"UserAction";
            break;
            
        case kAnaliticsEventTypeFolderReorder:
            returnString = @"UserAction";
            break;
            
        case kAnaliticsEventTypeRecordItemMoved:
            returnString = @"UserAction";
            break;
            
        case kAnaliticsEventTypeRecordItemRenamed:
            returnString = @"UserAction";
            break;
            
        case kAnaliticsEventTypeRecordItemDeleted:
            returnString = @"UserAction";
            break;
            
        default:
            break;
    }
    
    return returnString;
}

- (NSString*)stringForEventType:(AnaliticsEventTypes)eventType
{
    NSString* returnString = @"";

    switch (eventType)
    {
        case kAnaliticsEventTypePasswordShown:
            returnString = @"Lock screen shown";
            break;
        case kAnaliticsEventTypeFoldersShown:
            returnString = @"Folders screen shown";
            break;
            
        case kAnaliticsEventTypeRecordingsShown:
            returnString = @"Recording screen shown";
            break;
            
        case kAnaliticsEventTypeSettingsShown:
            returnString = @"Settings screen shown";
            break;
            
        case kAnaliticsEventTypeRecordItemSelected:
            returnString = @"Record item tapped";
            break;
            
        case kAnaliticsEventTypeInfoShown:
            returnString = @"Info screen shown";
            break;
            
        case kAnaliticsEventTypeShareShown:
            returnString = @"Share screen shown";
            break;
            
        case kAnaliticsEventTypeFolderCreated:
            returnString = @"Folder crated";
            break;
            
        case kAnaliticsEventTypeFolderRenamed:
            returnString = @"Folder renamed";
            break;
            
        case kAnaliticsEventTypeFolderDeleted:
            returnString = @"Folder deleted";
            break;
            
        case kAnaliticsEventTypeFolderReorder:
            returnString = @"Folder reordered";
            break;
            
        case kAnaliticsEventTypeRecordItemMoved:
            returnString = @"Record item moved";
            break;
            
        case kAnaliticsEventTypeRecordItemRenamed:
            returnString = @"Record item renamed";
            break;
            
        case kAnaliticsEventTypeRecordItemDeleted:
            returnString = @"Record item deleted";
            break;
            
        default:
            break;
    }
    
    return returnString;
}

#pragma mark - google tag manager delegate
#if TARGET_OS_IPHONE
//- (void)containerAvailable:(TAGContainer *)container {
//    // Note that containerAvailable may be called on any thread, so you may need to dispatch back to
//    // your main thread.
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.container = container;
//    });
//}
#endif
@end
