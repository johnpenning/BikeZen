//
//  NSDictionary+CityBikesAPI.m
//  DockSmart
//
//  NSDictionary categories for the City Bikes API, to pull the proper data from the NSDictionary output of AFNetworking
//  methods.
//
//  Created by John Penning on 12/14/13.
//  Copyright (c) 2013 John Penning. All rights reserved.
//

#import "DockSmartAppDelegate.h"
#import "NSDictionary+CityBikesAPI.h"
#import "define.h"

@implementation NSDictionary (CityBikesAPI)

- (NSInteger)stationID
{
    NSInteger n = [[self objectForKey:@"id"] integerValue];
    return n;
}

- (NSString *)name
{
    NSString *str = [self objectForKey:@"name"];

    // Match the "<integer> - " pattern at the beginning of a station name, in case the name is prefixed with a station
    // ID (we don't want to show these):  Updated 2/16/14: Boston Hubway uses "M<integer> - " pattern, so also match for
    // letter characters before the numbers
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[A-Z]*[0-9]+ - "
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];

    NSRange matchRange = [regex rangeOfFirstMatchInString:str options:0 range:NSMakeRange(0, [str length])];

    if (!NSEqualRanges(matchRange, NSMakeRange(NSNotFound, 0))) {
        return [str substringFromIndex:matchRange.length];
    } else {
        return str;
    }

#if 0
    //Take the first 8 characters out of the name, where the ID number is (for DC only... current API does not standardize this, so might have to make it city-specific for now):
    if ([[(DockSmartAppDelegate *)[[UIApplication sharedApplication] delegate] currentCityUrl] isEqualToString:CITY_URL_DC])
    {
        return [str stringByReplacingCharactersInRange:NSMakeRange(0, 8) withString:@""];
    }
    else
    {
        return str;
    }
#endif
}

- (CLLocationDegrees)lat
{
    // Latitude is represented in the JSON data as (degrees * 1e6); convert back
    CLLocationDegrees n = [[self objectForKey:@"lat"] integerValue] / 1e6;
    return n;
}

- (CLLocationDegrees)lng
{
    // Longitude is represented in the JSON data as (degrees * 1e6); convert back
    CLLocationDegrees n = [[self objectForKey:@"lng"] integerValue] / 1e6;
    return n;
}

- (NSInteger)bikes
{
    NSInteger n = [[self objectForKey:@"bikes"] integerValue];
    return n;
}

- (NSInteger)free
{
    NSInteger n = [[self objectForKey:@"free"] integerValue];
    return n;
}

- (NSDate *)timestamp
{
    // Convert textual data format to NSDate object
    NSString *str = [self objectForKey:@"timestamp"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.'SSSSSS"];
    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [df dateFromString:str];
    return date;
}

- (bool)installed
{
    bool n = [[self objectForKey:@"installed"] boolValue];
    return n;
}

- (bool)locked
{
    bool n = [[self objectForKey:@"locked"] boolValue];
    return n;
}

- (NSString *)url
{
    NSString *str = [self objectForKey:@"url"];
    return str;
}

@end
