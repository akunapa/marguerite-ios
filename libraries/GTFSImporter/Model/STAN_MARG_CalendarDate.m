//
//  CalendarDate.m
//
//  Created by Kevin Conley on 6/25/2013.
//

#import "STAN_MARG_CalendarDate.h"
#import "FMDatabase.h"
#import "STAN_MARG_CSVParser.h"
#import "STAN_MARG_GTFSDatabase.h"

@interface STAN_MARG_CalendarDate ()
{
}

@property (nonatomic, retain) FMDatabase *db;
@property (nonatomic, retain) NSDateFormatter *dateFormat;
@property (nonatomic, retain) NSDateFormatter *dateFormat2;


@end

@implementation STAN_MARG_CalendarDate

- (void) dealloc {
    [_serviceId release];
    [_date release];
    [_exceptionType release];
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

- (void)addCalendarDate:(STAN_MARG_CalendarDate *)calendarDate
{    
    if (_db==nil) {
        self.db = [FMDatabase databaseWithPath:[STAN_MARG_GTFSDatabase getNewAutoUpdateDatabaseBuildPath]];
        if (![_db open]) {
            NSLog(@"Could not open db.");
            return;
        }
    }
    
    [_db executeUpdate:@"INSERT into calendar_dates(service_id,date,exception_type) values(?, ?, ?)",
     calendarDate.serviceId,
     calendarDate.date,
     calendarDate.exceptionType];
    
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
    NSString *drop = @"DROP TABLE IF EXISTS calendar_dates";
    
    [_db executeUpdate:drop];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
    
    //Create table
    NSString *create = @"CREATE TABLE 'calendar_dates' ('service_id' varchar(20) NOT NULL,'date' date NOT NULL,'exception_type' tinyint(2) NOT NULL)";
    NSString *createIndex = @"CREATE INDEX service_id_calendar_dates ON calendar_dates(service_id)";
    
    [_db executeUpdate:create];
    [_db executeUpdate:createIndex];
    
    if ([_db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        return;
    }
}

- (void)receiveRecord:(NSDictionary *)aRecord
{
    
    STAN_MARG_CalendarDate *calendarDateRecord = [[[STAN_MARG_CalendarDate alloc] init] autorelease];
    calendarDateRecord.serviceId = aRecord[@"service_id"];
    calendarDateRecord.exceptionType = aRecord[@"exception_type"];
    //Date format is wrong, so correct it now
    calendarDateRecord.date = [_dateFormat2 stringFromDate:[_dateFormat dateFromString:aRecord[@"date"]]];
    
    [self addCalendarDate:calendarDateRecord];
}


@end
