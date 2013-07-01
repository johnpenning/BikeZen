//
//  DockSmartAppDelegate.m
//  DockSmart
//
//  Created by John Penning on 4/30/13.
//  Copyright (c) 2013 John Penning. All rights reserved.
//

#import "DockSmartAppDelegate.h"
#import "Station.h"
#import "ParseOperation.h"
#import "DockSmartMapViewController.h"

#pragma mark DockSmartAppDelegate ()

// forward declarations
@interface DockSmartAppDelegate ()

//@property (strong, nonatomic) NSURLConnection *earthquakeFeedConnection;
@property (strong, nonatomic) NSMutableData *stationXMLData;    // the data returned from the NSURLConnection (or from initDataWithURL)
@property (strong, nonatomic) NSOperationQueue *parseQueue;     // the queue that manages our NSOperation for parsing station data

- (void)addStationsToList:(NSArray *)stations;
- (void)handleError:(NSError *)error;
- (void)loadXMLData;
- (void)refreshStationData;
@end


#pragma mark -
#pragma mark DockSmartAppDelegate

@implementation DockSmartAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //Begin location service
    _userCoordinate = kCLLocationCoordinate2DInvalid;
    [self startUpdatingCurrentLocation];
    
//    self.parseQueue = [NSOperationQueue new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addStations:)
                                                 name:kAddStationsNotif
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stationError:)
                                                 name:kStationErrorNotif
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshStationData:)
                                                 name:kRefreshTappedNotif
                                               object:nil];
    
    // Spawn an NSOperation to parse the earthquake data so that the UI is not blocked while the
    // application parses the XML data.
    //
    // IMPORTANT! - Don't access or affect UIKit objects on secondary threads.
    //
//    ParseOperation *parseOperation = [[ParseOperation alloc] init];
//    [self.parseQueue addOperation:parseOperation];
//    
//    // stationXMLData will be retained by the NSOperation until it has finished executing,
//    // so we no longer need a reference to it in the main thread.
//    self.stationXMLData = nil;
    
    [self loadXMLData];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // TODO: Reload the station data?
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Handle errors in the download by showing an alert to the user. This is a very
// simple way of handling the error, partly because this application does not have any offline
// functionality for the user. Most real applications should handle the error in a less obtrusive
// way and provide offline functionality to the user.
//
- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:
     NSLocalizedString(@"Error Title",
                       @"Title for alert displayed when download or parse error occurs.")
                               message:errorMessage
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alertView show];
}

// Our NSNotification callback from the running NSOperation to add the earthquakes
//
- (void)addStations:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    [self addStationsToList:[[notif userInfo] valueForKey:kStationResultsKey]];
}

// Our NSNotification callback from the running NSOperation when a parsing error has occurred
//
- (void)stationError:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    [self handleError:[[notif userInfo] valueForKey:kStationsMsgErrorKey]];
}

// The NSOperation "ParseOperation" calls addStations: via NSNotification, on the main thread
// which in turn calls this method, with batches of parsed objects.
// The batch size is set via the kSizeOfEarthquakeBatch constant.
//
- (void)addStationsToList:(NSArray *)stations {
    
    // insert the earthquakes into our mapViewController's data source (for KVO purposes)
//    [self.rootViewController insertEarthquakes:earthquakes];
    
    //Insert stations in .plist file for displaying in the Destinations view later.
//    NSString* plistPath = nil;
//    NSFileManager* manager = [NSFileManager defaultManager];
//    if ((plistPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Supporting Files/stationData.plist"]))
//    {
//        if ([manager isWritableFileAtPath:plistPath])
//        {
//            NSMutableDictionary* infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
//            [infoDict setObject:@"foo object" forKey:@"fookey"];
//            [infoDict writeToFile:plistPath atomically:NO];
//            [manager setAttributes:[NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate] ofItemAtPath:[[NSBundle mainBundle] bundlePath] error:nil];
//        }
//    }
    
    //This will in turn add the stations to the map.
    UIViewController *controller = (UIViewController*)self.window.rootViewController;
    //TODO: the following line is super dangerous and dumb as implemented.  Please change! (use Notifs?)
    [controller.childViewControllers[0] insertStations:stations];
//    DockSmartMapViewController *mapViewController = (DockSmartMapViewController *)self.window.rootViewController.childViewControllers[0];
//    [mapViewController.dataController addStationListObjectsFromArray:stations];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kAddStationsNotif
//                                                        object:self
//                                                      userInfo:[NSDictionary dictionaryWithObject:stations
//                                                                                           forKey:kStationResultsKey]];

    
}

- (void)loadXMLData
{
    self.parseQueue = [NSOperationQueue new];
    
    ParseOperation *parseOperation = [[ParseOperation alloc] init];
    [self.parseQueue addOperation:parseOperation];
    
    // stationXMLData will be retained by the NSOperation until it has finished executing,
    // so we no longer need a reference to it in the main thread.
    self.stationXMLData = nil;

}

- (void)refreshStationData:(NSNotification *)notif
{
    assert([NSThread isMainThread]);
    
    [self loadXMLData];
}

#pragma mark - CLLocationManagerDelegate

- (void)startUpdatingCurrentLocation
{
    // if location services are restricted do nothing
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        return;
    }
    
    // if locationManager does not currently exist, create it
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        _locationManager.distanceFilter = 10.0f; // we don't need to be any more accurate than 10m
//        _locationManager.purpose = @"This will be used as part of the hint region for forward geocoding.";
    }
    
    [_locationManager startUpdatingLocation];
    
//    [self showCurrentLocationSpinner:YES];
}

- (void)stopUpdatingCurrentLocation
{
    [_locationManager stopUpdatingLocation];
    
//    [self showCurrentLocationSpinner:NO];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //TODO: make current location button inactive on mapview
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//    // if the location is older than 30s ignore
//    if (fabs([newLocation.timestamp timeIntervalSinceDate:[NSDate date]]) > 30)
//    {
//        return;
//    }
//    
//    _selectedCoordinate = [newLocation coordinate];
//    
//    // update the current location cells detail label with these coords
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"φ:%.4F, λ:%.4F", _selectedCoordinate.latitude, _selectedCoordinate.longitude];
//    
//    // after recieving a location, stop updating
//    [self stopUpdatingCurrentLocation];
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // if the location is older than 30s ignore
    if (fabs([[manager location].timestamp timeIntervalSinceNow]) > 30)
    {
        return;
    }
    
    _userCoordinate = [(CLLocation *)[locations lastObject] coordinate];
    
    NSLog(@"Last location: %@", [locations lastObject]);
    
    [self stopUpdatingCurrentLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    
    // stop updating
    [self stopUpdatingCurrentLocation];
    
    // since we got an error, set selected location to invalid location
    _userCoordinate = kCLLocationCoordinate2DInvalid;
    
    // show the error alert
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"Error obtaining location";
    alert.message = [error localizedDescription];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}


@end
