//
//  Stop.h
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import <CoreLocation/CoreLocation.h>

@interface STAN_MARG_Stop : NSObject

@property (nonatomic, retain) NSNumber * stopLat;
@property (nonatomic, retain) NSNumber * stopLon;
@property (nonatomic, retain) NSString * stopId;
@property (nonatomic, retain) NSString * stopName;
@property (nonatomic, retain) NSString * stopDesc;
@property (nonatomic, retain) NSNumber * locationType;
@property (nonatomic, retain) NSString * zoneId;
@property (nonatomic, retain) NSArray  * routes;

- (void)addStop:(STAN_MARG_Stop *)stop;
- (id)initWithDB:(FMDatabase *)fmdb;
- (void)cleanupAndCreate;
- (void)receiveRecord:(NSDictionary *)aRecord;
- (void)updateStopWithRoutes:(NSArray *)routes withStopId:(NSString *)stopId;
- (void)updateRoutes;
+ (NSArray *)getAllStops;

@end
