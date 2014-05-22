//
//  Route.h
//  GTFS-VTA
//
//  Created by Vashishtha Jogi on 7/31/11.
//  Copyright (c) 2011 Vashishtha Jogi Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface STAN_MARG_Route : NSObject

@property (nonatomic, retain) NSString * routeLongName;
@property (nonatomic, retain) NSNumber * routeType;
@property (nonatomic, retain) NSString * routeId;
@property (nonatomic, retain) NSString * routeShortName;
@property (nonatomic, retain) NSString * routeUrl;
@property (nonatomic, retain) NSString * routeColor;
@property (nonatomic, retain) NSString * routeTextColor;
@property (nonatomic, retain) NSString * agencyId;


- (void)addRoute:(STAN_MARG_Route *)route;
- (id)initWithDB:(FMDatabase *)fmdb;
- (void)cleanupAndCreate;
- (void)receiveRecord:(NSDictionary *)aRecord;
- (NSArray *)getAllRoutes;

@end
