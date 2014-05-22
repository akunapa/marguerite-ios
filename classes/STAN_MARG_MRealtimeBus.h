//
//  MBus.h
//  marguerite
//
//  Created by Kevin Conley on 7/22/13.
//  Copyright (c) 2013 Cardinal Devs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "STAN_MARG_MRoute.h"

@interface STAN_MARG_MRealtimeBus : NSObject

@property (nonatomic, retain) STAN_MARG_MRoute * route;
@property (nonatomic, retain) NSString * vehicleId;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSDictionary *dictionary;

- (id) initWithVehicleId:(NSString *) vid andRouteId:(NSString *)route_id andLocation:(CLLocation *)loc;

@end
