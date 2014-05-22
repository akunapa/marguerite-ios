//
//  CalendarDate.h
//
//  Created by Kevin Conley on 6/25/2013.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"


@interface STAN_MARG_CalendarDate : NSObject

@property (nonatomic, retain) NSString * serviceId;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * exceptionType;

- (id)initWithDB:(FMDatabase *)fmdb;
- (void)addCalendarDate:(STAN_MARG_CalendarDate *)calendarDate;
- (void)cleanupAndCreate;
- (void)receiveRecord:(NSDictionary *)aRecord;

@end
