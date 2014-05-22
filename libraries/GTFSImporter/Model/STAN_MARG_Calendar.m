//
//  Calendar.m
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import "STAN_MARG_Calendar.h"
#import "FMDatabase.h"
#import "STAN_MARG_CSVParser.h"
#import "STAN_MARG_GTFSDatabase.h"

@interface STAN_MARG_Calendar ()
{
}

@property (nonatomic, retain) FMDatabase *db;
@property (nonatomic, retain) NSDateFormatter *dateFormat;
@property (nonatomic, retain) NSDateFormatter *dateFormat2;


@end

@implementation STAN_MARG_Calendar

- (void) dealloc {
    [_endDate release];
    [_friday release];
    [_monday release];
    [_saturday release];
    [_serviceId release];
    [_startDate release];
    [_sunday release];
    [_thursday release];
    [_tuesday release];
    [_wednesday release];
    [_db release];
    [_dateFormat release];
    [_dateFormat2 release];
    [super dealloc];
}

- (id)initWithDB:(FMDatabase *)fmdb
{
    self = [super init];
	if (self)
	{
		_db = [fmdb retain];
        _dateFormat = [[NSDateFormatter alloc] init];
        [_dateFormat setDateFormat:@"yyyyMMdd"];
        _dateFormat2 = [[NSDateFormatter alloc] init];
        [_dateFormat2 setDateFormat:@"yyyy-MM-dd"];
	}
	return self;
}

- (void)addCalendar:(STAN_MARG_Calendar *)calendar
{
//    NSLog(@"Calendar %@, %@", calendar.start_date, calendar.end_date);
    
    if (_db==nil) {
        self.db = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
        if (![_db open]) {
            NSLog(@"Could not open db.");
            return;
        }
    }
    
    [_db executeUpdate:@"INSERT into calendar(end_date, friday, monday, saturday, service_id, start_date, sunday, thursday, tuesday, wednesday) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
     calendar.endDate,
     calendar.friday,
     calendar.monday,
     calendar.saturday,
     calendar.serviceId,
     calendar.startDate,
     calendar.sunday,
     calendar.thursday,
     calendar.tuesday,
     calendar.wednesday];
    
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
    NSString *drop = @"DROP TABLE IF EXISTS calendar";
    
    [_db executeUpdate:drop];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
    
    //Create table
    NSString *create = @"CREATE TABLE 'calendar' ('service_id' varchar(20) DEFAULT NULL,'start_date' date DEFAULT NULL,'end_date' date DEFAULT NULL,'monday' tinyint(1) DEFAULT NULL,'tuesday' tinyint(1) DEFAULT NULL,'wednesday' tinyint(1) DEFAULT NULL,'thursday' tinyint(1) DEFAULT NULL,'friday' tinyint(1) DEFAULT NULL,'saturday' tinyint(1) DEFAULT NULL,'sunday' tinyint(1) DEFAULT NULL)";
    NSString *createIndex = @"CREATE INDEX service_id_calendar ON calendar(service_id)";
    
    [_db executeUpdate:create];
    [_db executeUpdate:createIndex];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
}

- (void)receiveRecord:(NSDictionary *)aRecord
{
    
    STAN_MARG_Calendar *calendarRecord = [[[STAN_MARG_Calendar alloc] init] autorelease];
    calendarRecord.serviceId = aRecord[@"service_id"];
    calendarRecord.sunday = aRecord[@"sunday"];
    calendarRecord.monday = aRecord[@"monday"];
    calendarRecord.tuesday = aRecord[@"tuesday"];
    calendarRecord.wednesday = aRecord[@"wednesday"];
    calendarRecord.thursday = aRecord[@"thursday"];
    calendarRecord.friday = aRecord[@"friday"];
    calendarRecord.saturday = aRecord[@"saturday"];
    //Date format is wrong, so correct it now
    calendarRecord.startDate = [_dateFormat2 stringFromDate:[_dateFormat dateFromString:aRecord[@"start_date"]]];
    calendarRecord.endDate = [_dateFormat2 stringFromDate:[_dateFormat dateFromString:aRecord[@"end_date"]]];
    
    [self addCalendar:calendarRecord];
}


@end
