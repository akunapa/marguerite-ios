//
//  Trip.h
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface STAN_MARG_Trip : NSObject

@property (nonatomic, retain) NSString *tripHeadsign;
@property (nonatomic, retain) NSString *tripId;
@property (nonatomic, retain) NSString *routeId;
@property (nonatomic, retain) NSString *serviceId;
@property (nonatomic, retain) NSString *blockId;
@property (nonatomic, retain) NSString *shapeId;
@property (nonatomic, retain) NSNumber *directionId;

- (void)addTrip:(STAN_MARG_Trip *)trip;
- (id)initWithDB:(FMDatabase *)fmdb;
- (void)cleanupAndCreate;
- (void)receiveRecord:(NSDictionary *)aRecord;
- (NSArray *)getAllTripIds;

@end
