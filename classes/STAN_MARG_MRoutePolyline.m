//
//  MRoutePolyline.m
//  marguerite
//
//  Created by Kevin Conley on 8/26/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "STAN_MARG_MRoutePolyline.h"
#import "STAN_MARG_GTFSDatabase.h"
#import "STAN_MARG_MUtil.h"

@implementation STAN_MARG_MRoutePolyline

- (id) initWithRoute:(STAN_MARG_MRoute *)route
{
    if (route == nil) {
        [self release];
        return nil;
    }
    
    STAN_MARG_GTFSDatabase *db = nil;
    if ((db = [STAN_MARG_GTFSDatabase open]) == nil) {
        [self release];
        return nil;
    }
    
    // Create a yyyy-MM-dd date string for today's date
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *todaysDate = [dateFormat stringFromDate:[NSDate date]];
    
    // Create a HH:mm:ss time string for the current time
    NSDateFormatter *timeFormat = [[[NSDateFormatter alloc] init] autorelease];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    NSString *timeString = [timeFormat stringFromDate:[NSDate date]];
    
    // This SQLite query has 2 steps:
    // 1. Determine the next closest departure_time and its trip_id from stop_times for the given route and today's date and time.
    // 2. Grab the sequence of points from the shape table that corresponds to the trip from (1) for today's date and
    //    the departure_time from (1).
    NSString *shapeQuery = [NSString stringWithFormat:@"SELECT shape.shape_pt_lat, shape.shape_pt_lon FROM (SELECT trips.trip_id, stop_times.departure_time FROM trips, calendar_dates, stop_times WHERE trips.route_id=? AND stop_times.trip_id=trips.trip_id AND trips.service_id=calendar_dates.service_id AND calendar_dates.date=? AND time(stop_times.departure_time) > time(\'%@\') ORDER BY time(stop_times.departure_time) LIMIT 1) AS candidate, shape, trips, calendar_dates, stop_times WHERE trips.route_id=? AND trips.shape_id=shape.shape_id AND stop_times.trip_id=trips.trip_id AND trips.trip_id=candidate.trip_id AND trips.service_id=calendar_dates.service_id AND calendar_dates.date=? AND time(stop_times.departure_time)=candidate.departure_time ORDER BY CAST(shape.shape_pt_sequence AS INTEGER)", timeString];
    
    FMResultSet *shapeRS = [db executeQuery:shapeQuery withArgumentsInArray:@[route.routeId, todaysDate, route.routeId, todaysDate]];
    GMSMutablePath *points = [[[GMSMutablePath alloc] init] autorelease];
    while ([shapeRS next]) {
        CLLocationCoordinate2D point;
        point.latitude = [[shapeRS objectForColumnName:@"shape_pt_lat"] doubleValue];
        point.longitude = [[shapeRS objectForColumnName:@"shape_pt_lon"] doubleValue];
        [points addCoordinate:point];
        //NSUInteger sequenceNumber = [[shapeRS objectForColumnName:@"shape_pt_sequence"] integerValue];
        //[points insertCoordinate:point atIndex:(sequenceNumber - 1)];
    }

    [shapeRS close];
    [db close];
    
    if ((self = [super init])) {
        self.path = points;
        self.strokeWidth = 10.0;
        self.strokeColor = route.routeColor;
    }
    return self;
}

@end
