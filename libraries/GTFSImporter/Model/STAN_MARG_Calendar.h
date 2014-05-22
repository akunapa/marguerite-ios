//
//  Calendar.h
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"


@interface STAN_MARG_Calendar : NSObject

@property (nonatomic, retain) NSString * endDate;
@property (nonatomic, retain) NSString * friday;
@property (nonatomic, retain) NSString * monday;
@property (nonatomic, retain) NSString * saturday;
@property (nonatomic, retain) NSString * serviceId;
@property (nonatomic, retain) NSString * startDate;
@property (nonatomic, retain) NSString * sunday;
@property (nonatomic, retain) NSString * thursday;
@property (nonatomic, retain) NSString * tuesday;
@property (nonatomic, retain) NSString * wednesday;

- (id)initWithDB:(FMDatabase *)fmdb;
- (void)addCalendar:(STAN_MARG_Calendar *)calendar;
- (void)cleanupAndCreate;
- (void)receiveRecord:(NSDictionary *)aRecord;

@end
