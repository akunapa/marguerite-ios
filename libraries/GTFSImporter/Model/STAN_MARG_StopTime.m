//
//  StopTime.m
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import "STAN_MARG_StopTime.h"
#import "STAN_MARG_Trip.h"
#import "FMDatabase.h"
#import "STAN_MARG_CSVParser.h"
#import "STAN_MARG_GTFSDatabase.h"

@interface STAN_MARG_StopTime ()
{
    ;
}

@property (nonatomic, retain) FMDatabase *db;

@end

@implementation STAN_MARG_StopTime

- (void) dealloc {
    [_arrivalTime release];
    [_departureTime release];
    [_stopSequence release];
    [_tripId release];
    [_stopId release];
    [_isTimepoint release];
    [_pickupType release];
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

- (NSSet *)getStopTimeObjects:(NSNumber *)stop_id {
    return nil;
}

- (void)addStopTime:(STAN_MARG_StopTime *)stopTime
{
    if (_db==nil) {
        self.db = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
        if (![_db open]) {
            NSLog(@"Could not open db.");
            return;
        }
    }
    
    [_db executeUpdate:@"INSERT into stop_times(trip_id,arrival_time,departure_time,stop_id,stop_sequence,pickup_type) values(?, ?, ?, ?, ?, ?)",
     stopTime.tripId,
     stopTime.arrivalTime,
     stopTime.departureTime,
     stopTime.stopId,
     stopTime.stopSequence,
     stopTime.pickupType];
    
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
    NSString *drop = @"DROP TABLE IF EXISTS stop_times";
    
    [_db executeUpdate:drop];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
    
    //Create table
    NSString *create = @"CREATE TABLE 'stop_times' ('trip_id' varchar(11) DEFAULT NULL, 'arrival_time' time DEFAULT NULL, 'departure_time' time DEFAULT NULL, 'stop_id' varchar(11) DEFAULT NULL, 'stop_sequence' int(11) DEFAULT NULL, 'is_timepoint' tinyint(1) DEFAULT NULL, 'pickup_type' varchar(11) DEFAULT NULL)";
    
    NSString *createIndex = @"CREATE INDEX stop_id_stop_times ON stop_times(stop_id)";
    NSString *createIndex1 = @"CREATE INDEX trip_id_stop_times ON stop_times(trip_id)";
    
    [_db executeUpdate:create];
    [_db executeUpdate:createIndex];
    [_db executeUpdate:createIndex1];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
}

- (void)receiveRecord:(NSDictionary *)aRecord
{
    STAN_MARG_StopTime *stopTimeRecord = [[[STAN_MARG_StopTime alloc] init] autorelease];
    stopTimeRecord.tripId = aRecord[@"trip_id"];
    stopTimeRecord.departureTime = aRecord[@"departure_time"];
    stopTimeRecord.arrivalTime = aRecord[@"arrival_time"];
    stopTimeRecord.stopId = aRecord[@"stop_id"];
    stopTimeRecord.stopSequence = aRecord[@"stop_sequence"];
    stopTimeRecord.pickupType = aRecord[@"pickup_type"];
    
    [self addStopTime:stopTimeRecord];
}

- (NSArray *)getStopsForTripId:(NSString *)tripId
{
    NSMutableArray *stops = [[[NSMutableArray alloc] init] autorelease];
    
    FMDatabase *localdb = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
    
    [localdb setShouldCacheStatements:YES];
    if (![localdb open]) {
        NSLog(@"Could not open db.");
        //[db release];
        return nil;
    }
    
    NSString *query = @"SELECT stop_id FROM stop_times WHERE trip_id=?";
    
    FMResultSet *rs = [localdb executeQuery:query, tripId];
    while ([rs next]) {
        [stops addObject:[rs stringForColumn:@"stop_id"]];
    }
    // close the result set.
    [rs close];
    [localdb close];
    
    //    NSLog(@"getStopTimesByTripId %d", [stop_times count]);
    return stops;
}

- (NSArray *)getStopTimesByTripId:(NSString *)tripId
{
    NSMutableArray *stop_times = [[[NSMutableArray alloc] init] autorelease];
    
    NSString *query = @"SELECT stops.stop_lat, stops.stop_lon, stop_times.trip_id, stop_times.arrival_time, stop_times.stop_id, stop_times.stop_sequence, stop_times.pickup_type FROM stop_times, stops WHERE stop_times.trip_id=? AND stops.stop_id=stop_times.stop_id ORDER BY stop_times.stop_sequence";
    
    FMResultSet *rs = [_db executeQuery:query, tripId];
    while ([rs next]) {
        // just print out what we've got in a number of formats.
        NSMutableDictionary *stop_time = [[[NSMutableDictionary alloc] init] autorelease];
        
        stop_time[@"stop_lat"] = [rs objectForColumnName:@"stop_lat"];
        stop_time[@"stop_lon"] = [rs objectForColumnName:@"stop_lon"];
        stop_time[@"stop_id"] = [rs objectForColumnName:@"stop_id"];
        stop_time[@"trip_id"] = [rs objectForColumnName:@"trip_id"];
        stop_time[@"arrival_time"] = [rs objectForColumnName:@"arrival_time"];
        stop_time[@"stop_sequence"] = [rs objectForColumnName:@"stop_sequence"];
        stop_time[@"pickup_type"] = [rs objectForColumnName:@"pickup_type"];
        
        [stop_times addObject:stop_time];
    }
    // close the result set.
    [rs close];
    //    NSLog(@"getStopTimesByTripId %d", [stop_times count]);
    return stop_times;
}

@end
