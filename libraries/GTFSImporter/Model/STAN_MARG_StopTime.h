//
//  StopTime.h
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface STAN_MARG_StopTime : NSObject

@property (nonatomic, retain) NSString *arrivalTime;
@property (nonatomic, retain) NSString *departureTime;
@property (nonatomic, retain) NSNumber *stopSequence;
@property (nonatomic, retain) NSString *tripId;
@property (nonatomic, retain) NSString *stopId;
@property (nonatomic, retain) NSNumber *isTimepoint;
@property (nonatomic, retain) NSNumber *pickupType;

- (void)addStopTime:(STAN_MARG_StopTime *)stopTime;
- (id)initWithDB:(FMDatabase *)fmdb;
- (void)cleanupAndCreate;
- (void)receiveRecord:(NSDictionary *)aRecord;
- (NSArray *)getStopsForTripId:(NSString *)tripId;
- (NSArray *)getStopTimesByTripId:(NSString *)tripId;

@end