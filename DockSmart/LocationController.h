//
//  LocationController.h
//  DockSmart
//
//  Singleton CLLocationManagerDelegate class.
//
//  Created by John Penning on 9/14/13.
//  Copyright (c) 2013 John Penning. All rights reserved.
//

#import "DockSmartLogViewController.h"
#import "DockSmartMapViewController.h"
#import "LocationDataController.h"
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Notification key for location updates
extern NSString *const kLocationUpdateNotif;
// userInfo key for new location data
extern NSString *const kNewLocationKey;
// Notification key for geofence entry
extern NSString *const kRegionEntryNotif;
// Notification key for geofence exit
extern NSString *const kRegionExitNotif;
// userInfo key for geofence data
extern NSString *const kNewRegionKey;

@interface LocationController : NSObject <CLLocationManagerDelegate>

// current user location
@property(nonatomic, strong) CLLocation *location;
// delegate for the CLLocationManagerDelegate protocol methods
@property(nonatomic, weak) id delegate;

// Starts location updates
- (void)startUpdatingCurrentLocation;
// Stops location updates
- (void)stopUpdatingCurrentLocation;
// Starts significant location change monitoring
- (void)startMonitoringSignificantLocationChanges;
// Stops significant location change monitoring
- (void)stopMonitoringSignificantLocationChanges;
// Register a geofence
- (BOOL)registerRegionWithCoordinate:(CLLocationCoordinate2D)coordinate
                              radius:(CLLocationDistance)radius
                          identifier:(NSString *)identifier
                            accuracy:(CLLocationAccuracy)accuracy;
// Turn off all geofences
- (void)stopAllRegionMonitoring;

// Singleton method
+ (LocationController *)sharedInstance;

@end
