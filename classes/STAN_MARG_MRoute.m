//
//  MRoute.m
//  marguerite
//
//  Created by Kevin Conley on 7/20/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import "STAN_MARG_MRoute.h"
#import "STAN_MARG_GTFSDatabase.h"
#import "STAN_MARG_MUtil.h"

@implementation STAN_MARG_MRoute

- (void) dealloc {
    [_routeId release];
    [_routeShortName release];
    [_routeLongName release];
    [_routeUrl release];
    [_routeColor release];
    [_routeTextColor release];
    [super dealloc];
}

/*
 Return an MRoute object by looking up the route in the GTFS database. Returns nil if the route 
 does not exist.
 */
- (id) initWithRouteIdString:(NSString *) route_id
{
    if (route_id == nil) {
        return nil;
    }
    
    if ((self = [super init])) {
        STAN_MARG_GTFSDatabase *db = nil;
        if ((db = [STAN_MARG_GTFSDatabase open]) == nil) {
            [self release];
            return nil;
        }
        
        NSString *routesQuery = @"SELECT route_long_name, route_short_name, route_url, route_color, route_text_color FROM routes WHERE route_id=?";
        
        FMResultSet *routesRS = [db executeQuery:routesQuery withArgumentsInArray:@[route_id]];
        if ([routesRS next]) {
            _routeId = [route_id retain];
            _routeLongName = [[routesRS objectForColumnName:@"route_long_name"] retain];
            _routeShortName = [[routesRS objectForColumnName:@"route_short_name"] retain];
            _routeUrl = [[NSURL alloc] initWithString:[routesRS objectForColumnName:@"route_url"]];
            [self setColorUsingHexString:[routesRS objectForColumnName:@"route_color"]];
            [self setTextColorUsingHexString:[routesRS objectForColumnName:@"route_text_color"]];
        } else {
            [routesRS close];
            [db close];
            [self release];
            return nil;
        }
        
        [routesRS close];
        [db close];
    }
    return self;
}

/*
 Set the UIColor for the route's color using the hex string.
 */
- (void) setColorUsingHexString:(NSString *) hexString
{
    self.routeColor = [STAN_MARG_MUtil colorFromHexString:hexString];
}

/*
 Set the UIColor for the route's text color using a hex string.
 */
- (void) setTextColorUsingHexString:(NSString *) hexString
{
    self.routeTextColor = [STAN_MARG_MUtil colorFromHexString:hexString];
}

@end
