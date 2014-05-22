//
//  Trip.m
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import "STAN_MARG_Trip.h"
#import "FMDatabase.h"
#import "STAN_MARG_CSVParser.h"
#import "STAN_MARG_GTFSDatabase.h"

@interface STAN_MARG_Trip ()
{

}

@property (nonatomic, retain) FMDatabase *db;

@end

@implementation STAN_MARG_Trip


- (void) dealloc {
    [_tripHeadsign release];
    [_tripId release];
    [_routeId release];
    [_serviceId release];
    [_blockId release];
    [_shapeId release];
    [_directionId release];
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

- (void)addTrip:(STAN_MARG_Trip *)trip
{
    if (_db==nil) {
        self.db = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
        if (![_db open]) {
            NSLog(@"Could not open db.");
            return;
        }
    }
    
    [_db executeUpdate:@"INSERT into trips(block_id,route_id,direction_id,trip_headsign,service_id,shape_id,trip_id) values(?, ?, ?, ?, ?, ?, ?)",
     trip.blockId,
     trip.routeId,
     trip.directionId,
     trip.tripHeadsign,
     trip.serviceId,
     trip.shapeId,
     trip.tripId];
    
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
    NSString *drop = @"DROP TABLE IF EXISTS trips";
    
    [_db executeUpdate:drop];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
    
    //Create table
    NSString *create = @"CREATE TABLE 'trips' ('block_id' varchar(11) DEFAULT NULL, 'route_id' varchar(11) DEFAULT NULL, 'direction_id' tinyint(1) DEFAULT NULL, 'trip_headsign' varchar(255) DEFAULT NULL, 'service_id' varchar(11) DEFAULT NULL, 'shape_id' varchar(11) DEFAULT NULL, 'trip_id' varchar(11) NOT NULL, PRIMARY KEY ('trip_id'))";
    
    NSString *createIndex = @"CREATE INDEX route_id_trips ON trips(route_id)";
    
    [_db executeUpdate:create];
    [_db executeUpdate:createIndex];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
}

- (void)receiveRecord:(NSDictionary *)aRecord
{
    STAN_MARG_Trip *tripRecord = [[[STAN_MARG_Trip alloc] init] autorelease];
    tripRecord.blockId = aRecord[@"block_id"];
    tripRecord.routeId = aRecord[@"route_id"];
    tripRecord.directionId = aRecord[@"direction_id"];
    tripRecord.tripHeadsign = aRecord[@"trip_headsign"];
    tripRecord.serviceId = aRecord[@"service_id"];
    tripRecord.shapeId = aRecord[@"shape_id"];
    tripRecord.tripId = aRecord[@"trip_id"];
    
    [self addTrip:tripRecord];
}

- (NSArray *)getAllTripIds
{
    NSMutableArray *tripIds = [[[NSMutableArray alloc] init] autorelease];
    
    if (_db==nil) {
        self.db = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
        if (![_db open]) {
            NSLog(@"Could not open db.");
            self.db = nil;
            return nil;
        }
        
        _db.shouldCacheStatements=YES;
    }
    
    NSString *query = @"SELECT trip_id from trips";
    
    FMResultSet *rs = [_db executeQuery:query];
    while ([rs next]) {
        [tripIds addObject:[rs objectForColumnName:@"trip_id"]];
    }
    // close the result set.
    [rs close];
    [_db close];
    
    //    NSLog(@"getStopTimesByTripId %d", [stop_times count]);
    return tripIds;
}


@end
