//
//  Stop.m
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import "STAN_MARG_Stop.h"
#import "FMDatabase.h"
#import "STAN_MARG_CSVParser.h"
#import "STAN_MARG_Route.h"
#import "STAN_MARG_StopTime.h"
#import "STAN_MARG_GTFSDatabase.h"

@interface STAN_MARG_Stop ()
{
 
}

@property (nonatomic, retain) FMDatabase *db;

@end

@implementation STAN_MARG_Stop

- (void) dealloc {
    [_stopLat release];
    [_stopLon release];
    [_stopId release];
    [_stopName release];
    [_stopDesc release];
    [_locationType release];
    [_zoneId release];
    [_routes release];
    [_db release];
    [super dealloc];
}

- (id)initWithDB:(FMDatabase *)fmdb
{
    self = [super init];
	if (self)
	{
 		_db = [fmdb retain];
	}
	return self;
}

- (void)addStop:(STAN_MARG_Stop *)stop
{
    if (_db==nil) {
        self.db = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
        if (![_db open]) {
            NSLog(@"Could not open db.");
            return;
        }
    }
    
    [_db executeUpdate:@"INSERT into stops(stop_lat,zone_id,stop_lon,stop_id,stop_desc,stop_name,location_type) values(?, ?, ?, ?, ?, ?, ?)",
     stop.stopLat,
     stop.zoneId,
     stop.stopLon,
     stop.stopId,
     stop.stopDesc,
     stop.stopName,
     stop.locationType];
    
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
    NSString *drop = @"DROP TABLE IF EXISTS stops";
    
    [_db executeUpdate:drop];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
    
    //Create table
    NSString *create = @"CREATE TABLE 'stops' ('stop_lat' decimal(8,6) DEFAULT NULL, 'zone_id' varchar(11) DEFAULT NULL, 'stop_lon' decimal(9,6) DEFAULT NULL, 'stop_id' varchar(11) NOT NULL, 'stop_desc' varchar(255) DEFAULT NULL, 'stop_name' varchar(255) DEFAULT NULL, 'location_type' int(2) DEFAULT NULL, 'routes' varchar(255) DEFAULT NULL, PRIMARY KEY ('stop_id'))";
    
    NSString *createIndex = @"CREATE INDEX stop_lat_lon_stops ON stops(stop_lat, stop_lon)";
    
    [_db executeUpdate:create];
    [_db executeUpdate:createIndex];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
}

- (void)receiveRecord:(NSDictionary *)aRecord
{
    STAN_MARG_Stop *stopRecord = [[[STAN_MARG_Stop alloc] init] autorelease];
    stopRecord.stopId = aRecord[@"stop_id"];
    stopRecord.stopLat = aRecord[@"stop_lat"];
    stopRecord.stopLon = aRecord[@"stop_lon"];
    stopRecord.stopName = aRecord[@"stop_name"];
    stopRecord.stopDesc = aRecord[@"stop_desc"];
    stopRecord.zoneId = aRecord[@"zone_id"];
    stopRecord.locationType = aRecord[@"location_type"];
    
    [self addStop:stopRecord];
}

- (void)updateStopWithRoutes:(NSArray *)route withStopId:(NSString *)stopId
{
    if (_db==nil) {
        self.db = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
        if (![_db open]) {
            NSLog(@"Could not open db.");
            return;
        }
    }
    
    NSString *routeString = [route componentsJoinedByString:@","];
    
    [_db executeUpdate:@"UPDATE stops SET routes=? where stop_id=?",
     routeString,
     stopId];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
}

- (void)updateRoutes
{
    @autoreleasepool {
        NSMutableDictionary *stopWithRoutes = [[[NSMutableDictionary alloc] init] autorelease];
        //First get all unique route trips
        STAN_MARG_Route *route = [[[STAN_MARG_Route alloc] init] autorelease];
        NSArray *routeArray = [route getAllRoutes];
        STAN_MARG_StopTime *stopTime = [[[STAN_MARG_StopTime alloc] init] autorelease];
        
        for (NSDictionary *route in routeArray) {
            NSArray *stops = [stopTime getStopsForTripId:route[@"trip_id"]];
            for (NSString *stopId in stops) {
                if (stopWithRoutes[stopId]==nil) {
                    [stopWithRoutes setValue:[[[NSMutableArray alloc] init] autorelease] forKey:stopId];
                }
                if ([stopWithRoutes[stopId] containsObject:route[@"route_id"]] == NO) {
                    [stopWithRoutes[stopId] addObject:route[@"route_id"]];
                }
            }
        }
        
        
 //   NSLog(@"%@, %lu", stopWithRoutes, [stopWithRoutes count]);
        
        for (NSString *key in [stopWithRoutes allKeys]) {
//        NSLog(@"%@ - %@", key, [[stopWithRoutes objectForKey:key] componentsJoinedByString:@","]);
            [self updateStopWithRoutes:stopWithRoutes[key] withStopId:key];
        }
    }
}

+ (NSArray *)getAllStops
{
    
    NSMutableArray *stops = [[[NSMutableArray alloc] init] autorelease];
    
    FMDatabase *localdb = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
    
    [localdb setShouldCacheStatements:YES];
    if (![localdb open]) {
        NSLog(@"Could not open db.");
        //[db release];
        return nil;
    }
    
    NSString *query = @"select stop_id, stop_name, stop_lat, stop_lon, routes FROM stops";
    
    FMResultSet *rs = [localdb executeQuery:query];
    while ([rs next]) {
        NSMutableDictionary *stop = [[[NSMutableDictionary alloc] init] autorelease];
        stop[@"stop_id"] = [rs objectForColumnName:@"stop_id"];
        stop[@"stop_name"] = [rs objectForColumnName:@"stop_name"];
        stop[@"stop_lat"] = [rs objectForColumnName:@"stop_lat"];
        stop[@"stop_lon"] = [rs objectForColumnName:@"stop_lon"];
        stop[@"routes"] = [rs objectForColumnName:@"routes"];
        
        [stops addObject:stop];
    }
    // close the result set.
    [rs close];
    [localdb close];
    
    return stops;
}

@end
