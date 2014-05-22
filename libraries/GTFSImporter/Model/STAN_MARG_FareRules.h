//
//  FareRules.h
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface STAN_MARG_FareRules : NSObject

@property (nonatomic, retain) NSString *fareId;
@property (nonatomic, retain) NSString *routeId;
@property (nonatomic, retain) NSString *originId;
@property (nonatomic, retain) NSString *destinationId;
@property (nonatomic, retain) NSString *containsId;

- (void)addFareRules:(STAN_MARG_FareRules *)value;
- (id)initWithDB:(FMDatabase *)fmdb;
- (void)cleanupAndCreate;
- (void)receiveRecord:(NSDictionary *)aRecord;

@end
