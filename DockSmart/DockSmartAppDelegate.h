//
//  DockSmartAppDelegate.h
//  DockSmart
//
//  Created by John Penning on 4/30/13.
//  Copyright (c) 2013 John Penning. All rights reserved.
//

#import "DSHTTPSessionManager.h"
#import "LocationController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

extern NSString *const kAddStationsNotif;
extern NSString *const kStationResultsKey;
extern NSString *const kStationErrorNotif;
extern NSString *const kStationsMsgErrorKey;

extern NSString *const kAutoCityPreference;
extern NSString *const kCityPreference;
extern NSString *const kDisplayedVersion;

@class Station, DockSmartMapViewController;

@interface DockSmartAppDelegate : UIResponder <UIApplicationDelegate, UIStateRestoring>

@property(strong, nonatomic) UIWindow *window;

// The URL corresponding to the JSON station data for the currently selected city.
@property(nonatomic) NSString *currentCityUrl;

@end
