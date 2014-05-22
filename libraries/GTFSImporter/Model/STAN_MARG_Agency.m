//
//  Agency.m
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import "STAN_MARG_Agency.h"
#import "STAN_MARG_CSVParser.h"
#import "FMDatabase.h"
#import "STAN_MARG_GTFSDatabase.h"

@interface STAN_MARG_Agency ()
{

}

@property (nonatomic, retain) FMDatabase *db;

@end

@implementation STAN_MARG_Agency

- (void) dealloc {
    [_agencyId release];
    [_agencyName release];
    [_agencyUrl release];
    [_agencyTimezone release];
    [_agencyLang release];
    [_agencyPhone release];
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

- (void)addAgency:(STAN_MARG_Agency *)agency
{
    if (_db==nil) {
        self.db = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
        if (![_db open]) {
            NSLog(@"Could not open db.");
            return;
        }
    }
    
    [_db executeUpdate:@"INSERT into agency(agency_id, agency_name, agency_url, agency_timezone, agency_lang, agency_phone) values(?, ?, ?, ?, ?, ?)",
                        agency.agencyId,
                        agency.agencyName,
                        agency.agencyUrl,
                        agency.agencyTimezone,
                        agency.agencyLang,
                        agency.agencyPhone];
    
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
    NSString *dropAgency = @"DROP TABLE IF EXISTS agency";
    
    [_db executeUpdate:dropAgency];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
    
    //Create table
    NSString *createAgency = @"CREATE TABLE 'agency' ('agency_url' varchar(255) DEFAULT NULL, 'agency_name' varchar(255) DEFAULT NULL, 'agency_timezone' varchar(50) DEFAULT NULL, 'agency_lang' char(2) DEFAULT NULL, 'agency_phone' varchar(50) DEFAULT NULL, 'agency_id' varchar(50) DEFAULT NULL)";
    
    [_db executeUpdate:createAgency];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
}

- (void)receiveRecord:(NSDictionary *)aRecord
{
    
    STAN_MARG_Agency *agencyRecord = [[[STAN_MARG_Agency alloc] init] autorelease];
    agencyRecord.agencyId = aRecord[@"agency_id"];
    agencyRecord.agencyName = aRecord[@"agency_name"];
    agencyRecord.agencyUrl = aRecord[@"agency_url"];
    agencyRecord.agencyTimezone = aRecord[@"agency_timezone"];
    agencyRecord.agencyLang = aRecord[@"agency_lang"];
    agencyRecord.agencyPhone = aRecord[@"agency_phone"];
    
    [self addAgency:agencyRecord];
}



@end
