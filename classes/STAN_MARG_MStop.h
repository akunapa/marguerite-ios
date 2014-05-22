//
//  MStop.h
//  marguerite
//
//  Created by Kevin Conley on 7/23/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface STAN_MARG_MStop : NSObject <NSCoding>

@property (nonatomic, retain) CLLocation * location;
@property (nonatomic, retain) NSString * stopId;
@property (nonatomic, retain) NSString * stopName;
@property (nonatomic, retain) NSString * routesString;
@property double milesAway;

- (id) initWithStopId:(NSString *)stop_id;
- (BOOL) isFavoriteStop;
+ (NSMutableArray *) getFavoriteStops;
+ (void) setFavoriteStops:(NSArray *)stops;
+ (NSArray *) getAllStops;
+ (NSArray *)getClosestStops:(int)numStops withLocation:(CLLocation *)location;

@end
