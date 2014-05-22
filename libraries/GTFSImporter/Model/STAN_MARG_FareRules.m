//
//  FareRules.m
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import "STAN_MARG_FareRules.h"
#import "STAN_MARG_CSVParser.h"
#import "FMDatabase.h"
#import "STAN_MARG_GTFSDatabase.h"

@interface STAN_MARG_FareRules ()
{
}

@property (nonatomic, retain) FMDatabase *db;

@end

@implementation STAN_MARG_FareRules

- (void) dealloc {
    [_fareId release];
    [_routeId release];
    [_originId release];
    [_destinationId release];
    [_containsId release];
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

- (void)addFareRules:(STAN_MARG_FareRules *)value {
    if (_db==nil) {
        self.db = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
        if (![_db open]) {
            NSLog(@"Could not open db.");
            return;
        }
    }
    
    [_db executeUpdate:@"INSERT into fare_rules(fare_id,route_id,origin_id,destination_id,contains_id) values(?, ?, ?, ?, ?)",
     value.fareId,
     value.routeId,
     value.originId,
     value.destinationId,
     value.containsId];
    
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
    NSString *drop = @"DROP TABLE IF EXISTS fare_rules";
    
    [_db executeUpdate:drop];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
    
    //Create table
    NSString *create = @"CREATE TABLE 'fare_rules' ('fare_id' varchar(11) NOT NULL, 'route_id' varchar(11) NOT NULL, 'origin_id' varchar(11) NOT NULL, 'destination_id' varchar(11) NOT NULL, 'contains_id' varchar(11) NOT NULL)";
    
    [_db executeUpdate:create];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
}

- (void)receiveRecord:(NSDictionary *)aRecord
{
    STAN_MARG_FareRules *fareRulesRecord = [[[STAN_MARG_FareRules alloc] init] autorelease];
    fareRulesRecord.fareId = aRecord[@"fare_id"];
    fareRulesRecord.routeId = aRecord[@"route_id"];
    fareRulesRecord.originId = aRecord[@"origin_id"];
    fareRulesRecord.destinationId = aRecord[@"destination_id"];
    fareRulesRecord.containsId = aRecord[@"contains_id"];
    
    [self addFareRules:fareRulesRecord];
}


@end
