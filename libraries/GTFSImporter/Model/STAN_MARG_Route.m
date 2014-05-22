//
//  Route.m
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import "STAN_MARG_Route.h"
#import "STAN_MARG_CSVParser.h"
#import "FMDatabase.h"
#import "STAN_MARG_GTFSDatabase.h"

@interface STAN_MARG_Route ()
{
}

@property (nonatomic, retain) FMDatabase *db;

@end

@implementation STAN_MARG_Route

- (void) dealloc {
    [_routeLongName release];
    [_routeType release];
    [_routeId release];
    [_routeShortName release];
    [_routeUrl release];
    [_routeColor release];
    [_routeTextColor release];
    [_agencyId release];
    [_db release];
    [super dealloc];
}

- (id) initWithDB:(FMDatabase *)fmdb
{
    self = [super init];
	if (self)
	{
		_db = [fmdb retain];
	}
	return self;
}

- (void)addRoute:(STAN_MARG_Route *)route
{
    if (_db==nil) {
        self.db = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
        if (![_db open]) {
            NSLog(@"Could not open db.");
            return;
        }
    }
    
    [_db executeUpdate:@"INSERT into routes(route_long_name,route_type,agency_id,route_id,route_short_name,route_url,route_color,route_text_color) values(?, ?, ?, ?, ?, ?, ?, ?)",
     route.routeLongName,
     route.routeType,
     route.agencyId,
     route.routeId,
     route.routeShortName,
     route.routeUrl,
     route.routeColor,
     route.routeTextColor];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
}

- (void)cleanupAndCreate
{
    if (_db==nil) {
        self.db = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
        if (![_db open]) {
            NSLog(@"Could not open db.");
            return;
        }
    }
    
    //Drop table if it exists
    NSString *drop = @"DROP TABLE IF EXISTS routes";
    
    [_db executeUpdate:drop];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
    
    //Create table
    NSString *create = @"CREATE TABLE 'routes' ('route_long_name' varchar(255) DEFAULT NULL,'route_type' int(2) DEFAULT NULL, 'agency_id' varchar(11) DEFAULT NULL, 'route_id' varchar(11) NOT NULL, 'route_short_name' varchar(50) DEFAULT NULL, 'route_url' varchar(255) DEFAULT NULL, 'route_color' char(6) DEFAULT 'FFFFFF', 'route_text_color' char(6) DEFAULT '000000', PRIMARY KEY ('route_id'))";
    
    [_db executeUpdate:create];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
}

- (void)receiveRecord:(NSDictionary *)aRecord
{
    STAN_MARG_Route *routeRecord = [[[STAN_MARG_Route alloc] init] autorelease];
    routeRecord.routeId = aRecord[@"route_id"];
    routeRecord.routeLongName = aRecord[@"route_long_name"];
    routeRecord.routeShortName = aRecord[@"route_short_name"];
    routeRecord.routeType = aRecord[@"route_type"];
    routeRecord.agencyId = aRecord[@"agency_id"];
    routeRecord.routeUrl = aRecord[@"route_url"];
    routeRecord.routeColor = aRecord[@"route_color"];
    routeRecord.routeTextColor = aRecord[@"route_text_color"];
    
    [self addRoute:routeRecord];
}

- (NSArray *)getAllRoutes
{
    
    NSMutableArray *routes = [[[NSMutableArray alloc] init] autorelease];
    
    FMDatabase *localdb = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
    
    [localdb setShouldCacheStatements:YES];
    if (![localdb open]) {
        NSLog(@"Could not open db.");
        //[db release];
        return nil;
    }
    
    NSString *query = @"select routes.route_short_name, trips.route_id, trips.trip_headsign, trips.trip_id FROM routes, trips WHERE trips.route_id=routes.route_id";
    
    FMResultSet *rs = [localdb executeQuery:query];
    while ([rs next]) {
        // just print out what we've got in a number of formats.
        NSMutableDictionary *route = [[[NSMutableDictionary alloc] init] autorelease];
        route[@"route_id"] = [rs objectForColumnName:@"route_id"];
        route[@"trip_headsign"] = [rs objectForColumnName:@"trip_headsign"];
        route[@"trip_id"] = [rs objectForColumnName:@"trip_id"];
        route[@"route_short_name"] = [rs objectForColumnName:@"route_short_name"];
        
        
        [routes addObject:route];
        
    }
    // close the result set.
    [rs close];
    [localdb close];
    
    return routes;
    
}


@end
